package haxePort.starlingExtensions.utils;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

/**
 * ...
 * @author felini
 */
class DisplayUtil
{

	public function new() 
	{
		
	}
		
	public static function getRotationOnScreen(obj:DisplayObject):Float {
		return getRotationOn(obj, obj.stage);
	}
	/**
	 * @param	obj
	 * @param	hierarchyRoot - one of the top obj hierarchy root parents
	 * @return This method returns the object rotation in the given root. If provided hierarchyRoot argument is not a obj root then method will return 
	 * the obj rotation in stage
	 */
	public static function getRotationOn(obj:DisplayObject, hierarchyRoot:DisplayObject):Float {
		if (obj != null) {
			var rotation = obj.rotation ;
			var parent:DisplayObjectContainer = obj.parent;
			while (parent!=null && parent != obj.stage && parent != hierarchyRoot) {
				rotation += parent.rotation;
				parent = parent.parent;
			}
			return rotation;
		}
		return 0;
	}
}