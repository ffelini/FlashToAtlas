package haxePort.utils;
import haxe.ds.ObjectMap;
import flash.Lib;

class LogStack
{
	public static var DEBUG:Bool = true;
	
	public function new()
	{
	}
	public static var stack:String = "";
	private static var index:Int = 0;
	private static var line:String;
	public static var lines:Array<String> = [];
	public inline static function addLog(instance:Dynamic,message:String,params:Array<Dynamic>=null):Dynamic
	{
		if (stackByInstance == null) stackByInstance = new ObjectMap<Dynamic,String>();
		index++;

		line = "\n" + index + ". " + instance + ": " + message + " - " + params;
		lines.push(line);
		if(DEBUG) Lib.trace(line);
		
		if(instance!=null)
		{
			if(stackByInstance.exists(instance)) stackByInstance.set(instance,stackByInstance.get(instance) + line + "\n");
			else stackByInstance.set(instance,line);
		}
		stack += line + "\n";
		
		return line;
	}
	private static var stackByInstance:ObjectMap<Dynamic,String>;
	public static function getLogsByInstance(inst:Dynamic):String
	{
		return stackByInstance.get(inst);
	}
	public static function getLogs():String
	{
		return stack;
	}
	public static function clearLog():Void
	{
		index = 0;
		lines.splice(0, lines.length);
		stack = "";
	}
}