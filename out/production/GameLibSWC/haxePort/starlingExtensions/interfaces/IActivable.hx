package haxePort.starlingExtensions.interfaces;

interface IActivable
{
	var active(get, null):Bool;
	function get_active():Bool;
	function activate(value:Bool):Void;
}
