package haxePort.starlingExtensions.flash.movieclipConverter;

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

    public var debug:Bool = true;

    public var descriptor:AtlasDescriptor = new AtlasDescriptor();

    public static var helpTexture:Dynamic;

    public function new() {
        super();

        resetDescriptor();

        atlas = getAtlas();
    }
    function resetDescriptor() {
        var atlasToDrawRect:Rectangle = correctAtlasToDrawRect(descriptor.textureAtlasRect);
        var xOffset:Float = atlasToDrawRect!=null ? descriptor.xOffset + atlasToDrawRect.width : 0;
        xOffset *= 1.1;
        descriptor = descriptor.next();
        descriptor.xOffset = xOffset;
        descriptor.yOffset = 0;
        content.scaleX = content.scaleY = descriptor.textureScale;
    }
    public var symbolName:String;
    public var mc:MovieClip;
    public var frame:Int;
    public var subTextureName:String;
    public var subtextureObj:DisplayObject;

    public inline function setCurentOject(obj:DisplayObject, name:String = ""):Void {
        subtextureObj = obj;
        symbolName = ObjUtil.getClassName(subtextureObj);
        mc = Std.instance(subtextureObj, MovieClip);
        frame = mc != null ? mc.currentFrame : 1;

// generating frameName depend on number of frames for proper Array.CASEINSENSITIVE starling internal sorting of TextureAtlas.getTextures method
        subTextureName = name != "" ? name : getSubtextureName(subtextureObj);

        if (subtextureObj.parent == null) addChild(subtextureObj);
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

    public function addMovieClip(mc:MovieClip):Void {
        var frame:Int = mc.currentFrame;
        for (i in 1...mc.totalFrames + 1) {
            mc.gotoAndStop(i);
            addSubTexture(mc, "");
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

    public function checkSubtexture(obj:DisplayObject, name:String = ""):SubtextureRegion {
        name = name != "" ? name : getSubtextureName(obj);
        return descriptor.atlasAbstract.getSubtextureByName(name);
    }
    public var chooseBestRegionSizeDifference:Float = 2;
    public var chooseBestRegionSizes:Bool = true;
    public var continueOnFull:Bool = true;
    public var subtextureObjRect:Rectangle;
    public var rectPackerAlgorithmDuration:Float = 0;
    public var subTexture:SubtextureRegion;

    public function addSubTexture(obj:DisplayObject, name:String = ""):SubtextureRegion {
        subTexture = null;
        var coninueFunc:Bool = obj != null;
        if (coninueFunc) {
            subtextureObj = null;
            subtextureObjRect = null;

            setCurentOject(obj, name);

            subTexture = checkSubtexture(obj, subTextureName);

            subtextureObjRect = subtextureObj.getBounds(this);

            if (subTexture != null) {
                var bestSizeChoosed:Bool = false;
                if (chooseBestRegionSizes) {
                    if (((subtextureObjRect.width + subtextureObjRect.height) / (subTexture.width + subTexture.height)) >= chooseBestRegionSizeDifference) {
                        descriptor.freeRectangle(subTexture.regionRect);
                        subTexture.object.visible = false;
                        descriptor.atlasConfig.remove(subTexture.object);
                        bestSizeChoosed = true;
                    }
                }
                if (!bestSizeChoosed) {
                    obj.visible = false;
                    coninueFunc = false;
                }
            }
            if (coninueFunc) {

                var t:Float = getTimer();

                descriptor.quickRectInsert(subtextureObjRect);

                rectPackerAlgorithmDuration += (getTimer() - t);
                if (descriptor.isFull) {
                    // checking if obj bounds fits at least max rect size
                    subtextureObjRect = subtextureObj.getRect(this);
                    if (subtextureObjRect.width > descriptor.maximumWidth || subtextureObjRect.height > descriptor.maximumHeight) {
                        subtextureObjRect = RectangleUtil.fit(subtextureObjRect, descriptor.maxRect, ScaleMode.SHOW_ALL, false, subtextureObjRect);

                        var localRect:Rectangle = GlobalToContenRect.globalToContenRect(subtextureObjRect, obj.parent);
                        obj.width = localRect.width;
                        obj.height = localRect.height;

                        descriptor.quickRectInsert(subtextureObjRect);
                    } else if (descriptor.isFull) {
                        onAtlasIsFull();

                        if (continueOnFull) {
                            descriptor.quickRectInsert(subtextureObjRect);
                        }
                    }
                }

                if (descriptor.isFull && !continueOnFull) coninueFunc = false;
                if (coninueFunc) {
                    subtextureObj = prepareForAtlas(subtextureObj, null, subtextureObjRect);

// storing region
                    subtextureObjRect.x = descriptor.regionPoint.x;
                    subtextureObjRect.y = descriptor.regionPoint.y;

// calculating object position in the Main texture atlas region considering his local position
                    var localP:Point = subtextureObj.parent.globalToLocal(descriptor.regionPoint);
                    var localBounds:Rectangle = subtextureObj.getBounds(subtextureObj.parent);

                    subtextureObj.x -= localBounds.x - localP.x;// - (localBounds.x * subtextureObj.scaleX);
                    subtextureObj.y -= localBounds.y - localP.y;// - (localBounds.y * subtextureObj.scaleY);

                    if (subTexture == null) {
                        subTexture = new SubtextureRegion();

                        subTexture.name = this.subTextureName;
                        subTexture.symbolName = this.symbolName;
                        subTexture.x = subtextureObjRect.x;
                        subTexture.y = subtextureObjRect.y;
                        subTexture.width = subtextureObjRect.width;
                        subTexture.height = subtextureObjRect.height;
                        subTexture.frame = this.frame;
                        subTexture.frameRect = new Rectangle(0, 0, subtextureObjRect.width, subtextureObjRect.height);
                    }
                    else {
                        subTexture.x = subtextureObjRect.x;
                        subTexture.y = subtextureObjRect.y;
                        subTexture.width = subtextureObjRect.width;
                        subTexture.height = subtextureObjRect.height;
                        subTexture.frameRect.width = subtextureObjRect.width;
                        subTexture.frameRect.height = subtextureObjRect.height;
                    }

                    if (mc != null) {
                        var globalBounds:Rectangle = mc.getRect(this);
                        var gp:Point = mc.localToGlobal(descriptor.originPoint);
                        subTexture.pivotX = (gp.x - globalBounds.x) ;
                        subTexture.pivotY = (gp.y - globalBounds.y) ;
                        subTexture.frameLabel = mc != null ? mc.currentFrameLabel : "";
                    }
                    subTexture.regionRect = subtextureObjRect;
                    subTexture.object = subtextureObj;

                    descriptor.atlasAbstract.add(subTexture);

                    atlas.atlas = descriptor.atlasAbstract;
                    atlas.addRegion(subTextureName + "", subtextureObjRect, subTexture.frameRect);

                    if (isMovieClip(mc)) {
                        var frames:Array<Vector<Float>> = descriptor.atlasConfig.get(mc);
                        if (frames == null) {
                            frames = [];
                            descriptor.atlasConfig.set(mc, frames);
                        }
                        frames[mc.currentFrame] = Vector.fromArrayCopy([subtextureObj.x, subtextureObj.y, subtextureObj.width, subtextureObj.height]);
                    }
                    else descriptor.atlasConfig.set(subtextureObj, Vector.fromArrayCopy([subtextureObj.x, subtextureObj.y, subtextureObj.width, subtextureObj.height]));
                }
            }
        }
        return subTexture;
    }

    public function prepareForAtlas(obj:DisplayObject, config:Vector<Float> = null, objRect:Rectangle = null, _frame:Int = -1):DisplayObject {
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
    public var onFullHandler:Function;
/**
	 * return true if this object fits the atlas
	 * @return
	 *
	 */

    private function onAtlasIsFull():Void {
        var fitsAtlas:Bool = descriptor.maxRect.containsRect(subtextureObjRect);
        subtextureObj.visible = fitsAtlas;

        createTextureAtlass();
        if (onFullHandler != null) Handlers.functionCall(onFullHandler, [subtextureObj, subTextureName]);

        if (!fitsAtlas) restoreObject(subtextureObj);
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
    private static var movieClipsRectsByFrame:ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    private static var movieClipsByFrame:ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();

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

    public function getAtlas():ITextureAtlasDynamic {
        return Handlers.functionCall(getAtlasFunc, [helpTexture, descriptor.atlasAbstract]);
    }
    public var atlas:ITextureAtlasDynamic;
    public var useMipMaps:Bool = false;
    public var atlasBmd:BitmapData;

    public function createTextureAtlass():ITextureAtlasDynamic {
        if (width == 0 || height == 0) return null;
        atlas.setTexture(drawAtlasToTexture(getAtlasToDrawRect()));
        return atlas;
    }
    public static var textureFromBmdFunc:Dynamic;
/**
	 * 
	 * @param rect
	 * @return ConcreteTexture_Dynamic instance 
	 * 
	 */

    public function drawAtlasToTexture(rect:Rectangle):Dynamic {
        if (width == 0 || height == 0) return null;
        atlasBmd = drawAtlas(rect);

        return Handlers.functionCall(textureFromBmdFunc, [atlasBmd, atlas.textureScale]);
    }
    public var drawMAX_RECTAtlas:Bool = false;

    public function getAtlasToDrawRect(sourceAtlas:ITextureAtlasDynamic = null):Rectangle {
        return correctAtlasToDrawRect(descriptor.textureAtlasRect);
    }

    public inline function correctAtlasToDrawRect(rect:Rectangle):Rectangle {
        var properRect:Rectangle = drawMAX_RECTAtlas ? descriptor.maxRect : rect;

        var w:Int = properRect.width >= descriptor.maximumWidth ? Std.int(descriptor.maximumWidth) : GetNextPowerOfTwo.getNextPowerOfTwo(Std.int(properRect.width));
        var h:Int = properRect.height >= descriptor.maximumHeight ? Std.int(descriptor.maximumHeight) : GetNextPowerOfTwo.getNextPowerOfTwo(Std.int(properRect.height));

        return new Rectangle(0, 0, w, h);
    }
    public var debugAtlas:Bool = false;
    public var DRAWS:Int = 0;
    public static var saveAtlasPngFunc:Function;

    public function drawAtlas(rect:Rectangle):BitmapData {
        var t:Float = debug ? getTimer() : 0;

        content.scaleX = content.scaleY = descriptor.textureScale;

        if (debugAtlas) {
            drawFreeRectangles();
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

    function drawFreeRectangles() {
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
        if (atlas != null) {
            if (region != null || frame != null || extrusionFactor < 100) return atlas.getExtrudedTexture(name, region, frame, extrusionFactor);
            else return atlas.getTextureObjByName(name);
        }
        return null;
    }

    public inline function getSubtextures(name:String, result:Dynamic):Dynamic {
        return atlas != null ? atlas.getTexturesObj(name, result) : null;
    }

    public function clear():Void {
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