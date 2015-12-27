package ;
import haxePort.starlingExtensions.flash.movieclipConverter.AtlasDescriptor;
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

import haxePort.utils.*;
import haxePort.interfaces.*;
import haxePort.managers.*;
import haxePort.starlingExtensions.*;

//-swf-header 640:960:10:CCCCCC
//-swf-version 16 -swf-lib gameAssets.swc --macro include('src')

class Main extends Sprite {

    private var target:DisplayObject;// = new ScreenPlay();
    private var converter:FlashDisplay_Converter = new FlashDisplay_Converter();
    private var flashMirror:FlashMirrorRoot = new FlashMirrorRoot();

    public function new() {
        super();
        var stage:Stage = Lib.current.stage;
        stage.color = 0xCCCCCC;

        FlashAtlas.textureFromBmdFunc = textureFromBmdFunc;
        FlashAtlas.getAtlasFunc = getAtlas;
        FlashAtlas.helpTexture = {a:1};
        FlashAtlas.saveAtlasPngFunc = saveAtlasPng;


        converter = getConverter();
        converter.shareAtlasesRegions();

        addChild(converter);

        converter.convert(target, flashMirror, new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), false);
        converter.scaleX = converter.scaleY = 0.3;


//        target = new ScreenPlay();
//        flashMirror = new FlashMirrorRoot();
//        converter = getConverter();
//        converter.reUseGlobalSharedAtlases = true;
//        addChild(converter);
//        converter.convert(target, cd, flashMirror, new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), false);
//        converter.y = 1000;
//        converter.scaleX = converter.scaleY = 0.3;
    }

    private function getConverter():FlashDisplay_Converter {
        converter = new FlashDisplay_Converter();
        converter.debug = converter.debugAtlas = true;
        converter.removeGaps = true;
        new DragAndDrop(converter, onMouseEvent);
        return converter;
    }

    private function onMouseEvent(e:MouseEvent):Void {
        flashMirror.clear();
        addChild(flashMirror);
        removeChild(converter);

        converter.setTarget(target, flashMirror);
        for(atlas in flashMirror.atlases) {
            flashMirror.addBitmap(converter.redrawAtlas(atlas));
        }
        LogUI.inst().setText(e.target + " " + e.stageX + "/" + e.stageY +
        " \nstage.width - " + stage.width +
        " \nstage.height - " + stage.height +
        " \nstage.fullScreenWidth - " + stage.fullScreenWidth +
        " \nstage.fullScreenHeight - " + stage.fullScreenHeight +
        " \nconverter.descriptors.length - " + converter.descriptors.length+
        "\nconverter.convertDescriptor.convertDuration - " + converter.convertDescriptor.convertDuration);
    }

    private function textureFromBmdFunc(atlasBmd:BitmapData, textureScale:Float, onRestore:Function = null):Dynamic {
        return {a:1};
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
        Lib.current.stage.addChild(new Main());
    }
}
