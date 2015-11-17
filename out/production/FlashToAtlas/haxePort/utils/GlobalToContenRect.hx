package haxePort.utils;

import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.geom.Rectangle;

class GlobalToContenRect
{
	
	public function new(){}
	
	private static var shape:Shape;
	public inline static function globalToContenRect(globalRect:Rectangle,localCoordinateSystem:DisplayObjectContainer):Rectangle
	{
		if (shape == null) shape = new Shape();
		shape.graphics.clear();
		shape.graphics.beginFill(0);
		shape.graphics.drawRect(0,0,globalRect.width,globalRect.height);
		shape.graphics.endFill();
		
		return shape.getBounds(localCoordinateSystem);
	}
}
