package haxePort.starlingExtensions.flash.movieclipConverter;

import haxePort.starlingExtensions.flash.movieclipConverter.AtlasDescriptor;
import haxePort.starlingExtensions.flash.movieclipConverter.AtlasDescriptor;
import haxePort.starlingExtensions.utils.DisplayUtil;
import haxePort.starlingExtensions.flash.movieclipConverter.AtlasDescriptor;
import log.LogUI;
import flash.utils.Function;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.IGraphicsData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.display.PixelSnapping;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.ds.ObjectMap;
import haxe.ds.Vector;
import haxe.Timer;
import haxePort.starlingExtensions.flash.textureAtlas.SubtextureRegion;
import haxePort.utils.LogStack;

import haxePort.managers.Handlers;

import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.utils.RectangleUtil;
import haxePort.starlingExtensions.utils.ScaleMode;
import haxePort.starlingExtensions.utils.GetNextPowerOfTwo;

import haxePort.utils.ObjUtil;
import haxePort.utils.GlobalToContenRect;
import flash.Lib.getTimer;

/**
 * The basic class that is using for atlases creation.  
 * @author peak
 * 
 */
class FlashAtlas extends ContentSprite {
/**
	 * if true atlas drawing will use the BitmapData.drawWithQuality method with drawQuality value
	 * if false atlas drawing will use the simple BitmapData.draw method using the native stage quality 
	 */
    public var drawWithQuality:Bool = true;
    public var drawQuality:StageQuality = StageQuality.HIGH;
/**
	 * bitmadData.draw smoothing value 
	 */
    public var drawSmoothly:Bool = true;
/**
	 * if true converter will draw each mirror movie clip frame and will place there resulting bitmaps
	 * if falase converter will create movieclip clones for each required frame to be drawn. Al movieclip frames clones are cached in an global repository. 
	 */
    public var drawMovieClipFrames:Bool = false;

    private var _shareAtlases = false;

/**
* Using global shared atlases as texture providers. Bee 100% that those atlases will not dipose or loose their textures unexpectedly
**/
    public var reUseGlobalSharedAtlases:Bool = false;

    public var acceptableRegionQuality:Float = 1.5;
    public var acceptableSharedRegionQuality:Float = 0.75;
    public var debug:Bool = true;

    public var isBaselineExtended:Bool = false;
    public var descriptor:AtlasDescriptor;
    public var descriptors:Array<AtlasDescriptor> = [];

    public static inline var curentMaxWidth:Float = 4096;
    public static inline var curentMaxHeight:Float = 4096;

    public static inline var bestWidth:Float = 2048;
    public static inline var bestHeight:Float = 2048;

    private static var sharedDescriptors:Array<AtlasDescriptor> = [];
    public static var helpTexture:Dynamic;

    public function new() {
        super();
    }
    function getMaximumWidth() {
        return isBaselineExtended ? curentMaxWidth : bestWidth;
    }
    function getMaximumHeight() {
        return isBaselineExtended ? curentMaxHeight : bestHeight;
    }
    public function resetDescriptor():AtlasDescriptor {
        if(descriptor==null) {
            descriptor = new AtlasDescriptor(getMaximumWidth(), getMaximumHeight());
        } else {
            var atlasToDrawRect:Rectangle = correctAtlasToDrawRect(descriptor, descriptor.textureAtlasRect);
            var xOffset:Float = atlasToDrawRect!=null ? descriptor.xOffset + atlasToDrawRect.width : 0;
            xOffset *= 1.05;
            descriptor = descriptor.next();
            descriptor.xOffset = xOffset;
            descriptor.yOffset = 0;
        }
        content.scaleX = content.scaleY = descriptor.textureScale;

        descriptors.push(descriptor);
        if(_shareAtlases) {
            shareAtlasesRegions();
        }
        descriptor.atlas = getAtlas(descriptor);
        return descriptor;
    }
/**
	* All texture atlases of this mirror will be shared globally with other mirrors so if they will find appropriate subtextures for reuse they will reuse them.
	* Be carefully, this means that other mirrors will depend them so those atlases should not dispose unexpectedly.
**/
    public function shareAtlasesRegions() {
        _shareAtlases = true;
        if(sharedDescriptors.indexOf(descriptor)<0) {
            if(descriptor!=null) {
                sharedDescriptors.push(descriptor);
            }
        }
    }
    public function isSharingAtlasesRegions() {
        return _shareAtlases;
    }
    public var symbolName:String;
    public var mc:MovieClip;
    public var frame:Int;
    public var subtextureObj:DisplayObject;

