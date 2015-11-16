package ;
import flash.ui.Keyboard;
import flash.events.KeyboardEvent;
import log.LogUI;
import flash.text.TextFormat;
import flash.text.TextField;
import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
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

class Main2 extends Sprite {

    private var converter:FlashDisplay_Converter = new FlashDisplay_Converter();

    public function new() {
        super();
        var stage:Stage = Lib.current.stage;

// create a center aligned rounded gray square
        var shape = new Shape();
        shape.graphics.beginFill(0x333333);
        shape.graphics.drawRoundRect(0, 0, 100, 100, 10);
        shape.x = (stage.stageWidth - 100) / 2;
        shape.y = (stage.stageHeight - 100) / 2;

        var cd:ConvertDescriptor = new ConvertDescriptor();

        FlashAtlas.textureFromBmdFunc = textureFromBmdFunc;
        FlashAtlas.getAtlasFunc = getAtlas;
        FlashAtlas.helpTexture = {a:1};
        FlashAtlas.saveAtlasPngFunc = saveAtlasPng;

        var target:ScreenHome = new ScreenHome();
        converter.convert(target, cd, new FlashMirrorRoot(), new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), false, false);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEvent);

        stage.addChild(shape);
        stage.addChild(LogUI.inst());

    }

    private function onMouseEvent(e:MouseEvent):Void {
        LogUI.inst().setText(e.target + " " + e.stageX + "/" + e.stageY);
        if (e.type == MouseEvent.MOUSE_DOWN) {
            converter.startDrag();
        }
        if (e.type == MouseEvent.MOUSE_UP){
            converter.stopDrag();
        }
    }

    private function onKeyEvent(e:KeyboardEvent):Void {
        if(e.type==KeyboardEvent.KEY_DOWN) {
            switch e.keyCode {
                case Keyboard.CONTROL:
                    LogUI.inst().updateFromLogStack();
                case Keyboard.LEFT:
                    converter.x -= 10;
                case Keyboard.RIGHT:
                    converter.x += 10;
            }
        }
    }

    private function textureFromBmdFunc(atlasBmd:BitmapData, textureScale:Float, onRestore:Function = null):Dynamic {
        return {a:1 };
    }

    private function getAtlas(helpTexture:Dynamic, atlasXML:TextureAtlasAbstract):ITextureAtlasDynamic {
        return new TextureAtlasDynamic();
    }

    private function saveAtlasPng(path:String, atlasBmd:BitmapData):Void {

    }

    inline function func(a:String):Void {
        trace("func-" + a);
    }

    static function main() {
        Lib.current.stage.addChild(new Main2());
    }
}
