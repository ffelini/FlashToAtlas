package haxePort.starlingExtensions.flash.movieclipConverter;
import flash.display.DisplayObject;
import flash.display.Sprite;

class ContentSprite extends Sprite
{
	public var content:Sprite = new Sprite();
	
	public function new()
	{
		super();
		super.addChildAt(content,0);
	}
	override public function addChild(child:DisplayObject):DisplayObject
	{
		return content.addChild(child);
	}
	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject
	{
		return content.addChildAt(child, index);
	}
	override public function getChildAt(index:Int):DisplayObject
	{
		return content.getChildAt(index);
	}
	override public function getChildByName(name:String):DisplayObject
	{
		return content.getChildByName(name);
	}
	override public function getChildIndex(child:DisplayObject):Int
	{
		return content.getChildIndex(child);
	}
	public function get_numChildren():Int
	{
		return content.numChildren;
	}
	override public function removeChild(child:DisplayObject):DisplayObject
	{
		return content.removeChild(child);
	}
	override public function removeChildAt(index:Int):DisplayObject
	{
		return content.removeChildAt(index);
	}
	override public function removeChildren(beginIndex:Int=0, endIndex:Int=1000000):Void
	{
		content.removeChildren(beginIndex, endIndex);
	}
	override public function setChildIndex(child:DisplayObject, index:Int):Void
	{
		content.setChildIndex(child, index);
	}
	override public function swapChildren(child1:DisplayObject, child2:DisplayObject):Void
	{
		content.swapChildren(child1, child2);
	}
	override public function swapChildrenAt(index1:Int, index2:Int):Void
	{
		content.swapChildrenAt(index1, index2);
	}
	
}