    public inline function setCurentOject(obj:DisplayObject, name:String = ""):String {
        subtextureObj = obj;
        symbolName = ObjUtil.getClassName(subtextureObj);
        mc = Std.instance(subtextureObj, MovieClip);
        frame = mc != null ? mc.currentFrame : 1;

        if (subtextureObj.parent == null) addChild(subtextureObj);

        // generating frameName depend on number of frames for proper Array.CASEINSENSITIVE starling internal sorting of TextureAtlas.getTextures method
        return name != "" ? name : getSubtextureName(subtextureObj);
    }

    public inline function getSubtextureName(obj:DisplayObject):String {
        var objName:String = ObjUtil.getClassName(obj);
        var _mc:flash.display.MovieClip = Std.instance(obj, MovieClip);
        if (!isMovieClip(_mc)) _mc = null;

// generating frameName depend on number of frames for proper Array.CASEINSENSITIVE starling internal sorting of TextureAtlas.getTextures method
        if (_mc != null) {
            var addS:String = "";
            if (_mc != null) {
                addS = _mc.currentFrame + "";
                var i:Int = 0;
                var tl:Int = (_mc.totalFrames + "").length;
                var cl:Int = (_mc.currentFrame + "").length;
                while (i < tl - cl) {
                    addS = "0" + addS;
                    i++;
                }
            }
            objName += (addS != "" ? "_" + addS : "");
        }
        return objName;
    }

    public function addMovieClip(descriptor:AtlasDescriptor, mc:MovieClip, includeAllFrames:Bool):Void {
        var frame:Int = mc.currentFrame;
        var startFrame = includeAllFrames ? 1 : frame;
        for (i in startFrame...mc.totalFrames + 1) {
            mc.gotoAndStop(i);
            addSubTexture(descriptor, mc, "");
        }
        mc.visible = false;
        mc.gotoAndStop(frame);
        mc.stopAllMovieClips();
    }

    public function restoreObject(obj:DisplayObject):Void {
        // only movieclips should be hidden as their frames are cloned to same movieclip with the corresponding frame and
        // original movieclip should be hidden
        obj.visible = mc == null;
    }

    public function checkSubtexture(obj:DisplayObject, name:String = "", descriptors:Array<AtlasDescriptor>=null):AtlasDescriptor {
        name = name != "" ? name : getSubtextureName(obj);
        descriptors = descriptors!=null ? descriptors : this.descriptors;
        var subtexture:SubtextureRegion;
        for (descriptor in descriptors) {
            subtexture = descriptor.atlasAbstract.getSubtextureByName(name);
            if (subtexture != null) return descriptor;
        }
        return null;
    }

    public var rectPackerAlgorithmDuration:Float = 0;
    public var subTexture:SubtextureRegion;
    public var continueOnFull:Bool = true;
    public var reuseFullAtlasesFreeRegions:Bool = true;

    public function addSubTextureSomewhere(obj:DisplayObject, name:String = ""):SubtextureRegion {
        if (!reuseFullAtlasesFreeRegions) return addSubTexture(descriptor, obj, name);
        var numDescriptors:Int = descriptors.length;
        for (i in 0...numDescriptors) {
            var descriptor:AtlasDescriptor = descriptors[i];
            var subTexture:SubtextureRegion = addSubTexture(descriptor, obj, name, i == numDescriptors - 1);
            if (subTexture != null) {
                return subTexture;
            }
        }
        return null;
    }

