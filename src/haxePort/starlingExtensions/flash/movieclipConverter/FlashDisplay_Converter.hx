package haxePort.starlingExtensions.flash.movieclipConverter;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxe.ds.Vector;
import haxe.Timer;
import haxePort.starlingExtensions.flash.textureAtlas.SubtextureRegion;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;
import haxePort.starlingExtensions.interfaces.IDisplayObjectContainer;
import haxePort.utils.LogStack;

import haxePort.managers.ObjPool;

import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.utils.RectangleUtil;
import haxePort.starlingExtensions.utils.ScaleMode;
import haxePort.starlingExtensions.utils.Deg2rad;

import flash.Lib.getTimer;

/**
 * A helper class that is used to convert flash display hierarhies in starling.
 * The point of using is that it reacreates almost all the flash structure depends on how is configured. 
 * @author peak
 * 
 */
class FlashDisplay_Converter extends FlashAtlas
{
	public function new()
	{
		super();
	}
//	override public inline function checkSubtexture(obj:DisplayObject,name:String="", descriptors:Array<AtlasDescriptor>=null):SubtextureRegion
//	{
//		name = name!="" ? name : getSubtextureName(obj);
//		var subTexture:SubtextureRegion = descriptor.atlasAbstract.getSubtextureByName(name);
//		if (subTexture==null) subTexture = curentMirror.descriptor.getSubtexture(name, symbolName);
//		return subTexture;
//	}
	override public inline function restoreObject(obj:DisplayObject):Void
	{
		super.restoreObject(obj);

		var _mc:MovieClip = Std.instance(obj, MovieClip);
		var isEconomicBtn:Bool = isEconomicButton(_mc);

		obj.visible = _mc==null && !isEconomicBtn;
	}
	override public function resetDescriptor():Void
	{
		super.resetDescriptor();
		descriptor.atlasAbstract.imagePath = curentMirror+"_"+descriptor.atlasAbstract.imagePath;
	}
	/**
	 * if true and we reuse an existing atlas which texture will get a Main content provided by converter then we use atlas texture size.
	 */
	public var useAtlasBiggestSize:Bool = true;

	public var scaledRect:Rectangle = new Rectangle();
	override public function getAtlasToDrawRect(sourceAtlas:ITextureAtlasDynamic=null):Rectangle
	{
		var rect:Rectangle = super.getAtlasToDrawRect(sourceAtlas);
		if(rect==null) return null;

		if(useAtlasBiggestSize && sourceAtlas!=null)
		{
			var sourceTexture:Dynamic = sourceAtlas.curentTexture();
			if(sourceTexture!=null) {
				if(rect.width!=sourceTexture.nativeWidth || rect.height!=sourceTexture.nativeHeight)
				{
					rect.width = rect.width>sourceTexture.nativeWidth ? rect.width : sourceTexture.nativeWidth;
					rect.height = rect.height>sourceTexture.nativeHeight ? rect.height : sourceTexture.nativeHeight;
				}
			}
		}

		scaledRect = generateQuality(descriptor.textureAtlasRect,rect,removeGaps);

		var factorX:Float = scaledRect.width  / descriptor.textureAtlasRect.width;
		var factorY:Float = scaledRect.height / descriptor.textureAtlasRect.height;

		descriptor.textureScale = factorX < factorY ? factorX : factorY;
		atlas.textureScale = descriptor.textureScale;

		LogStack.addLog(this,"getAtlasToDrawRect",["atlasRegionScale-"+descriptor.textureScale]);

		// saving drawRect offset
		scaledRect.x = descriptor.xOffset * descriptor.textureScale;
		scaledRect.y = descriptor.yOffset * descriptor.textureScale;
		return scaledRect;
	}
	/**
	 * if true and the size is smaller than the middle between two power of two sizes atlas content is scaled down to nearest size
	 * if false atlas content is scaled to the power of two size
	 */
	public var removeGaps:Bool = true;

	public var differenceToScaleDownAtlas = 1.3;

