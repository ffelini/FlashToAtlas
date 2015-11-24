package log;
import haxePort.utils.LogStack;
import flash.text.TextFormat;
import flash.text.TextField;
class LogUI extends TextField {

    public function new() {
        super();
        updateStyle();
    }

    private static var _inst:LogUI;

    public static function inst():LogUI {
        if (_inst == null) {
            _inst = new LogUI();
        }
        return _inst;
    }

    public function updateStyle():LogUI {
        setTextFormat(new TextFormat("", 50, 0xFFFFFF));
        selectable = false;
        mouseWheelEnabled = false;
        return this;
    }

    public function updateFromLogStack() {
        setText(LogStack.lines.toString());
    }

    public function setText(value:String):Void {
        if (stage != null) {
            width = stage.stageWidth;
            height = stage.stageHeight;
        }
        text = value;
        scrollV  = maxScrollV;
        updateStyle();
    }
}
