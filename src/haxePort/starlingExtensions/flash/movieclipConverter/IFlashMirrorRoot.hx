package haxePort.starlingExtensions.flash.movieclipConverter;

import haxePort.starlingExtensions.flash.movieclipConverter.MirrorDescriptor;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.interfaces.IDisplayObjectContainer;

interface IFlashMirrorRoot extends IDisplayObjectContainer
{
	var quality(get, set):Float;
	function get_quality():Float;
	function set_quality(value:Float):Float;
	var descriptor(get, null):MirrorDescriptor;
	function get_descriptor():MirrorDescriptor;

	function onDescriptorReset(descriptor:AtlasDescriptor):Void;
	function storeAtlas(atlas:ITextureAtlasDynamic, bmd:BitmapData):Void;
	function getMirror(mirror:Dynamic):Dynamic;
	function getMirrorRect(_mirror:Dynamic):Rectangle;
	function registerMirror(instance:Dynamic, _mirror:DisplayObject):Void;
	function storeInstance(instance:Dynamic, _mirror:DisplayObject, mirrorRect:Rectangle = null):Void;
	function convertSprite(sprite:DisplayObjectContainer, spClass:Class<Dynamic>):IFlashSpriteMirror;
	function createChild(flashChild:DisplayObject):Void;
	function onCreateChildrenComplete():Void;

}