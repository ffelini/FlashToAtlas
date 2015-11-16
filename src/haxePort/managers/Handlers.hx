package haxePort.managers;

import haxe.ds.ObjectMap;
/**
 * ...
 * @author asd
 */
class Handlers
{

	private static var handlersByKey:ObjectMap<Dynamic,Dynamic> = new ObjectMap<Dynamic,Dynamic>();
	private static var singleCallHandlers:ObjectMap<Dynamic,Dynamic> = new ObjectMap<Dynamic,Dynamic>();
	private static var parametersByHandler:ObjectMap<Dynamic,Array<Dynamic>> = new ObjectMap<Dynamic,Array<Dynamic>>();
		
	public function new() 
	{

	}
	public inline static function add(key:Dynamic,singleCall:Bool,handler:Dynamic,parameters:Array<Dynamic>):Void
	{
		if(!key || handler==null) return;
		
		var handlers:Array<Dynamic> = getHandlers(key);
		if(handlers.indexOf(handler)<0) handlers.push(handler);
		if(singleCall) singleCallHandlers.set(handler,handler);
		
		if(parameters !=null && parameters.length>0) parametersByHandler.set(handler,parameters);
	}
	public inline static function remove(key:Dynamic,handler:Dynamic):Void
	{
		if(!key || handler==null) return;
		
		var handlers:Array<Dynamic> = getHandlers(key);
		var i:Int = handlers != null ? handlers.indexOf(handler) : -1;
		if(i>=0) handlers.splice(i,1);
	}
	public inline static function removeByKey(key:Dynamic):Void
	{
		if(!key) return;
		
		var handlers:Array<Dynamic> = getHandlers(key);
		for(func in handlers)
		{
			if(singleCallHandlers.exists(func))
			{
				singleCallHandlers.remove(func);
				parametersByHandler.remove(func);
			}
		}
		if (handlers != null) while (handlers.length > 0) handlers.shift();
	}
	private inline static function getHandlers(key:Dynamic):Array<Dynamic>
	{
		var handlers:Array<Dynamic> = handlersByKey.get(key);
		if(handlers != null) return handlers;
		
		handlers = new Array<Dynamic>();
		handlersByKey.set(key,handlers);
		return handlers;
	}
	public inline static function call(key:Dynamic,parameters:Array<Dynamic>):Void
	{
		var handlers:Array<Dynamic> = getHandlers(key);
		var numHandlers:Int = handlers.length;
		var func:Dynamic;
		for(i in -numHandlers...0)
		{
			func = handlers[-i];
			
			var functionCallParams:Array<Dynamic> = parametersByHandler.exists(func) ? parametersByHandler.get(func) : parameters;
			
			Reflect.callMethod(null,func,functionCallParams);
			
			if(parametersByHandler.exists(func))
			{
				singleCallHandlers.remove(func);
				parametersByHandler.remove(func);
				handlers.splice(-i,1);
			}
		}
	}
	public inline static function functionCall(func:Dynamic,parameters:Array<Dynamic>):Dynamic
	{
		if(func==null) return null;
		var result:Dynamic;
		
		try 
		{
			result = Reflect.callMethod(null,func,parameters);
		}
		catch ( msg : String ) 
		{
			var f:Dynamic = Reflect.makeVarArgs(func);
			
			result = Reflect.callMethod(null,f,parameters);			
		}
		return result;
	}
	
}