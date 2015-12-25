package ;
import flash.utils.Function;
import haxePort.managers.Handlers;
import flash.Lib;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.display.DisplayObject;
class DragAndDrop {
    private var target:DisplayObject;
    private var onMouseEventFunc:Function;
    private var stage:Stage;

    public function new(target:DisplayObject, onMouseEventFunc:Function=null) {
        this.target = target;
        this.onMouseEventFunc = onMouseEventFunc;
        this.stage = Lib.current.stage;
        enable(true);
    }

    public function enable(value:Bool):Void {
        if(target!=null) {
            if(value) {
            target.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
            target.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
            } else {
                target.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
                target.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
            }
        }
    }

    private function onMouseEvent(e:MouseEvent):Void {
        Handlers.functionCall(onMouseEventFunc, [e]);
        if (e.type == MouseEvent.MOUSE_DOWN) {
            e.currentTarget.startDrag();
        }
        if (e.type == MouseEvent.MOUSE_UP){
            e.currentTarget.stopDrag();
        }
    }
}
