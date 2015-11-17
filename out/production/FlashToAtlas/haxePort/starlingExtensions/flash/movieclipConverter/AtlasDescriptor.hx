package haxePort.starlingExtensions.flash.movieclipConverter;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;

class AtlasDescriptor extends MaxRectPacker
{
	public var maxWidth:Float = 4096;
	public var maxHeight:Float = 4096;

	public var bestWidth:Float = 2048;
	public var bestHeight:Float = 2048;

	public var MAX_RECT:Rectangle;
	public var atlasAbstract:TextureAtlasAbstract;
	public var atlasVerticalPoint:Point = new Point();
	public var atlasHorizontalPoint:Point = new Point();
	public var originPoint:Point = new Point();
	public var atlasRegionEnd:Point = new Point();
	public var maxY:Float = 0;
	public var maxX:Float = 0;
	public var minX:Float = 0;
	public var minY:Float = 0;
	public var maxW:Float;
	public var maxH:Float;

	/**
	 * flag that controls which packing algorythm to use. MaxRectPacker is much optional because it will fill all gaps but 30% slower because uses recursion for economic regions fit.
	 */
	public var useMaxRectPackerAlgorythm:Bool = true;

	public var subtextureTargets:Array<DisplayObject> = new Array<DisplayObject>();

	public var inColumn:Bool = false;

	public static var isBaselineExtended:Bool;

    public function new(xOffset:Float = 0, yOffset:Float = 0) {
        super(xOffset, yOffset, bestWidth, bestHeight);

        MAX_RECT = new Rectangle(0, 0, bestWidth, bestHeight);
        maxW = MAX_RECT.width / 8;
        maxH = MAX_RECT.height / 8;
        reset();
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
		// calulating next atlas region top left point
		while(regionPoint.x + objRect.width > maxW && regionPoint.y + objRect.height>maxH || objRect.height > maxH || objRect.width>maxW)
		{
			maxW = maxW*2<MAX_RECT.width ? (maxW*2+atlasRegionsGap) : MAX_RECT.width;
			maxH = maxH*2<MAX_RECT.height ? (maxH*2+atlasRegionsGap) : MAX_RECT.height;

			if(maxW>=MAX_RECT.width && maxH>=MAX_RECT.height) break;
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
			if(objRect.width + textureAtlasRect.width < maxW) newColumn(objRect);
			else if(objRect.height + textureAtlasRect.height < maxH) newRow(objRect);
		}
		else if(regionPoint.y + objRect.height > textureAtlasRect.height)
		{
			if(objRect.width + textureAtlasRect.width < maxW) newColumn(objRect);
			else if(objRect.height + textureAtlasRect.height < maxH) newRow(objRect);
		}

		updatePoints(objRect);

		// checking if a new row or column is possible
		if (atlasRegionEnd.x - atlasRegionsGap > MAX_RECT.width && atlasRegionEnd.y - atlasRegionsGap < MAX_RECT.height)
		{
			newRow(objRect);
		}
		else if (atlasRegionEnd.y - atlasRegionsGap > MAX_RECT.height && atlasRegionEnd.x - atlasRegionsGap < MAX_RECT.width)
		{
			newColumn(objRect);
		}
		updatePoints(objRect);
	}
	private inline function newColumn(objRect:Rectangle):Void
	{
		atlasHorizontalPoint.x = regionPoint.x;
		atlasHorizontalPoint.y = regionPoint.y;

		regionPoint.x = textureAtlasRect.width;
		regionPoint.y = maxY = 0;
		inColumn = true;

		updatePoints(objRect);
	}
	private inline function newRow(objRect:Rectangle):Void
	{
		atlasVerticalPoint.x = regionPoint.x;
		atlasVerticalPoint.y = regionPoint.y;

		regionPoint.x = maxX = 0;
		regionPoint.y = textureAtlasRect.height;
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

		return atlasRegionEnd.x - atlasRegionsGap > MAX_RECT.width || atlasRegionEnd.y - atlasRegionsGap > MAX_RECT.height ||
					textureAtlasRect.width>=MAX_RECT.width || textureAtlasRect.height>=MAX_RECT.height;
	}
	public var atlasConfig:ObjectMap<Dynamic,Dynamic>;
	public static var savedAtlases:Int = 0;
	public inline function reset():Void
	{
		atlasConfig = new ObjectMap();

		atlasAbstract = new TextureAtlasAbstract();
		atlasAbstract.imagePath = savedAtlases + ".png";

		subtextureTargets.splice(0, subtextureTargets.length);

		inColumn = false;
		maxY = maxX = minX = minY = 0;
		regionPoint.x = regionPoint.y = atlasRegionEnd.x = atlasRegionEnd.y = atlasHorizontalPoint.x = atlasHorizontalPoint.y = atlasVerticalPoint.x = atlasVerticalPoint.y = 0;

		MAX_RECT.width = isBaselineExtended ? maxWidth : bestWidth;
		MAX_RECT.height = isBaselineExtended ? maxHeight : bestHeight;

		maxW = MAX_RECT.width/8;
		maxH = MAX_RECT.height/8;

		init(xOffset, yOffset, MAX_RECT.width,MAX_RECT.height);
	}
	public function clone():AtlasDescriptor
	{
		var c:AtlasDescriptor = new AtlasDescriptor();
		c.useMaxRectPackerAlgorythm = useMaxRectPackerAlgorythm;
		c.MAX_RECT = MAX_RECT.clone();

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
		c.maxW = maxW;
		c.maxH = maxH;
		c.atlasRegionsGap = atlasRegionsGap;
		c.textureAtlasRect = textureAtlasRect.clone();
		c.subtextureTargets = subtextureTargets.concat(null);
		c.inColumn = inColumn;

		return c;
	}
}
