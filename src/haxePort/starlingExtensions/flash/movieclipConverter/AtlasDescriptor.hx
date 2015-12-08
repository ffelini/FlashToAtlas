package haxePort.starlingExtensions.flash.movieclipConverter;

import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.flash.textureAtlas.SubtextureRegion;
import haxePort.starlingExtensions.flash.movieclipConverter.rectPackerAlgorithms.MaxRectPacker;
import haxePort.starlingExtensions.flash.movieclipConverter.rectPackerAlgorithms.RectanglePacker;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;

class AtlasDescriptor extends MaxRectPacker
{
	public var curentMaxWidth:Float = 4096;
	public var curentMaxHeight:Float = 4096;

	public var bestWidth:Float = 2048;
	public var bestHeight:Float = 2048;

	public var atlasAbstract:TextureAtlasAbstract = new TextureAtlasAbstract();
	public var originPoint:Point = new Point();

	public var atlasConfig:ObjectMap<Dynamic,Dynamic> = new ObjectMap<Dynamic,Dynamic>();

	public var subtextureTargets:Array<DisplayObject> = [];

	public static var isBaselineExtended:Bool = false;
	public static var savedAtlases:Int = 0;

	public function new() {
		super(isBaselineExtended ? curentMaxWidth : bestWidth, isBaselineExtended ? curentMaxHeight : bestHeight);
    }

	public override function init(width:Float, height:Float):Void {
		super.init(width, height);

		atlasConfig = new ObjectMap();

		atlasAbstract = new TextureAtlasAbstract();
		atlasAbstract.imagePath = savedAtlases + ".png";

		subtextureTargets = [];
	}


	public function next():AtlasDescriptor {
        var nextAtlasDescriptor:AtlasDescriptor = new AtlasDescriptor();
        nextAtlasDescriptor.atlasRegionsGap = atlasRegionsGap;
		nextAtlasDescriptor.smartSizeIncrease = smartSizeIncrease;
		nextAtlasDescriptor.smartSizeIncreaseFactor = smartSizeIncreaseFactor;
		nextAtlasDescriptor.placeInSmallestFreeRect = placeInSmallestFreeRect;
        return nextAtlasDescriptor;
    }
	public inline function quickRectInsert(objRect:Rectangle):Void
	{
		quickInsert(objRect.width, objRect.height);
	}

    /**
	 * atlas content scale factor fo fitting the atlas content
	 */
    @:isVar public var textureScale(get, set):Float;

    function set_textureScale(value:Float) {
        return atlas.textureScale = atlasAbstract.atlasRegionScale = value;
    }

    function get_textureScale():Float {
        return atlasAbstract.atlasRegionScale;
    }

	public function addSubtextureRegion(subTexture:SubtextureRegion):Void {
		atlasAbstract.add(subTexture);
		atlas.atlas = atlasAbstract;
		atlas.addRegion(subTexture.name, subTexture.regionRect, subTexture.frameRect);
	}

	@:isVar public var atlas(get, set):ITextureAtlasDynamic;
	function set_atlas(value:ITextureAtlasDynamic) {
		return this.atlas = value;
	}

	function get_atlas():ITextureAtlasDynamic {
		return atlas;
	}

	public function toString():String {
		return "\nxOffset - " + xOffset +
		" \nyOffset - " + yOffset +
		"\ntextureAtlasRect - " + textureAtlasRect+
		"\n-----------------------------------";
	}
}