    public function addSubTexture(descriptor:AtlasDescriptor, obj:DisplayObject, name:String = "", addToNextAtlasOnFull:Bool=true):SubtextureRegion {
        subTexture = null;
        var continueFunc:Bool = obj != null;
        if (continueFunc) {
            subtextureObj = null;

            var subTextureName:String = setCurentOject(obj, name);

            var subTextureDescriptor:AtlasDescriptor = checkSubtexture(obj, subTextureName, descriptors);
            subTexture = subTextureDescriptor!=null ? subTextureDescriptor.atlasAbstract.getSubtextureByName(subTextureName) : null;

            var subtextureObjRect:Rectangle = subtextureObj.getBounds(this);
            var subtextureObjRotation = DisplayUtil.getRotationOn(obj, content);

            if (subTexture != null) {
                // checking if subtextureObjRect is bigger than existent subtexture so there is a reason to replace it with a new one (biger wiht a better final quality)
                if (subtextureObjRotation==subTexture.objRotation && (subtextureObjRect.width*subtextureObjRect.height)/(subTexture.width*subTexture.height) >= acceptableRegionQuality) {
                    subTextureDescriptor.freeRectangle(subTexture.regionRect);
                    subTexture.object.visible = false;
                } else {
                    obj.visible = false;
                    continueFunc = false;
                }
            } else if(reUseGlobalSharedAtlases) {
                subTextureDescriptor = checkSubtexture(obj, subTextureName, sharedDescriptors);
                subTexture = subTextureDescriptor!=null ? subTextureDescriptor.atlasAbstract.getSubtextureByName(subTextureName) : null;
                if (subTexture != null) {
                    if (subtextureObjRotation==subTexture.objRotation && (subTexture.width*subTexture.height)/(subtextureObjRect.width*subtextureObjRect.height) >= acceptableSharedRegionQuality) {
                        subTexture = subTexture.cloneInstance();
                        obj.visible = false;
                        continueFunc = false;
                    } else {
                        subTexture = null;
                    }
                }
            }
            if (continueFunc) {

                var t:Float = getTimer();

                var isFull:Bool = descriptor.quickRectInsert(subtextureObjRect) == null;

                rectPackerAlgorithmDuration += (getTimer() - t);
                if (isFull) {
                    // checking if obj bounds fits at least max rect size
                    subtextureObjRect = subtextureObj.getRect(this);
                    if (subtextureObjRect.width > descriptor.maximumWidth || subtextureObjRect.height > descriptor.maximumHeight) {
                        subtextureObjRect = RectangleUtil.fit(subtextureObjRect, descriptor.maxRect, ScaleMode.SHOW_ALL, false, subtextureObjRect);

                        var localRect:Rectangle = GlobalToContenRect.globalToContenRect(subtextureObjRect, obj.parent);
                        obj.width = localRect.width;
                        obj.height = localRect.height;

                        subtextureObjRect = subtextureObj.getRect(this);
                        isFull = descriptor.quickRectInsert(subtextureObjRect) == null;
                    }
                    if (isFull) {
                        if(addToNextAtlasOnFull) {
                            if (continueOnFull) {
                                // trying to insert in a new/next atlas
                                descriptor = resetDescriptor();
                                isFull = descriptor.quickRectInsert(subtextureObjRect) == null;
                            }
                        } else {
                            continueFunc = false;
                            subTexture = null;
                        }
                    }
                }

                if (isFull && !continueOnFull) continueFunc = false;
                if (continueFunc) {
                    subtextureObj = prepareForAtlas(descriptor, subtextureObj, null, subtextureObjRect);
                    if(subtextureObj!=obj) {
                        subtextureObjRotation = DisplayUtil.getRotationOn(subtextureObj, content);
                    }
// storing region
                    subtextureObjRect.x = descriptor.regionPoint.x;
                    subtextureObjRect.y = descriptor.regionPoint.y;

// calculating object position in the Main texture atlas region considering his local position
                    var localP:Point = subtextureObj.parent.globalToLocal(descriptor.regionPoint);
                    var localBounds:Rectangle = subtextureObj.getBounds(subtextureObj.parent);

                    subtextureObj.x -= localBounds.x - localP.x;// - (localBounds.x * subtextureObj.scaleX);
                    subtextureObj.y -= localBounds.y - localP.y;// - (localBounds.y * subtextureObj.scaleY);
                    subtextureObj.visible = true;

                    if (subTexture == null) {
                        subTexture = new SubtextureRegion();

                        subTexture.name = subTextureName;
                        subTexture.symbolName = this.symbolName;
                        subTexture.frame = this.frame;
                        subTexture.frameRect = new Rectangle(0, 0, subtextureObjRect.width, subtextureObjRect.height);
                    }
                    else {
                        subTexture.frameRect.width = subtextureObjRect.width;
                        subTexture.frameRect.height = subtextureObjRect.height;
                    }
                    subTexture.x = subtextureObjRect.x;
                    subTexture.y = subtextureObjRect.y;
                    subTexture.width = subtextureObjRect.width;
                    subTexture.height = subtextureObjRect.height;
                    subTexture.objRotation = subtextureObjRotation;

                    if (mc != null) {
                        var globalBounds:Rectangle = mc.getRect(this);
                        var gp:Point = mc.localToGlobal(descriptor.originPoint);
                        subTexture.pivotX = (gp.x - globalBounds.x) ;
                        subTexture.pivotY = (gp.y - globalBounds.y) ;
                        subTexture.frameLabel = mc != null ? mc.currentFrameLabel : "";
                    }
                    subTexture.regionRect = subtextureObjRect;
                    subTexture.object = subtextureObj;

                    descriptor.addSubtextureRegion(subTexture);
                }
            }
        }
        return subTexture;
    }