	var properRect:Rectangle = new Rectangle();
	public function generateQuality(atlasRect:Rectangle,rect:Rectangle,calculateBestSize:Bool):Rectangle
	{
		var initialW:Float = calculateBestSize ? scaledRect.width : atlasRect.width;
		var initialH:Float = calculateBestSize ? scaledRect.height : atlasRect.height;

		// choosing the proper atlas content size to fit the power of two size. It may scale up(better quality) or down(lower quality) depend on the size
		properRect.width = removeGaps && atlasRect.width/(rect.width/2)<differenceToScaleDownAtlas ? rect.width/2 : rect.width;
		properRect.height = removeGaps && atlasRect.height/(rect.height/2)<differenceToScaleDownAtlas ? rect.height/2 : rect.height;

		scaledRect = RectangleUtil.fit(atlasRect,properRect,ScaleMode.SHOW_ALL,false,scaledRect);

		scaledRect = correctAtlasToDrawRect(scaledRect);

		var factorX:Float = scaledRect.width  / atlasRect.width;
		var factorY:Float = scaledRect.height / atlasRect.height;

		descriptor.textureScale = factorX < factorY ? factorX : factorY;

		if(scaledRect.width==initialW && scaledRect.height==initialH) return scaledRect;

		var newRect:Rectangle = new Rectangle(0,0,atlasRect.width*descriptor.textureScale,atlasRect.height*descriptor.textureScale);

		LogStack.addLog(this,"generateQuality",[curentMirror,descriptor.textureScale,initialW,initialH,newRect,scaledRect]);

		if(calculateBestSize || descriptor.textureScale>1) scaledRect = generateQuality(newRect,scaledRect,false);

		return scaledRect;
	}
	override public function createTextureAtlass():ITextureAtlasDynamic
	{
		var t:Float = getTimer();

		var atlasRect:Rectangle;
		if(atlas.textureSource!=FlashAtlas.helpTexture)
		{
			atlasRect = getAtlasToDrawRect(atlas).clone();

			// preparing atlas for Main bmd upload. This method dispose the texture if the size if different. It is important to be done before drawing Main atlas
			atlas.prepareForBitmapDataUpload(atlasRect.width,atlasRect.height);

			atlas.haxeUpdate(descriptor.atlasAbstract,drawAtlas(atlasRect));
		}
		else
		{
			atlasRect = getAtlasToDrawRect().clone();
			atlas.atlas = descriptor.atlasAbstract;
			atlas.setTexture(drawAtlasToTexture(atlasRect));
		}

		descriptor.atlasAbstract.atlasConf = new AtlasConf(atlasRect, descriptor.textureScale, descriptor.regionPoint);

		curentMirror.descriptor.storeAtlas(atlas,descriptor.atlasAbstract);
		curentMirror.storeAtlas(atlas, atlasBmd);

		prepareForNextAtlas();

		LogStack.addLog(this, "createTextureAtlass", ["duration-"+(getTimer() - t)]);

		return atlas;
	}
	/**
	 * preparind content for next atlas creation. Hidding all existent texture regions and resetting descriptor. 
	 */
	public function prepareForNextAtlas():Void
	{
		resetDescriptor();

		if(!hierarchyParsingComplete)
		{
			atlas = getAtlas();
		}
	}

