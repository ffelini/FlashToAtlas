package haxePort.utils;
import flash.utils.Function;
import haxePort.managers.Handlers;

/**
 * ...
 * @author val
 */
class XMLUtils
{

	public function new() 
	{
		
	}
	public inline static function getChildren(xml:Xml):Iterator<Xml>
	{
		return xml.elements();
	}
	public static function iterateChidren(xml:Xml, childFunc:Function,parameters:Array<Dynamic>):Void
	{
		parameters.unshift(null);
		for (child in xml.elements())
		{
			parameters[0] = child;
			Handlers.functionCall(childFunc, parameters);
		}
	}
}