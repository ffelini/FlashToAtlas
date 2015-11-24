// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package haxePort.starlingExtensions.utils;

class Deg2rad
{
	
    /** Converts an angle from degrees into radians. */
	public inline static function deg2rad(deg:Float):Float
	{
		return deg / 180.0 * Math.PI;   
	}
}
