package haxePort.managers;

import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxePort.interfaces.IActivable;
import haxePort.interfaces.IDataInstance;
import haxePort.managers.interfaces.IResetable;
/**
 * ...
 * @author asd
 */
class ObjPool
{

	public inline static var DEBUG:Bool = false;
		
	public function new() 
	{
		
	}
	private static var _inst:ObjPool;
	public static var inst(get,set):ObjPool;
	static function get_inst():ObjPool
	{
		if(_inst!=null) return _inst;
		_inst = new ObjPool();
		return _inst;
	}
	static function set_inst(value:ObjPool):ObjPool
	{
		_inst = value;
		return _inst;
	}
	public inline function add(instance:Dynamic,key:Dynamic):Void
	{
		if(instance==null || key==null) return;
		
		var list:Array<Dynamic> = getPool(key);
		
		if(list.indexOf(instance)<0) 
		{
			list.push(instance);
			
			var iActivable:IActivable = Std.instance(instance, IActivable);
			if(iActivable!=null) iActivable.activate(false);
			
			var iResetable:IResetable = Std.instance(instance, IResetable);
			if(iResetable!=null) iResetable.reset();
		}
		
		if(DEBUG) trace(this,"add(inst, instClass)",key,instance,list !=null? list.length : 0);
	}
	public inline function addInstances(instances:Array<Dynamic>,key:Dynamic,clearSource:Bool=false):Void
	{
		if(instances==null || key==null) return;
		for (inst in instances)
		{
			var _instances:Array<Dynamic> = cast inst;
			if(_instances!=null) addInstances(_instances,key,clearSource);
			else add(inst,key);
		}
		if(clearSource)
		{
			try{
				while(instances.length>0) instances.shift();				
			}catch( msg : String ){}
		}
	}
	public inline function get(key:Dynamic,instantiate:Bool=true,parameters:Array<Dynamic>=null):Dynamic
	{
		if(key==null) return null;
		
		var list:Array<Dynamic> = getPool(key);
		var inst:Dynamic = list!=null ? list.pop() : null;
		var isFromPool:Bool = inst;
		
		try { 
		var _keyClass:Class<Dynamic> = cast key;
			if(!inst && instantiate && _keyClass!=null) inst = Type.createInstance(_keyClass,null); 
		}catch( msg : String ){}
		
		var iData:IDataInstance = Std.instance(inst, IDataInstance);
		if (iData != null)
		{
			var _f:Dynamic = Reflect.makeVarArgs(iData.setData);
			Reflect.callMethod(null, _f, parameters);
		}
		
		if(DEBUG) trace(this,"get(objClass, instantiate, parameters)",key,inst,"isFromPool-"+isFromPool,list!=null ? list.length : 0);
		
		return inst;
	}
	public var OBJ_POOLS:ObjectMap<String,Array<Dynamic>> = new ObjectMap<String,Array<Dynamic>>();
	public inline function getPool(key:Dynamic):Array<Dynamic>
	{
		var _keyClass:Class<Dynamic> = cast key;
		var id:String = _keyClass!=null ? Type.getClassName(_keyClass) : key+"";
		var list:Array<Dynamic> = OBJ_POOLS.get(id);
		if(list == null)
		{
			list = [];
			OBJ_POOLS.set(id,list);
		}
		return list;
	}
	public inline function clear(key:Dynamic):Void
	{
		var list:Array<Dynamic> = getPool(key);
		if (list != null) while (list.length > 0) list.shift();
	}
}