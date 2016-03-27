package haxePort.starlingExtensions.flash.textureAtlas;

import flash.geom.Rectangle;
import flash.display.DisplayObject;
/**
 * ...
 * @author val
 */
class SubtextureRegion extends Rectangle {
    public var name:String;
    public var symbolName:String;
    public var frameLabel:String;

    public var object:DisplayObject;

    public var frame:Int;
    public var pivotX:Float;
    public var pivotY:Float;

    public var regionRect:Rectangle;
    public var frameRect:Rectangle;

    public var objRotation:Float;
    @:isVar public var rotated(get, null):Bool;
    function get_rotated():Bool {
        return objRotation!=0;
    }

    public var parent:TextureAtlasAbstract;

    public function new() {
        super();
    }

    public function cloneInstance():SubtextureRegion {
	    var c:SubtextureRegion = new SubtextureRegion();
        c.x = x;
        c.y = y;
        c.width = width;
        c.height = height;
        c.name = name;
        c.symbolName = symbolName;
        c.frameLabel = frameLabel;
        c.object = object;
        c.frame = frame;
        c.pivotX = pivotX;
        c.pivotY = pivotY;
        c.regionRect = regionRect;
        c.frameRect = frameRect;
        c.objRotation = objRotation;
        c.parent = parent;
        return c;
    }
	override public function toString():String 
	{
		return "[SubtextureRegion name=" + name + " symbolName=" + symbolName + " frameLabel=" + frameLabel + " object=" + object + 
					" frame=" + frame + " pivotX=" + pivotX + " pivotY=" + pivotY + " regionRect=" + regionRect + 
					" frameRect=" + frameRect + " objRotation=" + objRotation + " rotated=" + rotated + 
					" x=" + x + " y=" + y + " width=" + width + " height=" + height + "]";
	}
}