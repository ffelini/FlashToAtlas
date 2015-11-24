package haxePort.starlingExtensions.flash.movieclipConverter;

import flash.display.DisplayObject;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxe.ds.Vector;
import haxePort.utils.LogStack;
import haxePort.utils.ObjUtil;

/**
 * This class is used to describe convertion of flash objects 
 * @author peak
 * 
 */	
class ConvertDescriptor
{
	public var map:ObjectMap<Dynamic,Dynamic> = new ObjectMap<Dynamic,Dynamic>();
	
	public static var CONVERT:String = "convert";
	public static var IGNORE_CONVERTING:String = "ignoreConverting";
	
	public var totalConvertDuration:Float;
	public var convertDuration:Float;
	public var createChildrenDuration:Float;
	public var drawAtlasToBmdDuration:Float;
	public var maxRectPackerAlgorithDuration:Float;
	
	public function getConvertionDurations():String
	{
		return "totalConvertDuration-"+totalConvertDuration+" "+
			"convertDuration-"+convertDuration+" "+
			"maxRectPackerAlgorithDuration-"+maxRectPackerAlgorithDuration+" "+
			"drawAtlasToBmdDuration-"+drawAtlasToBmdDuration+" "+
			"createChildrenDuration-"+createChildrenDuration+" ";
	}
	
	public function new()
	{
		
	}
	public inline function setInstanceState(inst:DisplayObject,state:String):Void
	{
		map.set(inst.name + "_state",state);
	}
	public inline function getInstanceState(inst:Dynamic):String
	{
		return map.get(inst.name + "_state");
	}
	public inline function addInstanceMirror(inst:DisplayObject,mirror:Dynamic):Void
	{
		map.set(inst,mirror);
	}
	public inline function getInstanceMirror(inst:DisplayObject):Dynamic
	{
		return map.get(inst);
	}
	public inline function getInstanceMirrorClass(inst:Dynamic):Class<Dynamic>
	{
		return map.exists(inst) ? map.get(inst) : map.get(Type.getClassName(Type.getClass(inst)));
	}
	/**
	 * associates a flash instance with a starling class for convertion 
	 * @param inst - flash instance
	 * @param mirrorClass - starling mirror class
	 * 
	 */		
	public inline function addInstanceMirrorClass(inst:DisplayObject,mirrorClass:Class<Dynamic>):Void
	{
		map.set(inst,mirrorClass);
	}
	/**
	 * 
	 * @param inst - flash class instance
	 * @param mirrorClass - starling mirror class
	 * 
	 */		
	public inline function associateClasses(inst:Dynamic,mirrorClass:Class<Dynamic>):Void
	{
		var instClassName:String = Std.is(inst,DisplayObject) || Std.is(inst,Class) ? Type.getClassName(inst) : inst+"";
		var mirrorClassName:String = Type.getClassName(mirrorClass);
		
		map.set(instClassName,mirrorClass); 
		map.set(mirrorClassName,inst); 
	}
	/**
	 * Ignore instances in the flash mirror hierarchy shoul be placed on top of everything 
	 * @param mirrorClass
	 * 
	 */		
	public inline function ignoreClass(mirrorClass:Dynamic):Void
	{
		var _class:Class<Dynamic> = Std.is(mirrorClass,Class) ? mirrorClass : Type.getClass(mirrorClass);
		var className:String = _class==String ? mirrorClass+"" : Type.getClassName(_class);
		map.set("ignore_"+className,_class);
	}
	/**
	 * Ignore instances in the flash mirror hierarchy shoul be placed on top of everything 
	 * @param mirrorClass
	 * 
	 */	
	public inline function ignore(mirrorClass:Dynamic):Bool
	{
		var _class:Class<Dynamic> = Type.getClass(mirrorClass);
		return map.exists("ignore_"+Type.getClassName(_class));
	}
	public inline function updatePoolClasses(add:Bool,classes:Array<Dynamic>):Void
	{
		var pool:Array<Class<Dynamic>> = map.get("poolClasses");
		if(pool==null)
		{
			pool = new Array<Class<Dynamic>>();
			map.set("poolClasses",pool);
		}
		var i:Int;
		for(cl in classes)
		{
			i = pool.indexOf(cl);
			
			if(add) if(i<0) pool.push(cl);
			else if(i>=0) pool.splice(i,1);
		}
	}
	public inline function getPoolClasses():Vector<Class<Dynamic>>
	{
		return map.exists("poolClasses") ? Vector.fromArrayCopy(map.get("poolClasses")) : null;
	}
	public function getObjClassToConvert(obj:DisplayObject):Class<Dynamic>
	{
		var cl:Class<Dynamic> = getInstanceMirrorClass(obj);
		
		return cl;
	}
	public inline function storeInstance(inst:Dynamic,key:Dynamic):Void
	{
		map.set(key,inst);
	}
	public inline function getInstance(key:Dynamic):Dynamic
	{
		return map.get(key);
	}
}