    public function prepareForAtlas(descriptor:AtlasDescriptor, obj:DisplayObject, config:Vector<Float> = null, objRect:Rectangle = null, _frame:Int = -1):DisplayObject {
        var mc:MovieClip = Std.instance(obj, MovieClip);

        if (mc != null && isMovieClip(mc)) {
            obj.visible = false;

            if (drawMovieClipFrames) {
                mc.gotoAndStop(_frame);
                mc.stopAllMovieClips();
            }
// drawing original object in case if it is MovieClip or should be drawn by default and using returned Bitmap as atlas region object
            obj = drawMovieClipFrames ? drawAndAddObj(obj) : cloneFrame(mc, objRect, false, _frame);
        }
        if (config != null) {
            obj.x = config[0];
            obj.y = config[1];
            obj.width = config[2];
            obj.height = config[3];
        }
        if (descriptor.subtextureTargets.indexOf(obj) < 0) descriptor.subtextureTargets.push(obj);

        return obj;
    }

    public inline function drawAndAddObj(obj:DisplayObject):DisplayObject {
        var _bmd:BitmapData;
        if (Std.is(obj, Bitmap)) _bmd = Std.instance(obj, Bitmap).bitmapData;
        else {
            _bmd = rasterize(obj, drawWithQuality ? drawQuality : null);
            DRAWS ++;
        }

        var globalObjRect:Rectangle = obj.getBounds(this);
        obj = new Bitmap(_bmd, PixelSnapping.AUTO, true);
        obj.width = globalObjRect.width;
        obj.height = globalObjRect.height;

        return addChild(obj);
    }
    private var movieClipsRectsByFrame:ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    private var movieClipsByFrame:ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();

    public function cloneFrame(mc:MovieClip, mcRect:Rectangle = null, cloneFrameGraphics:Bool = false, _frame:Int = -1):DisplayObject {
        var mcClassName:String = Type.getClassName(Type.getClass(mc));
        _frame = _frame >= 0 ? _frame : mc.currentFrame;

        var framesMC:Array<DisplayObject> = movieClipsByFrame.get(mcClassName);
        if (framesMC == null) {
            framesMC = [];
            movieClipsByFrame.set(mcClassName, framesMC);
        }
        var frameMC:DisplayObject = framesMC != null ? framesMC[_frame] : null;

        if (frameMC == null) {
            if (cloneFrameGraphics) {
                frameMC = new Sprite();
                var v:Bool = mc.visible;
                mc.visible = true;

                var graphicsData:flash.Vector<IGraphicsData> = mc.graphics.readGraphicsData(true);
                Std.instance(frameMC, Sprite).graphics.drawGraphicsData(graphicsData);
                mc.visible = v;
            }
            else {
                var mcClass:Class<Dynamic> = Type.getClass(mc);
                frameMC = Type.createEmptyInstance(mcClass);
            }

            framesMC[_frame] = frameMC;
        }
        var _frameMC:MovieClip = Std.instance(frameMC, MovieClip);
        if (_frameMC != null && _frameMC.currentFrame != _frame) {
            _frameMC.gotoAndStop(_frame);
            _frameMC.stopAllMovieClips();
        }

        var mcRects:Array<Rectangle> = movieClipsRectsByFrame.get(mcClassName);
        if (mcRects == null) {
            mcRects = [];
            movieClipsRectsByFrame.set(mcClassName, mcRects);
        }
        if (mcRect == null) {
            mcRect = mcRects != null ? mcRects[_frame] : null;

            if (mcRect == null) {
                if (mc.currentFrame != _frame) {
                    mc.gotoAndStop(_frame);
                    mc.stopAllMovieClips();
                }
                mcRect = mc.getBounds(this);
            }
        }
        mcRects[_frame] = mcRect;

        frameMC.width = mcRect.width;
        frameMC.height = mcRect.height;

        frameMC.visible = true;
        frameMC.filters = mc.filters;
//if(mc.transform.colorTransform) frameMC.transform.colorTransform = mc.transform.colorTransform;

        return addChild(frameMC);
    }
    public static var getAtlasFunc:Function;

