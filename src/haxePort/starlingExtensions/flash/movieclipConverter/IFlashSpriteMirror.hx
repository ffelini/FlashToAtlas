package haxePort.starlingExtensions.flash.movieclipConverter;
import haxePort.starlingExtensions.interfaces.IDisplayObjectContainer;

interface IFlashSpriteMirror extends IFlashMirror extends IDisplayObjectContainer
{
	function getMirrorChildAt(i:Int):Dynamic;
	function unflatten():Void;
}