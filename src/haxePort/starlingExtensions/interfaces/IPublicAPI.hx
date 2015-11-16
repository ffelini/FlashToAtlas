package haxePort.starlingExtensions.interfaces;

interface IPublicAPI
{
	function setApiValue(apiName:String, value:Dynamic):Bool;
	var holder(get, set):Dynamic;
	function set_holder(value:Dynamic):Dynamic;
	function get_holder():Dynamic;
	function getApi():Array<String>;
	function getValue(apiName:String):Dynamic;
	function getValues(apiName:String):Array<Dynamic>;
	function getDocumentation(apiName:String):String;
		
	function addApi(apiNamesStringValues:Array<Dynamic>):Void;
	function addApiValues(apiName:String, apiValues:Array<Dynamic>):Void;
	function addApiDocumentation(apiName:String, documentation:String):Void;
}
