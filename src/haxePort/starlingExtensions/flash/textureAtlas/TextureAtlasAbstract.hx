package haxePort.starlingExtensions.flash.textureAtlas;
import haxe.ds.Vector;
import haxePort.starlingExtensions.flash.movieclipConverter.AtlasConf;

/**
 * ...
 * @author val
 */
class TextureAtlasAbstract {
    public var imagePath:String;

    public var atlasRegionScale:Float = 1;

    public var subtextures:Array<SubtextureRegion>;

    public function new() {
        map = new Map();
        subtextures = new Array<SubtextureRegion>();
    }

    public inline function add(value:SubtextureRegion):Void {
        value.parent = this;
        if(subtextures.indexOf(value)<0) subtextures.push(value);
        map.set(value.name, value);
    }

    public inline function remove(value:SubtextureRegion):Void {
        value.parent = null;
        subtextures.remove(value);
    }
    private var map:Map<String, SubtextureRegion>;

    public inline function getSubtextureByName(name:String):SubtextureRegion {
        return map.get(name);
    }

    public inline function clone():TextureAtlasAbstract {
        var c:TextureAtlasAbstract = new TextureAtlasAbstract();
        c.imagePath = imagePath;
        c.subtextures = subtextures.copy();
        return c;
    }

    private var _atlasConf:AtlasConf;
    @isVar public var atlasConf(get, set):AtlasConf;
	function get_atlasConf():AtlasConf 
	{
		return _atlasConf;
	}
	
	function set_atlasConf(value:AtlasConf):AtlasConf 
	{
		return _atlasConf = value;
	}
}