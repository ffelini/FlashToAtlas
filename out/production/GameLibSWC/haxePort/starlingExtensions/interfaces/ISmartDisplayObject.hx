package haxePort.starlingExtensions.interfaces;

import flash.geom.Rectangle;

interface ISmartDisplayObject
{
	function setSize(w:Float, h:Float, boundRect:Rectangle = null):Void;
}