	public function redrawAtlas(atlas:ITextureAtlasDynamic):BitmapData {
		var atlasConf:AtlasConf = atlas.atlas.atlasConf;
		descriptor.textureScale = atlasConf.textureScale;
		atlas.prepareForBitmapDataUpload(atlasConf.atlasRect.width, atlasConf.atlasRect.height);
		return drawAtlas(atlasConf.atlasRect);
	}
	public var convertDescriptor:ConvertDescriptor;
	public var hierarchyParsingComplete:Bool = false;
	/**
	 * 
	 * @param object - flash display intance
	 * @param _descriptor - a desriptor that handle all convertion details and classes assoctiations
	 * @param mirror - intance that will contain all converted data
	 * @return 
	 * 
	 */
	public function convert(object:DisplayObject, _descriptor:ConvertDescriptor, mirror:IFlashMirrorRoot, coordinateSystemRect:Rectangle,
							isBaselineExtended:Bool=false):IFlashMirrorRoot
	{
		if(object==null) return null;
		convertDescriptor = _descriptor;

		AtlasDescriptor.isBaselineExtended = isBaselineExtended;
		LogStack.addLog(this,"-------------------------------------- CONVERT " + object + " to " + mirror + " -------------------------------------------");

		var t:Float = debug ? getTimer() : 0;

		rectPackerAlgorithmDuration = 0;
		NUM_LOOPS = DRAWS = 0;

		setTarget(object,mirror);

		// changing object size in case if it is bigger than the screen size, however big textures are not required for small screens
		if(object.scaleX==1 && object.scaleY==1) RectangleUtil.scaleToContent(object,coordinateSystemRect,false,curentMirror.quality,descriptor.maxRect);

		curentMirror.descriptor.mirrorRect = new Rectangle(object.x,object.y,object.width,object.height);

		atlas = getAtlas();

		hierarchyParsingComplete = false;

		stopAllMovieClips();

		if (isDisplayObjectContainer(object)) convertSprite(Std.instance(object,DisplayObjectContainer), mirror, _descriptor);
		else convertObject(object,0);

		stopAllMovieClips();

		hierarchyParsingComplete = true;

		_descriptor.convertDuration = getTimer() - t;
		_descriptor.maxRectPackerAlgorithDuration = rectPackerAlgorithmDuration;

		mirror.registerMirror(mirror,object);

		LogStack.addLog(this,"convert", [curentMirror, "DURATION-"+_descriptor.convertDuration,
			"packer placeInSmallestFreeRect-"+descriptor.placeInSmallestFreeRect,
			"packerRectAlgorithmDuration-"+rectPackerAlgorithmDuration, "num loops-"+NUM_LOOPS]);

		createTextureAtlass();

		var createChildrenTimeStamp:Float = getTimer();

		mirror.createChildren();
		mirror.onCreateChildrenComplete();

		_descriptor.createChildrenDuration = getTimer() - createChildrenTimeStamp;
		_descriptor.totalConvertDuration = getTimer() -t;

		LogStack.addLog(this, "convert+createTextureAtlass+createChildren", [curentMirror, "quality-" + mirror.quality, "createChildrenDuration-"+_descriptor.createChildrenDuration,
											"duration -"+_descriptor.totalConvertDuration, "draws -"+DRAWS]);

		LogStack.addLog(this,"-------------------------------------- CONVERTED " + object + " to " + mirror + " -------------------------------------------");

		return mirror;
	}

