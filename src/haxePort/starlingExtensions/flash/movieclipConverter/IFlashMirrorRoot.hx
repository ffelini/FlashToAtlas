package haxePort.starlingExtensions.flash.movieclipConverter;

import flash.text.TextField;
import flash.display.MovieClip;
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
	function convertSprite(sprite:DisplayObjectContainer, spClass:Class<Dynamic>):IFlashSpriteMirror;
	function createChild(flashChild:DisplayObject, childClass:Class<Dynamic>):Void;
	function createButton(flashButton:MovieClip, childClass:Class<Dynamic>):Void;
	function createTextField(flashTextField:TextField, childClass:Class<Dynamic>):Void;
	function createImage(flashImage:DisplayObject, childClass:Class<Dynamic>):Void;
	function createQuad(flashImage:DisplayObject, childClass:Class<Dynamic>, color:UInt, quadAlpha:Float):Void;
	function createMovieClip(flashMovieClip:MovieClip, childClass:Class<Dynamic>):Void;
	function createScale3Image(flashImage:DisplayObject, childClass:Class<Dynamic>, direction:String):Void;
	function createScale9Image(flashImage:DisplayObject, childClass:Class<Dynamic>):Void;
	function onChildrenCreationComplete():Void;
}