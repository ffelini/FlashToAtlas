package haxePort.starlingExtensions.flash.movieclipConverter;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;
import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import flash.geom.Point;
import flash.geom.Rectangle;
class AtlasConf {
    @:isVar public var atlas(get, null):ITextureAtlasDynamic;
    @:isVar public var atlasRect(get, null):Rectangle;
    @:isVar public var textureScale(get, null):Float;
    @:isVar public var regionPoint(get, null):Point;
    @:isVar public var atlasAbstract(get, null):TextureAtlasAbstract;

    public function new(atlas:ITextureAtlasDynamic, atlasRect:Rectangle, textureScale:Float, regionPoint:Point, atlasAbstract:TextureAtlasAbstract) {
        this.atlas = atlas;
        this.atlasRect = atlasRect.clone();
        this.regionPoint = regionPoint.clone();
        this.textureScale = textureScale;
        this.atlasAbstract = atlasAbstract;
    }

    function get_atlas():ITextureAtlasDynamic {
        return atlas;
    }

    function get_atlasRect():Rectangle {
        return atlasRect;
    }

    function get_textureScale():Float {
        return textureScale;
    }

    function get_regionPoint():Point {
        return regionPoint;
    }

    function get_atlasAbstract():TextureAtlasAbstract {
        return atlasAbstract;
    }

}