    public function getAtlas(descriptor:AtlasDescriptor):ITextureAtlasDynamic {
        var atlas:ITextureAtlasDynamic = Handlers.functionCall(getAtlasFunc, [helpTexture, descriptor.atlasAbstract]);
        if (atlas != null) {
            atlas.atlas = descriptor.atlasAbstract;
        }
        return atlas;
    }
    public var useMipMaps:Bool = false;
    public var atlasBmd:BitmapData;

    public function createTextureAtlass(descriptor:AtlasDescriptor):ITextureAtlasDynamic {
        if (width == 0 || height == 0) return null;
        descriptor.atlas.setTexture(drawAtlasToTexture(descriptor, getAtlasToDrawRect(descriptor)));
        return descriptor.atlas;
    }
    public static var textureFromBmdFunc:Dynamic;
/**
	 * 
	 * @param rect
	 * @return ConcreteTexture_Dynamic instance 
	 * 
	 */

    public function drawAtlasToTexture(descriptor:AtlasDescriptor, rect:Rectangle):Dynamic {
        if (width == 0 || height == 0) return null;
        atlasBmd = drawAtlas(descriptor, rect);

        return Handlers.functionCall(textureFromBmdFunc, [atlasBmd, descriptor.atlas.textureScale]);
    }
    public var drawMAX_RECTAtlas:Bool = false;

    public function getAtlasToDrawRect(descriptor:AtlasDescriptor, sourceAtlas:ITextureAtlasDynamic = null):Rectangle {
        return correctAtlasToDrawRect(descriptor, descriptor.textureAtlasRect);
    }

    public inline function correctAtlasToDrawRect(descriptor:AtlasDescriptor, rect:Rectangle):Rectangle {
        var properRect:Rectangle = drawMAX_RECTAtlas ? descriptor.maxRect : rect;

        var w:Int = properRect.width >= descriptor.maximumWidth ? Std.int(descriptor.maximumWidth) : GetNextPowerOfTwo.getNextPowerOfTwo(Std.int(properRect.width));
        var h:Int = properRect.height >= descriptor.maximumHeight ? Std.int(descriptor.maximumHeight) : GetNextPowerOfTwo.getNextPowerOfTwo(Std.int(properRect.height));

        return new Rectangle(0, 0, w, h);
    }
    public var debugAtlas:Bool = false;
    public var DRAWS:Int = 0;
    public static var saveAtlasPngFunc:Function;

    public function drawAtlas(descriptor:AtlasDescriptor, rect:Rectangle):BitmapData {
        var t:Float = debug ? getTimer() : 0;

        content.scaleX = content.scaleY = descriptor.textureScale;

        if (debugAtlas) {
            drawFreeRectangles(descriptor);
        }

        atlasBmd = new BitmapData(Std.int(rect.width), Std.int(rect.height), !debugAtlas, 0x000000);

        var drawMatrix:Matrix = new Matrix( 1, 0, 0, 1, - rect.x, - rect.y );
        if (drawWithQuality) atlasBmd.drawWithQuality(this, drawMatrix, null, null, null, drawSmoothly, drawQuality);
        else atlasBmd.draw(this, drawMatrix, null, null, null, drawSmoothly);

        if (debug) {
            DRAWS ++;
        }

        if (debugAtlas) Handlers.functionCall(saveAtlasPngFunc, [descriptor.atlasAbstract.imagePath, atlasBmd]);

        if (debug) LogStack.addLog(this, "FlashAtlas.drawAtlas size", [descriptor.textureAtlasRect, rect, "drawWithQuality-" + drawWithQuality, "drawQuality-" + drawQuality, "DURATION-" + (getTimer() - t), "bmd size-" + ObjUtil.getObjSize(atlasBmd),
        "\nlastSubtextureTargets-" + descriptor.subtextureTargets.length, debugAtlas ? "\n" + descriptor.atlasAbstract : "", "content scale-" + content.scaleX + "/" + content.scaleY]);

        AtlasDescriptor.savedAtlases++;
        return atlasBmd;
    }

