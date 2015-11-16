package haxePort.starlingExtensions.flash.movieclipConverter;
import haxePort.starlingExtensions.interfaces.IDisplayObjectContainer;

interface IFlashMirror
{
	function createChildren():Void;
	function validateChildrenCreation():Void;
	var created(get, null):Bool;
	function get_created():Bool;
}
