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
	var mouse:MouseHandler;

	public function new(window:Window, ?config:GumConfig) {
		isUpdating = false;
		this.window = window;
		this.mouse = new MouseHandler();
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
		mouse.update();
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
		mouse.onMouseMove(x, y);
		loop.onMouseMove(x, y);
	}

	public function onMouseDown(x:Float, y:Float, button:MouseButton):Void {
		mouse.onMouseDown(x, y, button);
		loop.onMouseDown(x, y, button);
	}

	public function onMouseUp(x:Float, y:Float, button:MouseButton):Void {
		mouse.onMouseUp(x, y, button);
		loop.onMouseUp(x, y, button);
	}

	public function onMouseScroll(deltaX:Float, deltaY:Float, wheelMode:MouseWheelMode):Void {
		mouse.onMouseScroll(deltaX, deltaY, wheelMode);
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

typedef Rectangle = {
	x:Int,
	y:Int,
	wide:Int,
	high:Int
}

/*
	public var pixelX(default, null):Int;
	public var pixelY(default, null):Int;
	public var pixelWidth(default, null):Int;
	public var pixelHeight(default, null):Int;
*/

class Interactive<T> {
	public function new(target:T, isOverlapping:Void->Bool, onMouseDown:T->Void=null, ?onMouseUp:T->Void=null, ?onMouseOver:T->Void=null, ?onMouseOut:T->Void=null){
		this.target = target;
		isOverlapping = overlapsMouse;
		this.onMouseDown = onMouseDown;
		this.onMouseUp = onMouseUp;
		this.onMouseOver = onMouseOver;
		this.onMouseOut = onMouseOut;
		pixelX = bounds.x;
		pixelY = bounds.y;
		pixelWidth = bounds.wide;
		pixelHeight = bounds.high;
	}

	var target:T;
	var isOverlapping:(x:Float, y:Float)->Bool;
	var onMouseDown:T->Void;
	var onMouseUp:T->Void;
	var onMouseOver:T->Void;
	var onMouseOut:T->Void;

	public function overlapsMouse(x:Float, y:Float) {
		return isOverlapping(x, y);
	}

	public function mouseOver(x:Float, y:Float) {
		if onMouseOver == null return;
		onMouseOver(x, y);
	}

	public function mouseDown(x:Float, y:Float, button:MouseButton) {
		if onMouseDown == null return;
		onMouseDown(x, y, button);
	}

	public function mouseUp(x:Float, y:Float, button:MouseButton) {
		if onMouseUp == null return;
		onMouseUp(x, y);
	}

	public function mouseScroll(deltaX:Float, deltaY:Float, wheelMode:MouseWheelMode) {
		if onMouseScroll == null return;
		mouseOver(deltaX, deltaY, wheelMode);
	}

	public function mouseScroll(deltaX:Float, deltaY:Float, wheelMode:MouseWheelMode) {
		if onMouseScroll == null return;
		mouseOver(deltaX, deltaY, wheelMode);
	}
}

class MouseHandler{
	var targets:Array<Interactive<Any>> = [];
	var mouseOver:Array<Interactive<Any>> = [];
	var mouseDown:Array<Interactive<Any>> = [];
	var mouseClicked:Array<Interactive<Any>> = [];
	var mouseX:Float = 0;
	var mouseY:Float = 0;
	var justMoved:Bool = false;
	var justReleased:Bool = false;
	var isMouseDown:Bool = false;
	var isMouseUp:Bool = false;

	public function new(){
		
	}
	
	public function add<Any>(target:Interactive<Any>):Void{
		targets.push(target);
	}
	
	inline function overlaps(x:Float, y:Float, target:Interactive<Any>){
		var overlapsX = x >= target.x && x <= x + target.pixelWidth;
		var overlapsY = y >= target.y && y <= y + target.pixelHeight;
		return  overlapsX && overlapsY;
	}

	function getTargetsUnderMouse():Array<Interactive<Any>>{
		return targets.filter(interactive -> interactive.overlapsMouse())
	}

	public function update() {
		var targetsUnderMouse getTargetsUnderMouse(mouseX, mouseY);
		for(t in targetsUnderMouse){
			t.mouseOver(mouseX, mouseY);
			if(justMoved){
				t.mouseMove(mouseX, mouseY);
			}
			if(isMouseDown){
				t.mouseDown(mouseX, mouseY);
			}
		}
		
		justMoved = false;
		// justReleased = false; todo ! handle each mouse button

	}
	public function onMouseMove(x:Float, y:Float) {
		mouseX = x;
		mouseY = y;
		justMoved = true;
	}

	public function onMouseDown(x:Float, y:Float, button:MouseButton) {
		isMouseDown = true;
		isMouseUp = false;
	}

	public function onMouseUp(x:Float, y:Float, button:MouseButton) {
		justReleased = true;
		isMouseDown = false;
		isMouseUp = true;
	}

	public function onMouseScroll(deltaX:Float, deltaY:Float, wheelMode:MouseWheelMode) {}

}