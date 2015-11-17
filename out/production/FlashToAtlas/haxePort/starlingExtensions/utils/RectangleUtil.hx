// =====starlingExtensions.utils====haxePort.starlingExtensions================================================================
//
//	Starling Framework
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package haxePort.starlingExtensions.utils;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxePort.starlingExtensions.interfaces.ISmartDisplayObject;

/** A utility class containing methods related to the Rectangle class. */
class RectangleUtil
{
	/** Helper objects. */
	static var sHelperPoint:Point = new Point();
	static var sPositions:Array<Point> = [ new Point(0, 0), new Point(1, 0), new Point(0, 1), new Point(1, 1) ];

	/** @private */
	public function new() { }
	
	/** Calculates the intersection between two Rectangles. If the rectangles do not intersect,
	 *  this method returns an empty Rectangle object with its properties set to 0. */
	public inline static function intersect(rect1:Rectangle, rect2:Rectangle, 
									 resultRect:Rectangle=null):Rectangle
	{
		if (resultRect == null) resultRect = new Rectangle();
		
		var left:Float   = rect1.x      > rect2.x      ? rect1.x      : rect2.x;
		var right:Float  = rect1.right  < rect2.right  ? rect1.right  : rect2.right;
		var top:Float    = rect1.y      > rect2.y      ? rect1.y      : rect2.y;
		var bottom:Float = rect1.bottom < rect2.bottom ? rect1.bottom : rect2.bottom;
		
		if (left > right || top > bottom)
			resultRect.setEmpty();
		else
			resultRect.setTo(left, top, right-left, bottom-top);
		
		return resultRect;
	}
	
	/** Calculates a rectangle with the same aspect ratio as the given 'rectangle',
	 *  centered within 'into'.  
	 * 
	 *  <p>This method is useful for calculating the optimal viewPort for a certain display 
	 *  size. You can use different scale modes to specify how the result should be calculated;
	 *  furthermore, you can avoid pixel alignment errors by only allowing whole-number  
	 *  multipliers/divisors (e.g. 3, 2, 1, 1/2, 1/3).</p>
	 *  
	 *  @see starling.utils.ScaleMode
	 */
	public inline static function fit(rectangle:Rectangle, into:Rectangle, 
							   scaleMode:String="showAll", pixelPerfect:Bool=false,
							   resultRect:Rectangle=null):Rectangle
	{
		if (!ScaleMode.isValid(scaleMode)) return null;
		if (resultRect == null) resultRect = new Rectangle();
		
		var width:Float   = rectangle.width;
		var height:Float  = rectangle.height;
		var factorX:Float = into.width  / width;
		var factorY:Float = into.height / height;
		var factor:Float  = 1.0;
		
		if (scaleMode == ScaleMode.SHOW_ALL)
		{
			factor = factorX < factorY ? factorX : factorY;
			if (pixelPerfect) factor = nextSuitableScaleFactor(factor, false);
		}
		else if (scaleMode == ScaleMode.NO_BORDER)
		{
			factor = factorX > factorY ? factorX : factorY;
			if (pixelPerfect) factor = nextSuitableScaleFactor(factor, true);
		}
		
		width  *= factor;
		height *= factor;
		
		resultRect.setTo(
			into.x + (into.width  - width)  / 2,
			into.y + (into.height - height) / 2,
			width, height);
		
		return resultRect;
	}
	
	/** Calculates the next whole-number multiplier or divisor, moving either up or down. */
	private inline static function nextSuitableScaleFactor(factor:Float, up:Bool):Float
	{
		var divisor:Float = 1.0;
		var result:Float = 0;
		
		if (up)
		{
			if (factor >= 0.5) result = Math.ceil(factor);
			else
			{
				while (1.0 / (divisor + 1) > factor)
					++divisor;
			}
		}
		else
		{
			if (factor >= 1.0) result = Math.floor(factor);
			else
			{
				while (1.0 / divisor > factor)
					++divisor;
			}
		}
		if (result == 0) result = 1.0 / divisor;
		
		return result;
	}
	
	/** If the rectangle contains negative values for width or height, all coordinates
	 *  are adjusted so that the rectangle describes the same region with positive values. */
	public inline static function normalize(rect:Rectangle):Void
	{
		if (rect.width < 0)
		{
			rect.width = -rect.width;
			rect.x -= rect.width;
		}
		
		if (rect.height < 0)
		{
			rect.height = -rect.height;
			rect.y -= rect.height;
		}
	}