	public var target:DisplayObject;
	public var curentMirror:IFlashMirrorRoot;
	public function setTarget(object:DisplayObject,mirror:IFlashMirrorRoot):Void
	{
		target = object;
		object.visible = true;
		visible = true;
		/*
		LogStack.addLog(this,"setTarget",[object,mirror,object.parent==this,curentMirror==mirror]);
		*/

		if(object.parent!=this && curentMirror!=mirror)
		{
			clear();
		}

		curentMirror = mirror;

		addChild(object);
		// for redrawing we set the same flash display object position for proper mathing
		if(mirror!=null && mirror.descriptor.mirrorRect!=null)
		{
			object.x = mirror.descriptor.mirrorRect.x;
			object.y = mirror.descriptor.mirrorRect.y;
		}
		else // for converting and creating
		{
			var objRect:Rectangle = object.getBounds(object);
			object.x = descriptor.maximumWidth*1.1 - objRect.x;
			object.y = descriptor.maximumHeight*1.1 - objRect.y;
		}
	}
	public inline function processFlashObjQuality(obj:DisplayObject):Void
	{
		var textureQuality:Float = getFlashObjField(obj,ConvertUtils.FIELD_QUALITY);
		if(textureQuality!=Math.NaN && textureQuality>0)
		{
			var factor:Float = obj.scaleX/obj.scaleY;
			obj.scaleX *= textureQuality;
			obj.scaleY = obj.scaleX/factor;
		}
	}
	public var spriteConvertMethod:Dynamic;
	public var resetFilters:Bool = false;
	public var NUM_LOOPS:Int = 0;
	private function convertSprite(sprite:DisplayObjectContainer, resultSprite:IDisplayObjectContainer,_descriptor:ConvertDescriptor=null):IDisplayObjectContainer
	{
		if(resetFilters) sprite.filters = null;

		var defaultScaleX:Float = sprite.scaleX;
		var defaultScaleY:Float = sprite.scaleY;

		Reflect.setField(sprite,ConvertUtils.FIELD_DEFAULT_SCALEX,defaultScaleX);
		Reflect.setField(sprite,ConvertUtils.FIELD_DEFAULT_SCALEY,defaultScaleY);

		var objRect:Rectangle = sprite.getBounds(sprite.parent);
		curentMirror.descriptor.storeMirrorRect(sprite,objRect);

		processFlashObjQuality(sprite);

		if(resultSprite==null) resultSprite = curentMirror.getMirror(sprite);
		if(resultSprite==null)
		{
			var spClass:Class<Dynamic> = convertDescriptor.getObjClassToConvert(sprite);
			resultSprite = curentMirror.convertSprite(sprite,spClass);
		}

		var _numChildren:Int = sprite.numChildren;
		var child:DisplayObject;
		var childMirror:Dynamic;

		NUM_LOOPS += _numChildren;
		for (objIndex in 0..._numChildren)
		{
			child = sprite.getChildAt(objIndex);

			childMirror = null;

			if(_descriptor.ignore(child)) continue;

			// converting child
			if (isDisplayObjectContainer(child))
			{
				childMirror = convertSprite(Std.instance(child,DisplayObjectContainer), Std.instance(childMirror,IDisplayObjectContainer), _descriptor);
				if(!childMirror) continue;

				if(childMirror!=resultSprite && childMirror.parent!=resultSprite) resultSprite.adChild(childMirror);
				curentMirror.storeInstance(childMirror, child);

				if(Std.is(childMirror,IFlashSpriteMirror)) Std.instance(childMirror,IFlashSpriteMirror).unflatten();
			}
			else convertObject(child, objIndex);
		}

		return resultSprite;
	}
	/**
	* if true converter will include all textfields and will convert them to images 
	*/
	public var drawTextFields:Bool = false;
	public var useFeathersScaledImages:Bool = true;
	public var registerMovieClipsPivots:Bool = true;
	public var registerMovieClipsFrameSize:Bool = true;
	private function convertObject(child:DisplayObject, objIndex:Int=0):Void
	{
		var subTexture:SubtextureRegion = null;
		var objBounds:Rectangle = child.getBounds(child.parent);

		processFlashObjQuality(child);

		var mc:MovieClip = Std.instance(child,MovieClip);
		var _isEconomicButton:Bool = isEconomicButton(mc);

		if(superIsMovieClip(mc) && !_isEconomicButton)
		{
			var isBtn:Bool = isButton(mc);
			var objType:String = getFlashObjType(mc);
			// setting proper position for mc rect. This value will be assigned to mirror movieClip
			if(!isBtn && objType!=ConvertUtils.TYPE_BTN)
			{
				objBounds.x = mc.x;
				objBounds.y = mc.y;
			}
			var _symbolName:String = Type.getClassName(Type.getClass(child));
			var subTextures:Vector<SubtextureRegion> = curentMirror.descriptor.getSubtextures(_symbolName);

			if(subTextures==null)
			{
				subTextures = new Vector<SubtextureRegion>(mc.totalFrames);

				for(i in 1...mc.totalFrames+1)
				{
					mc.gotoAndStop(i);
					subTexture = addSubTexture(mc, "");

					subTextures.set(i-1,subTexture);
				}
			}
			curentMirror.descriptor.addSubtextures(mc, objBounds, _symbolName, subTextures);
			mc.stop();
		}
		else
		{
			if (Std.is(child,TextField))
			{
				child.visible = drawTextFields;
				if(child.visible) subTexture = addSubTexture(child);
			}
			else
			{
				if(mc!=null) mc.stop();
				processObjType(child);

				var objName:String = _isEconomicButton || Std.is(child, DisplayObjectContainer) ? "" : Type.getClassName(Type.getClass(child.parent)) + "_" + objIndex;

				subTexture = addSubTexture(child, objName);
			}
			curentMirror.descriptor.addSubtexture(child, objBounds, subTexture, descriptor.atlasAbstract);
		}
	}

