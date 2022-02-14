package ob.gum;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;

class Gum {
	public var loop(default, null):ILoop;
	public var totalTicksPassed(default, null):Int = 0;
	public var elapsedMsSinceLastTick(default, null):Int = 0;
	public var totalMsElapsed(default, null):Float = 0.0;
	public var window(default, null):Window;

	var drawNeedsUpdate:Bool = false;
	public var config(default, null):GumConfig;
	var tickDurationMs:Int;
	var isUpdating:Bool;

	public function new(window:Window, ?config:GumConfig) {
		isUpdating = false;
		this.window = window;
		this.config = config != null ? config : {
			framesPerSecond: 60,
			drawOnlyWhenRequested: false
		};
		tickDurationMs = Math.floor(1000 / this.config.framesPerSecond);
		loop = new LoadingLoop();
		loop.onInit(this);
	}

	public function toggleUpdate(?setIsUpdatingTo:Bool) {
		if (setIsUpdatingTo != null) {
			isUpdating = setIsUpdatingTo;
		} else {
			isUpdating = !isUpdating;
		}
	}

	public function changeLoop(next:ILoop) {
		loop = next;
		loop.onInit(this);
	}

	public function onUpdate(deltaTime:Int):Void {
		if (!isUpdating)
			return;
		elapsedMsSinceLastTick += deltaTime;
		if (elapsedMsSinceLastTick >= tickDurationMs) {
			elapsedMsSinceLastTick = 0;
			totalTicksPassed++;
			drawNeedsUpdate = loop.onTick(deltaTime);
		}
		// todo ? same as above but a 'tick rate' for draw at different rate
		if (!config.drawOnlyWhenRequested || drawNeedsUpdate) {
			loop.onDraw(deltaTime);
			drawNeedsUpdate = false;
		}
	}

	public function onKeyDown(key:KeyCode, modifier:KeyModifier):Void {
		loop.onKeyDown(key, modifier);
	}

	public function onKeyUp(key:KeyCode, modifier:KeyModifier):Void {
		loop.onKeyUp(key, modifier);
	}

	public function onMouseMove(x:Float, y:Float):Void {
		loop.onMouseMove(x, y);
	}

	public function onMouseDown(x:Float, y:Float, button:MouseButton):Void {
		loop.onMouseDown(x, y, button);
	}

	public function onMouseUp(x:Float, y:Float, button:MouseButton):Void {
		loop.onMouseUp(x, y, button);
	}

	public function onMouseScroll(deltaX:Float, deltaY:Float, wheelMode:MouseWheelMode):Void {
		loop.onMouseScroll(deltaX, deltaY, wheelMode);
	}

	public function onWindowResize(width:Int, height:Int):Void {
		loop.onWindowResize(width, height);
	}
}

typedef Tick = Int;

interface ILoop {
	function onInit(gum:Gum):Void;
	function onTick(tick:Tick):IsRedrawRequired;
	function onDraw(tick:Tick):Void;
	function onKeyDown(code:KeyCode, modifier:KeyModifier):Void;
	function onKeyUp(code:KeyCode, modifier:KeyModifier):Void;
	function onMouseMove(x:Float, y:Float):Void;
	function onMouseDown(x:Float, y:Float, button:MouseButton):Void;
	function onMouseUp(x:Float, y:Float, button:MouseButton):Void;
	function onMouseScroll(deltaX:Float, deltaY:Float, wheelMode:MouseWheelMode):Void;
	function onWindowResize(width:Int, height:Int):Void;
}

typedef IsRedrawRequired = Bool;

typedef GumConfig = {
	framesPerSecond:Int,
	drawOnlyWhenRequested:Bool,
	?displayWidth:Int,
	?displayHeight:Int,
	?displayIsScaled:Bool
}

/** The default loop used when Gum starts, does nothing **/
class LoadingLoop implements ILoop {
	var gum:Gum;

	public function new() {}

	public function onTick(tick:Int):IsRedrawRequired {
		return false;
	}

	public function onInit(gum:Gum) {
		this.gum = gum;
		trace('LoadingLoop onInit');
	}

	public function onDraw(tick:Int) {}

	public function onKeyDown(code:KeyCode, modifier:KeyModifier) {}

	public function onKeyUp(code:KeyCode, modifier:KeyModifier) {}

	public function onMouseMove(x:Float, y:Float) {}

	public function onMouseDown(x:Float, y:Float, button:MouseButton) {}

	public function onMouseUp(x:Float, y:Float, button:MouseButton) {}

	public function onMouseScroll(deltaX:Float, deltaY:Float, wheelMode:MouseWheelMode) {}

	public function onWindowResize(width:Int, height:Int) {}
}
