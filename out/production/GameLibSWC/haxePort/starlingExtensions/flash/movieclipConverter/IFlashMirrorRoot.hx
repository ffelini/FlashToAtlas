package haxePort.starlingExtensions.flash.movieclipConverter;

import haxe.ds.ObjectMap;
import haxePort.starlingExtensions.flash.movieclipConverter.Mirror_State;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.interfaces.IDisplayObjectContainer;

import haxePort.starlingExtensions.interfaces.ISmartDisplayObject;

interface IFlashMirrorRoot extends IDisplayObjectContainer
{
	var quality(get, set):Float;
	function get_quality():Float;
	function set_quality(value:Float):Float;
	var state(get, null):Mirror_State;
	function get_state():Mirror_State;
		
	function storeAtlas(atlas:ITextureAtlasDynamic, bmd:BitmapData):Void;
	function getMirror(mirror:Dynamic):Dynamic;
	function getMirrorRect(_mirror:Dynamic):Rectangle;
	function registerMirror(instance:Dynamic, _mirror:DisplayObject):Void;
	function storeInstance(instance:Dynamic, _mirror:DisplayObject, mirrorRect:Rectangle = null):Void;
	function convertSprite(sprite:DisplayObjectContainer, spClass:Class<Dynamic>):IFlashSpriteMirror;
	function createChildren():Void;
	function onCreateChildrenComplete():Void;
}