package haxePort.utils;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display3D.textures.Texture;
import flash.events.Event;
import flash.system.System;
import flash.sampler.Api;
import haxe.Timer;

class ObjUtil
{
	public function ObjUtil()
	{
		
	}
	public static function getObjSize(obj:Dynamic):Float
	{
		var num:Float = Api.getSize(obj) / 1024 / 1024;
		obj = null;
		return num;
	}
	public inline static function dispose(obj:Dynamic,forceGC:Bool=false,debug:Bool=false):Void
	{
		if(debug) trace("ObjUtil.dispose before",obj,getObjSize(obj));
		
		if(Reflect.hasField(obj,"dispose") && Reflect.isFunction(Reflect.field(obj,"dispose"))) Reflect.callMethod(obj,Reflect.field(obj,"dispose"),null);
		else if(Std.is(obj,BitmapData)) Std.instance(obj,BitmapData).dispose();
		else if(Std.is(obj,Bitmap) && Reflect.field(obj,"bitmapData")!=null) 
		{
			Std.instance(obj,Bitmap).bitmapData.dispose();
			Std.instance(obj,Bitmap).bitmapData = null;
		}
		else if(Std.is(obj,Shape)) Std.instance(obj,Shape).graphics.clear();
		
		if (debug) 
		{
			Timer.delay(function():Void { trace("ObjUtil.dispose after", obj, getObjSize(obj)); }, 5000);
		}
		else obj = null;
		
		if(forceGC) startGCCycle();
	}
	private static var gcCount:Int;
	private inline static function startGCCycle():Void
	{
		System.pauseForGCIfCollectionImminent();
		/*try {
			new LocalConnection().connect('foo');
			new LocalConnection().connect('foo');
		} catch (e:*) {}*/
		gcCount = 0;
		//if(stage) stage.addEventListener(Event.ENTER_FRAME, doGC);
	}
	private static function doGC(evt:Event):Void
	{
		flash.system.System.gc();
		if(++gcCount > 1)
		{
			evt.target.removeEventListener(Event.ENTER_FRAME, doGC);
			Timer.delay(lastGC, 40);
		}
		trace("ObjUtil.doGC(evt)");
	}
	private inline static function lastGC():Void
	{
		flash.system.System.gc();
	}
	public inline static function toString(obj:Dynamic):String
	{
		if(!obj) return "null";
		
		var s:String = obj + "\n";
		var objFields:Array<String> = Reflect.fields(obj);
		var field:Dynamic;
		
		for(p in objFields)
		{
			field = Reflect.field(obj, p);
			if(field!=null && Std.is(field,Dynamic)==false) s += '$field';
			else s += "\n" + p +" - " + field;
		}
		return s;
	}
	public inline static function cloneInstance(inst:Dynamic):Dynamic
	{
		try{
			var c:Class<Dynamic> = getClass(inst);
			return Type.createEmptyInstance(c);
		}
		catch(msg:String){}
		
		return null;
	}
	public inline static function getClass(inst:Dynamic):Class<Dynamic>
	{
		return Type.getClass(inst);
	}
	public inline static function getClassName(inst:Dynamic):String
	{
		return Type.getClassName(getClass(inst));
	}
	public inline static function cloneFields(from:Dynamic,to:Dynamic,properties:Array<String>):Dynamic
	{
		return cloneFieldsList(from,to,properties);
	}
	public inline static function cloneFieldsList(from:Dynamic,to:Dynamic,properties:Array<String>):Dynamic
	{
		if(!from || !to) return to;
		
		properties = properties == null || properties.length == 0 ? Reflect.fields(from) : properties;
		
		for(p in properties)
		{
			var value:Dynamic = Reflect.hasField(from,p) ? Reflect.field(from, p) : null;
			var valueStr:String = Std.string(value);
			try{
				Reflect.setField(to,p,value);
			}
			catch(msg:String){
				try{
					if(to.hasOwnProperty(p))
					{	
						if(!Std.is(to,Xml) && Std.is(from,Xml)) 
						{
							if(valueStr=="false") Reflect.setField(to,p,false);
							else if(valueStr=="true") Reflect.setField(to,p,true);
							else
							{	
								try{ Reflect.setField(to,p,valueStr);}
								catch (msg:String)
								{
									try{ Reflect.setField(to,p,cast(valueStr,UInt));}
									catch (msg:String)
									{
										
										try{ Reflect.setField(to,p,Std.parseFloat(valueStr));}
										catch(msg:String){
											
										}
									}
								}
							}
						}
						else if (Std.is(to, Xml))
						{
							Std.instance(to, Xml).set(p,valueStr);
						}
					}
				}catch(msg:String){}
			}
		}
		return to;
	}
	/**
	 * Is registering in to and class instance and instance as a public property
	 * @param to class object that sould have the isntance.name property to register
	 * @param instance
	 * @return 
	 * 
	 */		
	public inline static function registerInstance(to:Dynamic,instance:Dynamic):Bool
	{
		try{
			if(to.hasOwnProperty(instance.name)) to[instance.name] = instance;
			return true;
		}catch(msg:String){};
		return false;
	}
	public inline static function isExtensionOf(instance:Dynamic,extendsClass:Class<Dynamic>):Bool
	{
		return Type.getSuperClass(instance) == extendsClass;
	}
}