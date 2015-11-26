package haxePort.starlingExtensions.flash.movieclipConverter;

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
	public static var INSTANCES:Array<AtlasDescriptor> = [];

	public var curentMaxWidth:Float = 4096;
	public var curentMaxHeight:Float = 4096;

	public var bestWidth:Float = 2048;
	public var bestHeight:Float = 2048;

	public var atlasAbstract:TextureAtlasAbstract = new TextureAtlasAbstract();
	public var atlasVerticalPoint:Point = new Point();
	public var atlasHorizontalPoint:Point = new Point();
	public var originPoint:Point = new Point();
	public var atlasRegionEnd:Point = new Point();
	public var maxY:Float = 0;
	public var maxX:Float = 0;
	public var minX:Float = 0;
	public var minY:Float = 0;

	public var atlasConfig:ObjectMap<Dynamic,Dynamic> = new ObjectMap<Dynamic,Dynamic>();

/**
	 * flag that controls which packing algorythm to use. MaxRectPacker is much optional because it will fill all gaps but 30% slower because uses recursion for economic regions fit.
	 */
	public var useMaxRectPackerAlgorythm:Bool = true;

	public var subtextureTargets:Array<DisplayObject> = [];

	public var inColumn:Bool = false;

	public static var isBaselineExtended:Bool = false;

    public function new() {
		super(isBaselineExtended ? curentMaxWidth : bestWidth, isBaselineExtended ? curentMaxHeight : bestHeight);

		INSTANCES.push(this);
    }

	public override function init(width:Float, height:Float):Void {
		super.init(width, height);

		atlasConfig = new ObjectMap();

		atlasAbstract = new TextureAtlasAbstract();
		atlasAbstract.imagePath = savedAtlases + ".png";

		subtextureTargets = [];

		inColumn = false;
		maxY = maxX = minX = minY = 0;
		regionPoint.x = regionPoint.y = atlasRegionEnd.x = atlasRegionEnd.y = atlasHorizontalPoint.x = atlasHorizontalPoint.y = atlasVerticalPoint.x = atlasVerticalPoint.y = 0;

	}


	public function next():AtlasDescriptor {
        var nextAtlasDescriptor:AtlasDescriptor = new AtlasDescriptor();
        nextAtlasDescriptor.atlasRegionsGap = atlasRegionsGap;
		nextAtlasDescriptor.useMaxRectPackerAlgorythm = useMaxRectPackerAlgorythm;
		nextAtlasDescriptor.smartSizeIncrease = smartSizeIncrease;
		nextAtlasDescriptor.smartSizeIncreaseFactor = smartSizeIncreaseFactor;
		nextAtlasDescriptor.placeInSmallestFreeRect = placeInSmallestFreeRect;
        return nextAtlasDescriptor;
    }

	public inline function updateMaxY(objRect:Rectangle):Void
	{
		updatePoints(objRect);
		// updating maxY position for next atlas regions row
		if (objRect.width + atlasRegionsGap > maxX) maxX = objRect.width + atlasRegionsGap;
		if (objRect.height + atlasRegionsGap > maxY) maxY = objRect.height + atlasRegionsGap;
	}
	public inline function updateAtlasPoint(objRect:Rectangle):Void
	{
		updatePoints(objRect);
		if(atlasRegionEnd.y < maxY || (inColumn && atlasRegionEnd.y < textureAtlasRect.height)) regionPoint.y += objRect.height + atlasRegionsGap;
		else regionPoint.x += objRect.width + atlasRegionsGap;
	}
	public inline function quickRectInsert(objRect:Rectangle):Void
	{
		if(useMaxRectPackerAlgorythm) {
			quickInsert(objRect.width, objRect.height);
			return;
		}
		// calulating next atlas region top left point
		while(regionPoint.x + objRect.width > curentMaxW && regionPoint.y + objRect.height>curentMaxH || objRect.height > curentMaxH || objRect.width>curentMaxW)
		{
			curentMaxW = curentMaxW*2<maximumWidth ? (curentMaxW*2+atlasRegionsGap) : maximumWidth;
			curentMaxH = curentMaxH*2<maximumHeight ? (curentMaxH*2+atlasRegionsGap) : maximumHeight;

			if(curentMaxW>=maximumWidth && curentMaxH>=maximumHeight) break;
		}
		if(!inColumn && regionPoint.x + objRect.width > textureAtlasRect.width)// && textureAtlasRect.width + objRect.width <= textureAtlasRect.height)
		{
			newColumn(objRect);
		}
		if(regionPoint.y + objRect.height > textureAtlasRect.height && textureAtlasRect.height + objRect.height <= textureAtlasRect.width)
		{
			newRow(objRect);
		}
		else if(regionPoint.x + objRect.width > textureAtlasRect.width && maxY < textureAtlasRect.height && !inColumn)
		{
			if(objRect.width + textureAtlasRect.width < curentMaxW) newColumn(objRect);
			else if(objRect.height + textureAtlasRect.height < curentMaxH) newRow(objRect);
		}
		else if(regionPoint.y + objRect.height > textureAtlasRect.height)
		{
			if(objRect.width + textureAtlasRect.width < curentMaxW) newColumn(objRect);
			else if(objRect.height + textureAtlasRect.height < curentMaxH) newRow(objRect);
		}

		updatePoints(objRect);

		// checking if a Main row or column is possible
		if (atlasRegionEnd.x - atlasRegionsGap > maximumWidth && atlasRegionEnd.y - atlasRegionsGap < maximumHeight)
		{
			newRow(objRect);
		}
		else if (atlasRegionEnd.y - atlasRegionsGap > maximumHeight && atlasRegionEnd.x - atlasRegionsGap < maximumWidth)
		{
			newColumn(objRect);
		}
		updatePoints(objRect);

		regionPoint.x += xOffset;
		regionPoint.y += yOffset;
	}
	private inline function newColumn(objRect:Rectangle):Void
	{
		atlasHorizontalPoint.x = regionPoint.x;
		atlasHorizontalPoint.y = regionPoint.y;

		regionPoint.x = xOffset + textureAtlasRect.width;
		regionPoint.y = maxY = 0;
		inColumn = true;

		updatePoints(objRect);
	}
	private inline function newRow(objRect:Rectangle):Void
	{
		atlasVerticalPoint.x = regionPoint.x;
		atlasVerticalPoint.y = regionPoint.y;

		regionPoint.x = maxX = 0;
		regionPoint.y = yOffset + textureAtlasRect.height;
		inColumn = false;

		updatePoints(objRect);
	}
	private inline function updatePoints(objRect:Rectangle):Void
	{
		atlasRegionEnd.x = regionPoint.x + objRect.width + atlasRegionsGap;
		atlasRegionEnd.y = regionPoint.y + objRect.height + atlasRegionsGap;

		if (atlasRegionEnd.x > textureAtlasRect.width) textureAtlasRect.width = atlasRegionEnd.x;
		if (atlasRegionEnd.y > textureAtlasRect.height) textureAtlasRect.height = atlasRegionEnd.y;
	}
	override public function get_isFull():Bool
	{
		if(useMaxRectPackerAlgorythm) return super.isFull;

		return atlasRegionEnd.x - atlasRegionsGap > maximumWidth || atlasRegionEnd.y - atlasRegionsGap > maximumHeight ||
					textureAtlasRect.width>=maximumWidth || textureAtlasRect.height>=maximumHeight;
	}

    /**
	 * atlas content scale factor fo fitting the atlas content
	 */
    @:isVar public var textureScale(get, set):Float;

    function set_textureScale(value:Float) {
        return atlasAbstract.atlasRegionScale = value;
    }

    function get_textureScale():Float {
        return atlasAbstract.atlasRegionScale;
    }
	public static var savedAtlases:Int = 0;
	public function clone():AtlasDescriptor
	{
		var c:AtlasDescriptor = new AtlasDescriptor();
		c.useMaxRectPackerAlgorythm = useMaxRectPackerAlgorythm;
		c.maxRect = maxRect.clone();

		c.atlasAbstract = atlasAbstract.clone();

		c.regionPoint = regionPoint.clone();
		c.atlasVerticalPoint = atlasVerticalPoint.clone();
		c.atlasHorizontalPoint = atlasHorizontalPoint.clone();
		c.originPoint = originPoint.clone();
		c.atlasRegionEnd = atlasRegionEnd.clone();
		c.maxY = maxY;
		c.maxX = maxX;
		c.minX = minX;
		c.minY = minY;
		c.curentMaxW = curentMaxW;
		c.curentMaxH = curentMaxH;
		c.atlasRegionsGap = atlasRegionsGap;
		c.textureAtlasRect = textureAtlasRect.clone();
		c.subtextureTargets = subtextureTargets.concat(null);
		c.inColumn = inColumn;

		return c;
	}

	public function toString():String {
		return "\nxOffset - " + xOffset +
		" \nyOffset - " + yOffset +
		"\ntextureAtlasRect - " + textureAtlasRect+
		"\n-----------------------------------";
	}
}
