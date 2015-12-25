package haxePort.starlingExtensions.flash.movieclipConverter;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;
import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import flash.geom.Point;
import flash.geom.Rectangle;
class AtlasConf {
    @:isVar public var atlasRect(get, null):Rectangle;
    @:isVar public var textureScale(get, null):Float;
    @:isVar public var regionPoint(get, null):Point;

    public function new(atlasRect:Rectangle, textureScale:Float, regionPoint:Point) {
        this.atlasRect = atlasRect.clone();
        this.regionPoint = regionPoint.clone();
        this.textureScale = textureScale;
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

}
