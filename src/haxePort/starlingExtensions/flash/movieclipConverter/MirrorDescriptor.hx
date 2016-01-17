package haxePort.starlingExtensions.flash.movieclipConverter;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxe.ds.Vector;
import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.flash.textureAtlas.SubtextureRegion;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;

class MirrorDescriptor
{
	public var key:Dynamic;
	public var mirrorRect:Rectangle;
	
	public var atlasesConf:ObjectMap<Dynamic,Dynamic>;
	public var subtexturesMap:ObjectMap < Dynamic, Vector<SubtextureRegion>>;
	public var textureAtlases:Array<ITextureAtlasDynamic>;
	
	public var mirrorsCreationStack:Array<DisplayObject>;
	private var flashMirrors:Array<DisplayObject>;
	
	public var mirrorRects:ObjectMap<Dynamic,Dynamic>;
	
	public function new()
	{
		atlasesConf = new ObjectMap();
		subtexturesMap = new ObjectMap();
		textureAtlases = new Array<ITextureAtlasDynamic>();
		mirrorsCreationStack = new Array<DisplayObject>();
		flashMirrors = new Array<DisplayObject>();
		mirrorRects = new ObjectMap();
	}
	public inline function includeInState(mirror:DisplayObject):Void
	{
		if(flashMirrors.indexOf(mirror)<0) flashMirrors.push(mirror);
	}
	public inline function excludeFromState(mirror:DisplayObject):Void
	{
		var i:Int = flashMirrors.indexOf(mirror);
		if(i>0) flashMirrors.splice(i,1);
	}
	public inline function clear():Void
	{
		for(mirror in flashMirrors)
		{
			if(mirror.parent!=null) mirror.parent.removeChild(mirror);
		}
	}
	public inline function getConf(key:Dynamic):Dynamic
	{
		return atlasesConf.get(key);
	}
	public inline function setConf(key:Dynamic,value:Dynamic):Void
	{
		atlasesConf.set(key, value);
	}
	public inline function storeMirrorRect(mirror:DisplayObject, rect:Rectangle):Void
	{
		mirrorRects.set(mirror,rect);
	}
	public inline function addSubtextures(mirror:DisplayObject, rect:Rectangle, _symbolName:String, subTextures:Vector<SubtextureRegion>):Void
	{
		storeMirrorRect(mirror,rect);
		if (mirrorsCreationStack.indexOf(mirror) < 0) mirrorsCreationStack.push(mirror);
		
		subtexturesMap.set(mirror,subTextures);
		subtexturesMap.set(_symbolName,subTextures); 
	}
	public inline function getSubtextures(mirror:DisplayObject):Vector<SubtextureRegion>
	{
		return subtexturesMap.get(mirror);
	}
	public inline function getSubtexturesBySymbolName(symbolName:String):Vector<SubtextureRegion>
	{
		return subtexturesMap.get(symbolName);
	}
	public inline function addSubtexture(mirror:DisplayObject, rect:Rectangle, subTexture:SubtextureRegion):Void
	{
		storeMirrorRect(mirror,rect);
		if (mirrorsCreationStack.indexOf(mirror) < 0) mirrorsCreationStack.push(mirror);
		
		if(subTexture==null) return; 
		
		var _subtextureName:String = subTexture.name;
		var _symbolName:String = subTexture.symbolName;
		
		atlasesConf.set(mirror,subTexture);
		atlasesConf.set(_symbolName,subTexture); 
		
		// storing subtexture childs and parent atlas objects. Linking together
		if(!atlasesConf.exists(_subtextureName+"_|_"+_symbolName)) atlasesConf.set(_subtextureName+"_|_"+_symbolName, subTexture); 
	}
	public inline function getSubtexture(mirror:DisplayObject):SubtextureRegion {
		return atlasesConf.get(mirror);
	}
	public inline function getSubtextureByName(name:String, symbolName:String):SubtextureRegion
	{
		return atlasesConf.get(name+"_|_"+symbolName);
	}
	public inline function storeAtlas(atlas:ITextureAtlasDynamic, atlasAbstract:TextureAtlasAbstract):Void
	{
		if(!atlasesConf.exists(atlas))
		{
			if(textureAtlases.indexOf(atlas)<0) textureAtlases.push(atlas);
			atlasesConf.set(atlas,atlasAbstract);
			atlasesConf.set(atlasAbstract,atlas);
		}
	}
	public inline function getAtlas(subtextureName:String,subtextureSymbolName:String):ITextureAtlasDynamic
	{
		return atlasesConf.get(atlasesConf.get(subtextureName));
	}
	public inline function clearMirrorState():Void
	{
		mirrorsCreationStack.splice(0, mirrorsCreationStack.length);
	}
}