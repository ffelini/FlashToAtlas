package haxePort.starlingExtensions.flash.textureAtlas;

import flash.geom.Rectangle;
import flash.display.DisplayObject;
/**
 * ...
 * @author val
 */
class SubtextureRegion extends Rectangle
{
	public var name:String;
	public var symbolName:String;
	public var frameLabel:String;
	
	public var object:DisplayObject;
	
	public var frame:Int;
	public var pivotX:Float;
	public var pivotY:Float;
	
	public var regionRect:Rectangle;
	public var frameRect:Rectangle;
	
	public var rotated:Bool;
	
	public var parent:TextureAtlasAbstract;
	
	public function new() 
	{
		super();
	}
	
}