package test;

import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;

import flash.display.BitmapData;
import flash.geom.Rectangle;
/**
 * ...
 * @author val
 */
class TextureAtlasDynamic implements ITextureAtlasDynamic
{

	public function new() 
	{
		
	}
	
	public var isDisposed(get, null):Bool;
	public function get_isDisposed():Bool
	{
		return false;
	}
	private var _textureScale:Float;
	public var textureScale(get, set):Float;
	public function get_textureScale():Float
	{
		return _textureScale;
	}
	public function set_textureScale(value:Float):Float
	{
		_textureScale = value;
		return _textureScale;
	}
	private var _textureSource:Dynamic;
	public var textureSource(get, null):Dynamic;
	public function get_textureSource():Dynamic
	{
		return _textureSource;
	}
	public function addRegion(name:String, region:Rectangle, frame:Rectangle = null, rotated:Bool = false):Void
	{
		
	}
	public function getRegion(name:String):Rectangle
	{
		return null;
	}
	public function getFrame(name:String):Rectangle
	{
		return null;
	}
	public function getTextureObjByName(name:String):Dynamic
	{
		return null;
	}
	public function getTexturesObj(prefix:String = '', result:Dynamic = null):Dynamic
	{
		return null;
	}
	public function getExtrudedTexture(name:String, frame:Rectangle = null, region:Rectangle = null, extrusionFactor:Float = 100):Dynamic
	{
		return null;
	}
	public function prepareForBitmapDataUpload(bmdWidth:Float, bmdHeight:Float):Void
	{
		
	}
	public function updateBitmapData(data:BitmapData):Void
	{
		
	}
	public function haxeUpdate(atlasXML:TextureAtlasAbstract, data:BitmapData):Void
	{
		
	}
	public function dispose():Void
	{
		
	}
	public function setTexture(value:Dynamic):Void
	{
		
	}
	
	public var atlas(get, set):TextureAtlasAbstract;
	public function get_atlas():TextureAtlasAbstract {
		return null;
	}
	public function set_atlas(value:TextureAtlasAbstract):TextureAtlasAbstract {
		return null;
	}
	public function curentTexture():Dynamic
	{
		return null;
	}
}