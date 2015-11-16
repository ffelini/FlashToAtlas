package ;
import haxePort.starlingExtensions.flash.movieclipConverter.FlashAtlas;
import flash.utils.Function;
import flash.display.Stage;
import flash.display.Shape;
import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;
import flash.display.BitmapData;
import test.TextureAtlasDynamic;
import flash.geom.Rectangle;
import test.FlashMirrorRoot;
import haxePort.starlingExtensions.flash.movieclipConverter.ConvertDescriptor;
import haxePort.starlingExtensions.flash.movieclipConverter.FlashDisplay_Converter;
import flash.Lib;
import ScreenHome;
class Main2 {
    public function new() {

    }

    private static function textureFromBmdFunc(atlasBmd:BitmapData, textureScale:Float, onRestore:Function = null):Dynamic {
        return {a:1 };
    }

    private static function getAtlas(helpTexture:Dynamic, atlasXML:TextureAtlasAbstract):ITextureAtlasDynamic {
        return new TextureAtlasDynamic();
    }

    private static function saveAtlasPng(path:String, atlasBmd:BitmapData):Void {

    }

    static inline function func(a:String):Void {
        trace("func-" + a);
    }

    static function main() {
        var stage:Stage = Lib.current.stage;

// create a center aligned rounded gray square
        var shape = new Shape();
        shape.graphics.beginFill(0x333333);
        shape.graphics.drawRoundRect(0, 0, 100, 100, 10);
        shape.x = (stage.stageWidth - 100) / 2;
        shape.y = (stage.stageHeight - 100) / 2;

        var cc:FlashDisplay_Converter = new FlashDisplay_Converter();

        var cd:ConvertDescriptor = new ConvertDescriptor();

        FlashAtlas.textureFromBmdFunc = textureFromBmdFunc;
        FlashAtlas.getAtlasFunc = getAtlas;
        FlashAtlas.helpTexture =  {a:1};
        FlashAtlas.saveAtlasPngFunc = saveAtlasPng;

        cc.convert(new ScreenHome(), cd, new FlashMirrorRoot(), new Rectangle(0,0,stage.stageWidth,stage.stageHeight), false,false);

//        stage.addChild(cc);
//        stage.addChild(shape);
    }
}
