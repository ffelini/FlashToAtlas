package test;
import haxePort.starlingExtensions.flash.movieclipConverter.FlashDisplay_Converter;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashMirrorRoot;
import flash.geom.Rectangle;
import flash.display.*;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashSpriteMirror;
import haxePort.starlingExtensions.flash.movieclipConverter.Mirror_State;
import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import flash.Lib;
/**
 * ...
 * @author val
 */
class FlashMirrorRoot implements IFlashMirrorRoot
{

	public function new() 
	{
		
	}
	
	public var quality(get, set):Float;
	public function get_quality():Float
	{
		return 1.0;
	}
	public function set_quality(value:Float):Float
	{
		return 1.0;
	}
	private var _state:Mirror_State;
	public var state(get, null):Mirror_State;
	public function get_state():Mirror_State
	{
		if (_state==null) _state = new Mirror_State();
		return _state;
	}
		
	public function storeAtlas(atlas:ITextureAtlasDynamic, bmd:BitmapData):Void
	{
		var bmp:Bitmap = new Bitmap(bmd);
		Lib.current.stage.addChild(bmp);
	}
	public function getMirror(mirror:Dynamic):Dynamic
	{
		return null;
	}
	public function getMirrorRect(_mirror:Dynamic):Rectangle
	{
		return null;
	}
	public function registerMirror(instance:Dynamic, _mirror:DisplayObject):Void
	{
		
	}
	public function storeInstance(instance:Dynamic, _mirror:DisplayObject, mirrorRect:Rectangle = null):Void
	{
		
	}
	public function convertSprite(sprite:DisplayObjectContainer, spClass:Class<Dynamic>):IFlashSpriteMirror
	{
		return new FlashSpriteMirror();
	}
	public function createChildren():Void
	{
		
	}
	public function onCreateChildrenComplete():Void
	{
		
	}
	public function isEconomicButton(obj:DisplayObject):Bool
	{
		return FlashDisplay_Converter.isButton(Std.instance(obj,MovieClip));
	}
	public function adChildAt(child:Dynamic, index:Int):Void
	{
		
	}
	public function adChild(child:Dynamic):Void
	{
		
	}
	public function getChildAtIndex(index:Int):Dynamic
	{
		return null;
	}
	public function numChildrens():Int
	{
		return 0;
	}
}