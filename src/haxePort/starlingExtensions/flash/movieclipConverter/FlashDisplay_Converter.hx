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
	override public inline function checkSubtexture(obj:DisplayObject,name:String=""):SubtextureRegion
	{
		name = name!="" ? name : getSubtextureName(obj);	
		var subTexture:SubtextureRegion = descriptor.atlasAbstract.getSubtextureByName(name);
		if (subTexture==null) subTexture = curentMirror.state.getSubtexture(name, symbolName);
		return subTexture;
	}
	override public inline function restoreObject(obj:DisplayObject):Void
	{
		super.restoreObject(obj);
		
		var _mc:MovieClip = Std.instance(obj, MovieClip);
		var isEconomicBtn:Bool = isEconomicButton(_mc);
		
		obj.visible = _mc==null && !isEconomicBtn;
	}
	/**
	 * existing  textureAtlasses
	 */		
	public var atlasesPool:Array<ITextureAtlasDynamic>;
	public var atlasPoolIndex:Int = 0;
	
	public var reuseAtlases(null, set):Bool;
	private var _reuseAtlases:Bool = false;
	/**
	 * If this instance of converter is common for many instances of converted display objects then converter will save all atlases that will be reused for other
	 * convertion. The point is that converter may be reused only sequential. It means that last instance that used it should be hidden.
	 * Most common cases on converter reuse is for app. UI layers with a lot of graphics data.  
	 * @param value
	 * 
	 */		
	public function set_reuseAtlases(value:Bool):Bool
	{
		if(value && atlasesPool!=null) return false;
		
		if(value && atlasesPool==null) atlasesPool = [];
		else 
		{
			atlasesPool = null;
			_reuseAtlases = false;
		}
		return _reuseAtlases;
	}
	override public function clear():Void
	{
		super.clear();
		textureScale = 1;
	}
	override public function resetAll():Void
	{
		super.resetAll();
		textureScale = 1;
		descriptor.atlasAbstract.imagePath = curentMirror+"_"+descriptor.atlasAbstract.imagePath;
		descriptor.atlasConfig = new ObjectMap();
	}
	/**
	 * if true and we reuse an existing atlas which texture will get a new content provided by converter then we use atlas texture size.  
	 */		
	public var useAtlasBiggestSize:Bool = false;
	/**
	 * atlas content scale factor fo fitting the atlas content 
	 */		
	public var textureScale:Float = 1;
	/**
	 * if true atlas is scaled up or down depend on removeGaps variable 
	 * if false and the context profile is baseLine extended -> atlas is drawn using his default size
	 */		
	public var scaleTexture:Bool = false;
	
	public var scaledRect:Rectangle = new Rectangle();
	override public function getAtlasToDrawRect(sourceAtlas:ITextureAtlasDynamic=null):Rectangle
	{
		var rect:Rectangle = super.getAtlasToDrawRect(sourceAtlas);
		if(rect==null) return null;
		
		if(useAtlasBiggestSize && sourceAtlas!=null)
		{
			var sourceTexture:Dynamic = sourceAtlas.curentTexture();
			if(rect.width!=sourceTexture.nativeWidth || rect.height!=sourceTexture.nativeHeight)
			{
				rect.width = rect.width>sourceTexture.nativeWidth ? rect.width : sourceTexture.nativeWidth;
				rect.height = rect.height>sourceTexture.nativeHeight ? rect.height : sourceTexture.nativeHeight;
			}
		}
		
		scaledRect = !scaleTexture && AtlasDescriptor.isBaselineExtended ? descriptor.textureAtlasRect : generateQuality(descriptor.textureAtlasRect,rect,removeGaps);
		
		var factorX:Float = scaledRect.width  / descriptor.textureAtlasRect.width;
		var factorY:Float = scaledRect.height / descriptor.textureAtlasRect.height;
		
		textureScale = factorX < factorY ? factorX : factorY;
		descriptor.atlasAbstract.atlasRegionScale = textureScale;
		atlas.textureScale = textureScale;
		
		LogStack.addLog(this,"getAtlasToDrawRect",["atlasRegionScale-"+textureScale]);
		
		return scaledRect;
	}
	/**
	 * if true and the size is smaller than the middle between two power of two sizes atlas content is scaled down to nearest size
	 * if false atlas content is scaled to the power of two size
	 */		
	public var removeGaps:Bool = true;
	/**
	 * if true atlas content is scaled down when needed. Required for low end devices for memory enconomy. 
	 */		
	public var enableAutoDownScale:Bool = true;
	
	public var properRect:Rectangle = new Rectangle();
	public function generateQuality(atlasRect:Rectangle,rect:Rectangle,calculateBestSize:Bool):Rectangle
	{
		var initialW:Float = calculateBestSize ? scaledRect.width : atlasRect.width;
		var initialH:Float = calculateBestSize ? scaledRect.height : atlasRect.height;
		
		// choosing the proper atlas content size to fit the power of two size. It may scale up(better quality) or down(lower quality) depend on the size
		properRect.width = atlasRect.width/(rect.width/2)<1.5 && removeGaps ? rect.width/2 : rect.width;
		properRect.height = atlasRect.height/(rect.height/2)<1.5 && removeGaps ? rect.height/2 : rect.height;
		
		// if enableAutDownScale is false return from the method te target rectangle
		if(properRect.width<rect.width || properRect.height<rect.height)
			if(!enableAutoDownScale) 
				return rect; 
		
		scaledRect = RectangleUtil.fit(atlasRect,properRect,ScaleMode.SHOW_ALL,false,scaledRect);
		
		scaledRect = correctAtlasToDrawRect(scaledRect);
		
		var factorX:Float = scaledRect.width  / atlasRect.width;
		var factorY:Float = scaledRect.height / atlasRect.height;
		
		textureScale = factorX < factorY ? factorX : factorY;
		
		if(scaledRect.width==initialW && scaledRect.height==initialH) return scaledRect;
		
		var newRect:Rectangle = new Rectangle(0,0,atlasRect.width*textureScale,atlasRect.height*textureScale);
		
		LogStack.addLog(this,"generateQuality",["enableAutoDownScale-"+enableAutoDownScale,curentMirror,textureScale,initialW,initialH,newRect,scaledRect]);
		
		if(calculateBestSize || textureScale>1) scaledRect = generateQuality(newRect,scaledRect,false);
		
		return scaledRect;
	}
	override public function getAtlas():ITextureAtlasDynamic
	{
		var a:ITextureAtlasDynamic = _reuseAtlases && atlasesPool!=null && atlasPoolIndex<atlasesPool.length ? atlasesPool[atlasPoolIndex] : null;
		
		atlasPoolIndex ++;
		
		if(a!=null) return a;
		
		a = super.getAtlas();
		
		if(atlasesPool!=null && atlasesPool.indexOf(a)<0) atlasesPool.push(a);
		
		return a;
	}
	override public function createTextureAtlass():ITextureAtlasDynamic
	{
		var t:Float = getTimer();
		
		var atlasRect:Rectangle;
		if(atlas.textureSource!=FlashAtlas.helpTexture)  
		{
			atlasRect = getAtlasToDrawRect(atlas).clone();
			
			// preparing atlas for new bmd upload. This method dispose the texture if the size if different. It is important to be done before drawing new atlas
			atlas.prepareForBitmapDataUpload(atlasRect.width,atlasRect.height);
			
			atlas.haxeUpdate(descriptor.atlasAbstract,drawAtlas(atlasRect));
		}
		else 
		{
			atlasRect = getAtlasToDrawRect().clone();
			atlas.setAtlas(descriptor.atlasAbstract); 
			atlas.setTexture( drawAtlasToTexture(atlasRect));
		}
					
		descriptor.atlasConfig.set(atlas,[atlasRect,textureScale]);
		descriptor.atlasConfig.set(atlasRect, [descriptor.regionPoint.x, descriptor.regionPoint.y]);
		
		curentMirror.state.storeAtlas(atlas,descriptor.atlasConfig,descriptor.atlasAbstract);
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
		for(subtextObj in descriptor.subtextureTargets)
		{
			processObjType(subtextObj,curentMirror.getMirrorRect(subtextObj));
			subtextObj.visible = false; 
		}
		
		textureScale = content.scaleX = content.scaleY = 1;
		descriptor.reset();
		
		if(!hierarchyParsingComplete)
		{
			atlas = getAtlas();
		}
	}
	override public function drawAtlas(rect:Rectangle):BitmapData
	{
		content.scaleX = content.scaleY = textureScale;
		var bmd:BitmapData = super.drawAtlas(rect);   
		
		for(subtextObj in descriptor.subtextureTargets)
		{
			processObjType(subtextObj,curentMirror.getMirrorRect(subtextObj));
			subtextObj.visible = false; 
		}
		
		return bmd;
	}
	public function redrawAtlas(atlas:ITextureAtlasDynamic,_atlasConfig:ObjectMap<Dynamic,Dynamic>):BitmapData
	{ 
		restoreAtlas(_atlasConfig); 
		
		var atlasConf:Dynamic = _atlasConfig.get(atlas);
		var rect:Rectangle = atlasConf[0];
		textureScale = atlasConf[1];
		
		atlas.prepareForBitmapDataUpload(rect.width,rect.height);
		
		return drawAtlas(rect); 
	}
	public function restoreAtlas(_atlasConfig:ObjectMap<Dynamic,Dynamic>):Void
	{
		var objConfig:Dynamic;
		var _mc:MovieClip;
		
		descriptor.reset();
		
		for(key in _atlasConfig.keys())
		{
			if(!Std.is(key,DisplayObject)) continue; 
			objConfig = _atlasConfig.get(key);
			
			var parentMC:MovieClip = Std.is(key.parent, MovieClip) ? Std.instance(key.parent,MovieClip) : null;
			if(parentMC!=null && parentMC.totalFrames>1) parentMC.gotoAndStop(1);
			
			key.visible = true;
			_mc = Std.instance(key,MovieClip);
			
			if(isMovieClip(_mc))
			{
				var mcConfig:Vector<Float>;
				var frames:Int = _mc.totalFrames;
				for(frame in 1...frames+1)
				{
					mcConfig = objConfig[frame]; 
					if(mcConfig==null) continue;
					
					prepareForAtlas(_mc,mcConfig,null,frame);	
				}
				_mc.visible = false;
			}
			else 
			{
				processObjType(cast(key,DisplayObject));					
				prepareForAtlas(cast(key,DisplayObject),objConfig); 
			}
		}			
	}
	private var convertDescriptor:ConvertDescriptor;
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
							isBaselineExtended:Bool=false,autoReset:Bool=true):IFlashMirrorRoot
	{	
		if(object==null) return null;
		convertDescriptor = _descriptor;
		
		AtlasDescriptor.isBaselineExtended = isBaselineExtended;
		LogStack.addLog(this,"-------------------------------------- CONVERT " + object + " to " + mirror + " -------------------------------------------");
		
		object.visible = false;

		var t:Float = debug ? getTimer() : 0;

		try{
			if(isDisplayObjectContainer(object)) Std.instance(object,DisplayObjectContainer).stopAllMovieClips();
		}catch(msg:String){}

		rectPackerAlgorithmDuration = 0;   
		NUM_LOOPS = DRAWS = 0;
		
		setTarget(object,mirror);

		// changing object size in case if it is bigger than the screen size, however big textures are not required for small screens			
		if(object.scaleX==1 && object.scaleY==1) RectangleUtil.scaleToContent(object,coordinateSystemRect,false,curentMirror.quality,descriptor.MAX_RECT); 
		
		curentMirror.state.mirrorRect = new Rectangle(object.x,object.y,object.width,object.height);
		
		atlas = getAtlas();
		
		hierarchyParsingComplete = false;
		
		if (isDisplayObjectContainer(object)) convertSprite(Std.instance(object,DisplayObjectContainer), mirror, _descriptor);
		else convertObject(object,0);
		
		hierarchyParsingComplete = true;
		
		_descriptor.convertDuration = getTimer() - t;
		_descriptor.maxRectPackerAlgorithDuration = rectPackerAlgorithmDuration;
		
		mirror.registerMirror(mirror,object); 
		
		LogStack.addLog(this,"convert", [curentMirror, "DURATION-"+_descriptor.convertDuration,"chooseBestRegionSizes-"+chooseBestRegionSizes,
			"useMaxRectPackerAlgorythm-"+descriptor.useMaxRectPackerAlgorythm,
			"packer placeInSmallestFreeRect-"+descriptor.placeInSmallestFreeRect,
			"packerRectAlgorithmDuration-"+rectPackerAlgorithmDuration, "num loops-"+NUM_LOOPS]);
		
		createTextureAtlass();
		
		var createChildrenTimeStamp:Float = getTimer();
		
		mirror.createChildren();
		mirror.onCreateChildrenComplete();
		
		_reuseAtlases = atlasesPool!=null;
		
		if (autoReset)
		{			
			clear();
			resetAll();
		}
		
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
			resetAll();
		}
		
		curentMirror = mirror;
		
		addChild(object);
		// for redrawing we set the same flash display object position for proper mathing
		if(mirror!=null && mirror.state.mirrorRect!=null)
		{
			object.x = mirror.state.mirrorRect.x;
			object.y = mirror.state.mirrorRect.y;
		}
		else // for converting and creating
		{	
			var objRect:Rectangle = object.getBounds(object);
			object.x = descriptor.MAX_RECT.width*1.1 - objRect.x;
			object.y = descriptor.MAX_RECT.height*1.1 - objRect.y;
		}
		content.scaleX = content.scaleY = 1;
		
		atlasPoolIndex = 0;
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
		curentMirror.state.storeMirrorRect(sprite,objRect);
		
		processFlashObjQuality(sprite);
		
		if(resultSprite==null) resultSprite = curentMirror.getMirror(sprite);
		if(resultSprite==null) 
		{
			var spClass:Class<Dynamic> = convertDescriptor.getObjClassToConvert(sprite);
			
			// getting instance from pool
			resultSprite = curentMirror.state.useObjPool ? Std.instance(ObjPool.inst.get(spClass,false),IDisplayObjectContainer) : null;
			if(resultSprite==null) resultSprite = curentMirror.convertSprite(sprite,spClass);
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
			
			// if resultSprite is from pool then all his children should be registered in new rootSprite
			if(curentMirror.state.useObjPool)
			{
				if(Std.is(resultSprite,IFlashSpriteMirror)) childMirror = Std.instance(resultSprite,IFlashSpriteMirror).getMirrorChildAt(objIndex); 
				else childMirror = resultSprite!=null && objIndex<resultSprite.numChildrens() ? resultSprite.getChildAtIndex(objIndex) : null;
				
				if(childMirror) curentMirror.registerMirror(childMirror,child);
			}
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
			var subTextures:Vector<SubtextureRegion> = curentMirror.state.getSubtextures(_symbolName);
			
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
			curentMirror.state.addSubtextures(mc, objBounds, _symbolName, subTextures);  
			//mc.visible = false;
			mc.stop();
		}
		else  
		{
			if (Std.is(child,TextField))  
			{
				child.visible = drawTextFields;
				if(drawTextFields) subTexture = addSubTexture(child);
			}
			else
			{	
				if(mc!=null) mc.stop();
				processObjType(child);
				
				var objName:String = _isEconomicButton || Std.is(child, DisplayObjectContainer) ? "" : Type.getClassName(Type.getClass(child.parent)) + "_" + objIndex;
				
				subTexture = addSubTexture(child, objName);
			}
			curentMirror.state.addSubtexture(child, objBounds, subTexture, descriptor.atlasAbstract);  
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