	/** Calculates the bounds of a rectangle after transforming it by a matrix.
	 *  If you pass a 'resultRect', the result will be stored in this rectangle
	 *  instead of creating a new object. */
	public inline static function getBounds(rectangle:Rectangle, transformationMatrix:Matrix,
									 resultRect:Rectangle=null):Rectangle
	{
		if (resultRect == null) resultRect = new Rectangle();
		
		var minX:Float = Math.POSITIVE_INFINITY;
		var minY:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;
		var maxY:Float = Math.NEGATIVE_INFINITY;
		
		for(i in 0...4)
		{
			MatrixUtil.transformCoords(transformationMatrix, 
										sPositions[i].x * rectangle.width, 
										sPositions[i].y * rectangle.height, sHelperPoint);
			
			if (minX > sHelperPoint.x) minX = sHelperPoint.x;
			if (maxX < sHelperPoint.x) maxX = sHelperPoint.x;
			if (minY > sHelperPoint.y) minY = sHelperPoint.y;
			if (maxY < sHelperPoint.y) maxY = sHelperPoint.y;
		}
		
		resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
		return resultRect;
	}
	
	public static var helpPoint:Point = new Point();
	public static var helpRect:Rectangle;	
	public inline static function scaleToContent(obj:Dynamic,_coordinateSystemRect:Rectangle,centrateAllToContent:Bool,scale:Float=1,maxRect:Rectangle=null):Void
	{
		helpRect = obj.hasOwnProperty("getRect") ? obj.getRect(obj.parent) : obj.getBounds(obj.parent,helpRect);
		validateRect(helpRect);
		
		var raport:Float = helpRect.width/helpRect.height;
		
		helpRect = RectangleUtil.fit(helpRect,_coordinateSystemRect,ScaleMode.NO_BORDER,false,helpRect);
		helpRect.width *= scale;
		helpRect.height = helpRect.width/raport;
		
		if(Std.is(obj,ISmartDisplayObject)) Std.instance(obj,ISmartDisplayObject).setSize(helpRect.width,helpRect.height);
		else
		{
			obj.width = helpRect.width;
			obj.height = helpRect.height;
		}
		
		if(maxRect!=null && (helpRect.width>maxRect.width || helpRect.height>maxRect.height))
		{
			RectangleUtil.fit(helpRect,maxRect,ScaleMode.SHOW_ALL,false,helpRect);
			helpRect.width *= scale;
			helpRect.height = helpRect.width/raport;
			
			validateRect(helpRect);
			if(Std.is(obj,ISmartDisplayObject)) Std.instance(obj,ISmartDisplayObject).setSize(helpRect.width,helpRect.height);
			else
			{
				obj.width = helpRect.width;
				obj.height = helpRect.height;
			}
		}
		if(centrateAllToContent) centrateToContent(obj,_coordinateSystemRect);
	}
	public inline static function centrateToContent(obj:Dynamic,_coordinateSystemRect:Rectangle,_objRect:Rectangle=null):Void
	{
		if(_objRect==null) _objRect = Reflect.hasField(obj,"getRect") ? Reflect.callMethod(null,Reflect.field(obj,"getRect"),[obj.parent]) : Reflect.callMethod(null,Reflect.field(obj,"getBounds"),[obj.parent,helpRect]);
		validateRect(_objRect);
		validateRect(obj);
		
		obj.x = _coordinateSystemRect.x + _coordinateSystemRect.width/2 - _objRect.width/2 + obj.x - _objRect.x;
		obj.y = _coordinateSystemRect.y + _coordinateSystemRect.height/2 - _objRect.height/2 + obj.y - _objRect.y;			
	}
	public inline static function validateRect(obj:Dynamic):Void
	{
		if(obj.width==Math.NaN) obj.width = 1;
		if(obj.height==Math.NaN) obj.height = 1;
		if(obj.x==Math.NaN) obj.x = 0;
		if(obj.y==Math.NaN) obj.y = 0;
	}
	public inline static function centrateToStage(obj:Dynamic,coordinateSystemRect:Rectangle,xOffset:Float=1,yOffset:Float=1):Void
	{
		helpRect = obj.hasOwnProperty("getRect") ? obj.getRect(obj.stage) : obj.getBounds(obj.stage,helpRect);
		helpRect.x = (coordinateSystemRect.width - helpRect.width)/2;
		helpRect.y = (coordinateSystemRect.height - helpRect.height)/2;
		
		helpRect.x *= xOffset;
		helpRect.y *= yOffset;
		
		helpPoint = obj.parent.globalToLocal(new Point(helpRect.x,helpRect.y),helpPoint);
		obj.x = helpPoint.x;
		obj.y = helpPoint.y;
	}
}