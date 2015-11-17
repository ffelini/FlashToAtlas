package haxePort.managers.interfaces;

interface IPopUp
{
	function close(callHandler:Bool = true, openPrecedent:Bool = true, clearHistory:Bool = true):Void;
}
