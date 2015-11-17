package haxePort.starlingExtensions.interfaces;

interface IPublicApiHolder
{
	var publicAPI(get, null):IPublicAPI;
	function get_publicAPI():IPublicAPI;
}
