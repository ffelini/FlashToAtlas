package test;
import flash.utils.Function;
import haxePort.starlingExtensions.flash.textureAtlas.TextureAtlasAbstract;
import flash.display.Sprite;
import flash.text.TextField;
import haxePort.starlingExtensions.flash.movieclipConverter.AtlasDescriptor;
import log.LogUI;
import flash.events.MouseEvent;
import haxePort.starlingExtensions.flash.movieclipConverter.FlashDisplay_Converter;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashMirrorRoot;
import flash.geom.Rectangle;
import flash.display.*;
import haxePort.starlingExtensions.flash.movieclipConverter.IFlashSpriteMirror;
import haxePort.starlingExtensions.flash.movieclipConverter.MirrorDescriptor;
import haxePort.starlingExtensions.flash.textureAtlas.ITextureAtlasDynamic;
import flash.Lib;
/**
 * ...
 * @author val
 */
class FlashMirrorRoot extends Sprite implements IFlashMirrorRoot {

    private var curentAtlasBitmap:Bitmap;


    public var atlases:Array<ITextureAtlasDynamic> = [];

    public function new() {
        super();
        scaleX = scaleY = 0.3;
    }

    public function onDescriptorReset(descriptor:AtlasDescriptor) {
    }

    public var quality(get, set):Float;

    public function get_quality():Float {
        return 1.0;
    }

    public function set_quality(value:Float):Float {
        return 1.0;
    }
    private var _descriptor:MirrorDescriptor;
    public var descriptor(get, null):MirrorDescriptor;

    public function get_descriptor():MirrorDescriptor {
        if (_descriptor == null) _descriptor = new MirrorDescriptor();
        return _descriptor;
    }

    public function storeAtlas(atlas:ITextureAtlasDynamic, bmd:BitmapData):Void {
        if (atlases.indexOf(atlas) < 0) atlases.push(atlas);

        addBitmap(bmd);
    }

    public function createTextureAtlasDynamic(atlas:TextureAtlasAbstract, atlasBmd:BitmapData):ITextureAtlasDynamic {
        return new TextureAtlasDynamic();
    }

    public function saveAtlasPng(path:String, atlasBmd:BitmapData):Void {
    }

    public function addBitmap(bmd:BitmapData):Void {
        var atlasBitmapX:Float = curentAtlasBitmap != null ? curentAtlasBitmap.x + curentAtlasBitmap.width + 20 : 0;
        var sp:Sprite = new Sprite();
        curentAtlasBitmap = new Bitmap(bmd);
        curentAtlasBitmap.x = atlasBitmapX;
        sp.addChild(curentAtlasBitmap);
        addChild(sp);
        new DragAndDrop(sp, onMouseEvent);
    }

    public function clear() {
        if(numChildren>0) removeChildren(0, numChildren-1);
        curentAtlasBitmap = null;
    }

    private function onMouseEvent(e:MouseEvent):Void {
        LogUI.inst().setText(e.currentTarget + " size - " + e.currentTarget.width + "/" + e.currentTarget.height);
    }

    public function getMirror(mirror:Dynamic):Dynamic {
        return null;
    }

    public function getMirrorRect(_mirror:Dynamic):Rectangle {
        return null;
    }

    public function registerMirror(instance:Dynamic, _mirror:DisplayObject):Void {

    }

    public function storeInstance(instance:Dynamic, _mirror:DisplayObject, mirrorRect:Rectangle = null):Void {

    }

    public function convertSprite(sprite:DisplayObjectContainer, spClass:Class<Dynamic>):IFlashSpriteMirror {
        return new FlashSpriteMirror();
    }

    public function createChild(flashChild:DisplayObject, childClass:Class<Dynamic>):Void {

    }

    public function createButton(flashButton:MovieClip, childClass:Class<Dynamic>) {
    }

    public function createTextField(flashTextField:TextField, childClass:Class<Dynamic>) {
    }

    public function createImage(flashImage:DisplayObject, childClass:Class<Dynamic>) {
    }

    public function createQuad(flashImage:DisplayObject, childClass:Class<Dynamic>, color:UInt, quadAlpha:Float) {
    }

    public function createMovieClip(flashMovieClip:MovieClip, childClass:Class<Dynamic>) {
    }

    public function createScale3Image(flashImage:DisplayObject, childClass:Class<Dynamic>, direction:String) {
    }

    public function createScale9Image(flashImage:DisplayObject, childClass:Class<Dynamic>) {
    }

    public function onChildrenCreationComplete():Void {
    }

    public function isEconomicButton(obj:DisplayObject):Bool {
        return FlashDisplay_Converter.isButton(Std.instance(obj, MovieClip));
    }

    public function adChildAt(child:Dynamic, index:Int):Void {

    }

    public function adChild(child:Dynamic):Void {

    }

    public function getChildAtIndex(index:Int):Dynamic {
        return null;
    }

    public function numChildrens():Int {
        return 0;
    }
}