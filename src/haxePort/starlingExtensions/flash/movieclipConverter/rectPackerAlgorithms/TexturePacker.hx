package haxePort.starlingExtensions.flash.movieclipConverter.rectPackerAlgorithms;
import flash.geom.Point;
import flash.geom.Rectangle;
class TexturePacker {

    public static inline var DEFAULT_ATLAS_REGIONS_GAP:Float = 2;

    public var maxRect:Rectangle = new Rectangle();

    public var curentMaxW:Float;
    public var curentMaxH:Float;

    public var maximumWidth:Float;
    public var maximumHeight:Float;

    public var textureAtlasRect:Rectangle = new Rectangle();
    public var regionPoint:Point = new Point();

    @:isVar public var xOffset(get, set):Float;

    function set_xOffset(value:Float) {
        return this.xOffset = value;
    }

    function get_xOffset():Float {
        return xOffset;
    }

    function set_yOffset(value:Float) {
        return this.yOffset = value;
    }

    function get_yOffset():Float {
        return yOffset;
    }
    @:isVar public var yOffset(get, set):Float;


    public var atlasRegionsGap:Float = DEFAULT_ATLAS_REGIONS_GAP;
/**
	 * if true - this flag will control the max. rectangle zie. It will start from the smallest possible and will increase each size twice till the maximum. This is useful because the content may be packed using the smalles possible size
	 * if false - the max size will be fixed and algorithm will pack all regions in that size.
	 */
    public var smartSizeIncrease:Bool = false;
/**
	 * by this value the size of the rect will be increased
	 */
    public var smartSizeIncreaseFactor:Float = 1.25;
/**
	 * if true - algorithm will place the rect in the smallest free rectangle
	 * if flase - algorithm will place the rect in the first found proper rectangle (a bit faster because will not go through all free rectangles)
	 */
    public var placeInSmallestFreeRect:Bool = false;

    public function new(maximumW:Float, maximumH:Float) {
        xOffset = yOffset = 0;
        init(maximumW, maximumH);
    }

    function init(width:Float, height:Float):Void {

        _isFull = false;
        maximumWidth = width;
        maximumHeight = height;
        maxRect.width = maximumWidth;
        maxRect.height = maximumHeight;
        curentMaxW = width;
        curentMaxH = height;

        if (smartSizeIncrease) {
            curentMaxW = curentMaxW / 8;
            curentMaxH = curentMaxH / 8;
        }

        regionPoint.x = regionPoint.y = 0;
        textureAtlasRect.x = 0;
        textureAtlasRect.y = 0;
        textureAtlasRect.width = textureAtlasRect.height = 0;
    }

    public function quickInsert(width:Float, height:Float):Rectangle {
        var newNode:Rectangle = packRect(width, height);

        if (newNode != null) {
            textureAtlasRect.width = newNode.x + width > textureAtlasRect.width ? newNode.x + width : textureAtlasRect.width;
            textureAtlasRect.height = newNode.y + height > textureAtlasRect.height ? newNode.y + height : textureAtlasRect.height;
            regionPoint.x = newNode.x + xOffset;
            regionPoint.y = newNode.y + yOffset;
        }
        else {
            if (curentMaxW < maximumWidth || curentMaxH < maximumHeight) {
                increaseCurentMaxRect();
                // trying to add the rect using Main size
                newNode = quickInsert(width, height);
            }
        }

        _isFull = newNode == null;

        return newNode;
    }

    function increaseCurentMaxRect() {
        if (curentMaxW == curentMaxH) curentMaxW = curentMaxW * smartSizeIncreaseFactor < maximumWidth ? curentMaxW * smartSizeIncreaseFactor : maximumWidth;
        else {
            if (curentMaxW > curentMaxH) curentMaxH = curentMaxH * smartSizeIncreaseFactor < maximumHeight ? curentMaxH * smartSizeIncreaseFactor : maximumHeight;
            else curentMaxW = curentMaxW * smartSizeIncreaseFactor < maximumWidth ? curentMaxW * smartSizeIncreaseFactor : maximumWidth;
        }
    }

    public function freeRectangle(r:Rectangle):Void {
    }

    function packRect(width:Float, height:Float):Rectangle {
        return null;
    }

    private var _isFull:Bool = false;
    public var isFull(get, null):Bool = false;

    public function get_isFull():Bool {
        return _isFull;
    }
}
