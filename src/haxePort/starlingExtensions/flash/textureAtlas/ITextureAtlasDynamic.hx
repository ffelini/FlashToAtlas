package haxePort.starlingExtensions.flash.textureAtlas;

import flash.display.BitmapData;
import flash.geom.Rectangle;

interface ITextureAtlasDynamic
{
	var isDisposed(get, null):Bool;
	function get_isDisposed():Bool;
	
	var textureScale(get, set):Float;
	function get_textureScale():Float;
	function set_textureScale(value:Float):Float;
	var textureSource(get, null):Dynamic;
	function get_textureSource():Dynamic;
	
	var atlas(get, set):TextureAtlasAbstract;
	function get_atlas():TextureAtlasAbstract;
	function set_atlas(value:TextureAtlasAbstract):TextureAtlasAbstract;

	function setTexture(value:Dynamic):Void;
	function curentTexture():Dynamic;
	function addRegion(name:String, region:Rectangle, frame:Rectangle = null, rotated:Bool = false):Void;
	function getRegion(name:String):Rectangle;
	function getFrame(name:String):Rectangle;
	function getTextureObjByName(name:String):Dynamic;
	function getTexturesObj(prefix:String = '', result:Dynamic = null):Dynamic;
	function getExtrudedTexture(name:String, frame:Rectangle = null, region:Rectangle = null, extrusionFactor:Float = 100):Dynamic;
	function prepareForBitmapDataUpload(bmdWidth:Float, bmdHeight:Float):Void;
	function updateBitmapData(data:BitmapData):Void;
	function haxeUpdate(atlas:TextureAtlasAbstract, data:BitmapData):Void;
	function dispose():Void;	
}