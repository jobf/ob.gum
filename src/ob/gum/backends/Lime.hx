package ob.gum.backends;

import ob.gum.Core;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Window;

class App extends Application {
	var gum:Gum;
	var isReadyForUpdate = false;

	function init(window:Window, ?config:GumConfig) {
		gum = new Gum(window, config);
		isReadyForUpdate = true;
	}

	override function onWindowCreate():Void {
		trace('App onWindowCreate');
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try {
					init(window);
				} catch (_) {
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	public override function update(deltaTime:Int):Void {
		if (isReadyForUpdate) {
			gum.onUpdate(deltaTime);
		}
	}

	override function onKeyDown(keyCode:KeyCode, modifier:KeyModifier):Void {
		#if !html5
		if (keyCode == ESCAPE) {
			window.close();
		}
		#end

		gum.onKeyDown(keyCode, modifier);
	}

	override function onKeyUp(keyCode:KeyCode, modifier:KeyModifier):Void {
		gum.onKeyUp(keyCode, modifier);
	}

	override function onMouseMove(x:Float, y:Float) {
		gum.onMouseMove(x, y);
	}

	override function onMouseDown(x:Float, y:Float, button:MouseButton):Void {
		gum.onMouseDown(x, y, button);
	}

	override function onMouseUp(x:Float, y:Float, button:MouseButton):Void {
		gum.onMouseUp(x, y, button);
	}

	override function onMouseWheel(deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		gum.onMouseScroll(deltaX, deltaY, deltaMode);
	}

	override function onWindowResize(width:Int, height:Int) {
		super.onWindowResize(width, height);
		gum.onWindowResize(width, height);
	}

	override function onPreloadComplete() {
		super.onPreloadComplete();
		gum.onPreloadComplete();
	}
}