    function drawFreeRectangles(descriptor:AtlasDescriptor) {
        for(i in 0...descriptor.freeAreas.length) {
            var r:Rectangle = descriptor.freeAreas[i];
            content.graphics.lineStyle(2,0x00ff00);
            content.graphics.drawRect(r.x + descriptor.xOffset, r.y+descriptor.yOffset, r.width, r.height);
        }
    }

    public function isMovieClip(value:MovieClip):Bool {
        if (value == null) return false;

        if (Reflect.hasField(value, "isMovieClip")) return Reflect.field(value, "isMovieClip") == true;

        var isMc:Bool = value.totalFrames > 1;
        Reflect.setField(value, "isMovieClip", isMc);

        return isMc;
    }

    public inline function getSubtexture(name:String, region:Rectangle = null, frame:Rectangle = null, extrusionFactor:Float = 100):Dynamic {
        if (descriptor.atlas != null) {
            if (region != null || frame != null || extrusionFactor < 100) return descriptor.atlas.getExtrudedTexture(name, region, frame, extrusionFactor);
            else return descriptor.atlas.getTextureObjByName(name);
        }
        return null;
    }

    public inline function getSubtextures(name:String, result:Dynamic):Dynamic {
        return descriptor.atlas != null ? descriptor.atlas.getTexturesObj(name, result) : null;
    }

    function clear():Void {
        Reflect.callMethod(this, forEachChild, [this, removeAtlasContainerChild]);
        resetDescriptor();
    }

    public inline function removeAtlasContainerChild(child:DisplayObject, childIndex:Int):Void {
        ObjUtil.dispose(child, false);
        if (child.parent != null) child.parent.removeChild(child);
    }

    public inline static function forEachChild(sprite:DisplayObjectContainer, func:Function, parameters:Array<Dynamic> = null):Void {
        var _numChildren:Int = Std.is(sprite, ContentSprite) ? Std.instance(sprite, ContentSprite).get_numChildren() : sprite.numChildren;
        var child:DisplayObject;

        var _parameters:Array<Dynamic> = parameters != null ? parameters.copy() : [];

        for (i in 0..._numChildren) {
            child = sprite.getChildAt(_numChildren - 1 - i);
            _parameters[0] = child;
            _parameters[1] = _numChildren - i;

            Handlers.functionCall(func, _parameters);
        }
    }

    public inline static function rasterize(obj:DisplayObject, drawQuality:StageQuality = null, usePowerOfTwoSize:Bool = false, boundsTargetCoordinateSpace:DisplayObject = null):BitmapData {
        if (boundsTargetCoordinateSpace == null) boundsTargetCoordinateSpace = obj.parent != null ? obj.parent : obj;

        var objRect:Rectangle = obj.getBounds(boundsTargetCoordinateSpace);

        var _bData:BitmapData = new BitmapData(usePowerOfTwoSize ? GetNextPowerOfTwo.getNextPowerOfTwo(Std.int(objRect.width)) : Std.int(objRect.width),
        usePowerOfTwoSize ? GetNextPowerOfTwo.getNextPowerOfTwo(Std.int(objRect.height)) : Std.int(objRect.height), true, 0);
        var _mat:Matrix = obj.transform.matrix;
        _mat.translate(-objRect.x, -objRect.y);

        if (drawQuality != null) _bData.drawWithQuality(obj, _mat, null, null, null, true, drawQuality);
        else _bData.draw(obj, _mat, null, null, null, true);

        return _bData;
    }
}