package haxePort.starlingExtensions.flash.movieclipConverter;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
class ConvertUtils
{
	public inline static var SUBTEXTURE_NAME_DELIMITER:String = "_";
	/**
	 * constant that defines the down frameLabel name of the flash button instance 
	 */		
	public inline static var BUTTON_KEYFRAME_DOWN:String = "down";
	
	/**
	 * constant that defines the up frameLabel name of the flash button instance 
	 */		
	public inline static var BUTTON_KEYFRAME_UP:String = "up";
	
	public inline static var TYPE_POP_UP_LAYER:String = "popUpLayer";
	public inline static var TYPE_BTN:String = "Btn";
	public inline static var TYPE_PRIMITIVE:String = "primitive";
	public inline static var TYPE_QUAD:String = "quad";
	
	public inline static var TYPE_FLASH_MOVIE_CLIP:String = "flashMovieClip";
	public inline static var TYPE_FLASH_LABEL_BUTTON:String = "flashLabelButton";
	
	public inline static var TYPE_SCALE3_IMAGE:String = "scale3Image";
	public inline static var TYPE_SCALE9_IMAGE:String = "scale9Image";
	
	public inline static var FIELD_HIERARCHY:String = "hierarchy";
	public inline static var FIELD_QUALITY:String = "texturesQuality";
	public inline static var FIELD_ACCEPTABLE_SHARED_REGION_QUALITY = "acceptableSharedRegionQuality";
	public inline static var FIELD_DEFAULT_SCALEX:String = "defaultScaleX";
	public inline static var FIELD_DEFAULT_SCALEY:String = "defaultScaleY";
	public inline static var FIELD_MOVIECLIP_SIMMILAR_FRAMES:String = "simmilarFrames";
	public inline static var FIELD_EXTRUSION_FACTOR:String = "extrusionFactor";
	public inline static var FIELD_DIRECTION:String = "direction";
	public inline static var FIELD_COLOR:String = "color";
	public inline static var FIELD_QUAD_ALPHA:String = "quadAlpha";
	public inline static var FIELD_FPS = "fps";
	public inline static var FIELD_TYPE = "type";
	
	public function new()
	{
	}

	public inline static function getFlashObjType(obj:DisplayObject):String
	{
		var value:Dynamic = ConvertUtils.getFlashObjField(obj,FIELD_TYPE);
		return value!=null ? value+"" : "";
	}

	public inline static function getFlashObjField(obj:DisplayObject,fieldName:String, defaultValue:Dynamic=null):Dynamic
	{
		var r:Dynamic=null;
		obj = Std.is(obj,MovieClip) || Std.is(obj,DisplayObjectContainer) ? obj : obj.parent;
		try{
			r = obj!=null && Reflect.hasField(obj,fieldName) ? Reflect.field(obj,fieldName) : null;
		}catch(msg:String){}

		return r != null ? r : defaultValue;
	}
}