	private function processObjType(obj:DisplayObject,rect:Rectangle=null):Void
	{
		if(obj.parent!=null)
		{
			var objType:String = getFlashObjType(obj);

			switch(objType)
			{
				case ConvertUtils.TYPE_QUAD:
				{
					obj.width = rect==null ? 50/obj.parent.scaleX : rect.width;
					obj.height = rect==null ? 50/obj.parent.scaleY : rect.height;
				}
				case ConvertUtils.TYPE_PRIMITIVE:
				{
					obj.width = rect==null ? 50/obj.parent.scaleX : rect.width;
					obj.height = rect==null ? 50/obj.parent.scaleY : rect.height;
				}
				case ConvertUtils.TYPE_SCALE3_IMAGE:
				{
					if(useFeathersScaledImages)
					{
						var hResizeFactor:Float = getFlashObjField(obj,"hResizeFactor");
						var vResizeFactor:Float = getFlashObjField(obj,"vResizeFactor");

						obj.width = rect==null ? obj.width/hResizeFactor : rect.width;
						obj.height = rect==null ? obj.height/vResizeFactor : rect.height;
					}
				}
				case ConvertUtils.TYPE_SCALE9_IMAGE:
				{
					if(useFeathersScaledImages)
					{
						var hResizeFactor:Float = getFlashObjField(obj,"hResizeFactor");
						var vResizeFactor:Float = getFlashObjField(obj,"vResizeFactor");

						obj.width = rect==null ? obj.width/hResizeFactor : rect.width;
						obj.height = rect==null ? obj.height/vResizeFactor : rect.height;
					}
				}
			}
		}
	}
	private static var px:Point = new Point(0, 1);
	private static var py:Point = new Point(1, 0);
	public inline static function getSkewX(obj:DisplayObject,returnAbsoluteveValue:Bool=true):Float
	{
		px.x = py.y = 0;
		px.y = py.x = 1;
		var m:Matrix = obj.transform.matrix;
		px = m.deltaTransformPoint(px);
		py = m.deltaTransformPoint(py);

		var s:Float = Math.round(((180/Math.PI) * Math.atan2(px.y, px.x) - 90));

		return returnAbsoluteveValue ? Math.abs(s) : s;
	}
	public inline static function getSkewY(obj:DisplayObject,returnAbsoluteveValue:Bool=true):Float
	{
		px.x = py.y = 0;
		px.y = py.x = 1;
		var m:Matrix = obj.transform.matrix;
		px = m.deltaTransformPoint(px);
		py = m.deltaTransformPoint(py);

		var s:Float = Math.round(((180/Math.PI) * Math.atan2(py.y, py.x)));

		return returnAbsoluteveValue ? Math.abs(s) : s;
	}
	public inline static function getSkew(obj:DisplayObject,returnAbsoluteveValue:Bool=true):Array<Float>
	{
		px.x = py.y = 0;
		px.y = py.x = 1;
		var m:Matrix = obj.transform.matrix;
		px = m.deltaTransformPoint(px);
		py = m.deltaTransformPoint(py);

		var sx:Float = Math.round(((180/Math.PI) * Math.atan2(px.y, px.x) - 90));
		var sy:Float = Math.round(((180/Math.PI) * Math.atan2(py.y, py.x)));
		if(returnAbsoluteveValue)
		{
			sx = Math.abs(sx);
			sy = Math.abs(sy);
		}

		return [sx,sy];
	}
	public inline static function getSkewXRad(obj:DisplayObject,returnAbsoluteveValue:Bool=true):Float
	{
		return returnAbsoluteveValue ?  Math.abs(Deg2rad.deg2rad(getSkewX(obj,returnAbsoluteveValue))) : Deg2rad.deg2rad(getSkewX(obj,returnAbsoluteveValue));
	}
	public inline static function getSkewYRad(obj:DisplayObject,returnAbsoluteveValue:Bool=true):Float
	{
		return returnAbsoluteveValue ? Math.abs(Deg2rad.deg2rad(getSkewY(obj,returnAbsoluteveValue))) : Deg2rad.deg2rad(getSkewY(obj,returnAbsoluteveValue));
	}
	public inline static function isDisplayObjectContainer(obj:DisplayObject):Bool
	{
		var hierarchyField:Dynamic = getFlashObjField(obj, ConvertUtils.FIELD_HIERARCHY);
		if(hierarchyField!=null && hierarchyField==false) return false;

		var isFlashMC:Bool = isFlashMovieClip(obj);
		if(isFlashMC) return true;

		return Std.is(obj, DisplayObjectContainer) && (!Std.is(obj, MovieClip) || Std.instance(obj, MovieClip).totalFrames == 1) && !Std.is(obj, SimpleButton);
	}
	/**
	 * if true all flash buttons (movie clips with 2 frames - down and up) are converted to images and decorated as simple buttons using Decorator_Button class
	 */
	public var economicDecoration:Bool = true;
	public inline function isEconomicButton(obj:MovieClip):Bool
	{
		return economicDecoration && isButton(obj);
	}
	private function superIsMovieClip(value:MovieClip):Bool
	{
		return super.isMovieClip(value);
	}
	override public function isMovieClip(value:MovieClip):Bool
	{
		if(value==null) return false;
		var isEconomicBtn:Bool = isEconomicButton(value);

		return super.isMovieClip(value) && (!isEconomicBtn || !isButton(value));
	}
	public inline static function isFlashMovieClip(obj:DisplayObject):Bool
	{
		var objType:String = getFlashObjType(obj);
		return objType==ConvertUtils.TYPE_FLASH_MOVIE_CLIP && Std.is(obj,MovieClip) && Std.instance(obj,MovieClip).totalFrames>1;
	}
	public static function isButton(value:MovieClip):Bool
	{
		if (value == null) return false;

		if(Reflect.hasField(value,"isButton"))
			return Reflect.field(value,"isButton")==true;

		if(value==null || getFlashObjType(value)==ConvertUtils.TYPE_BTN)
		{
			if(value!=null) Reflect.setField(value,"isButton",false);
			return false;
		}

		value.stop();
		if(value.totalFrames==2)
		{
			var frameLabels:Array<flash.display.FrameLabel> = value.currentLabels;

			if(frameLabels.length!=2)
			{
				Reflect.setField(value,"isButton",false);
				return false;
			}

			if(frameLabels[0].name!=ConvertUtils.BUTTON_KEYFRAME_DOWN && frameLabels[0].name!=ConvertUtils.BUTTON_KEYFRAME_UP) return false;
			if(frameLabels[1].name!=ConvertUtils.BUTTON_KEYFRAME_DOWN && frameLabels[1].name!=ConvertUtils.BUTTON_KEYFRAME_UP) return false;

			Reflect.setField(value,"isButton",true);

			return true;
		}
		return false;
	}
	public inline static function getFlashObjType(obj:DisplayObject):String
	{
		var value:Dynamic = getFlashObjField(obj,"type");
		return value!=null ? value+"" : "";
	}
	public inline static function getFlashObjField(obj:DisplayObject,fieldName:String):Dynamic
	{
		var r:Dynamic=null;
		obj = Std.is(obj,MovieClip) || Std.is(obj,DisplayObjectContainer) ? obj : obj.parent;
		try{
			r = obj!=null && Reflect.hasField(obj,fieldName) ? Reflect.field(obj,fieldName) : null;
		}catch(msg:String){}

		return r;
	}
}