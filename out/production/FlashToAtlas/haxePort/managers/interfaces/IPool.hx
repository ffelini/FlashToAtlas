package haxePort.managers.interfaces;

interface IPool
{
	function getFromPool(objClass:Class<Dynamic>, instantiate:Bool = true):Dynamic;
	function addToPool(inst:Dynamic, irClass:Class<Dynamic>):Void;
	function clearPool():Void;
}