package haxePort.starlingExtensions.interfaces;

/**
 * @author val
 */

interface IDisplayObjectContainer 
{
  function adChildAt(child:Dynamic, index:Int):Void;
  function adChild(child:Dynamic):Void;
  function getChildAtIndex(index:Int):Dynamic;
  function numChildrens():Int;
}