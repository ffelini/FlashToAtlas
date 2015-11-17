// =====starlingExtensions.utils====================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package haxePort.starlingExtensions.utils;

class GetNextPowerOfTwo
{
	function new(){}
	/** Returns the next power of two that is equal to or bigger than the specified number. */
	public inline static function getNextPowerOfTwo(number:Int):Int
	{
		if (number > 0 && (number & (number - 1)) == 0) // see: http://goo.gl/D9kPj
			return number;
		else
		{
			var result:Int = 1;
			while (result < number) result <<= 1;
			return result;
		}
	}

}