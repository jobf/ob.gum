package ob.gum.backends;

import haxe.display.Display.Define;
import ob.gum.Core.Gum;
import ob.gum.Core.IsRedrawRequired;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import ob.gum.Core.ILoop;
import peote.view.Color;
import peote.view.Display;
import lime.graphics.Image;
import peote.view.PeoteView;
import peote.text.Font;
import utils.Loader;
import peote.view.Texture;
import peote.view.Program;
import peote.view.Element;
import peote.view.Buffer;

class PeoteViewLoop implements ILoop {
	var gum:Gum;

	public var peoteView(default, null):PeoteView;
	public var display(default, null):Display;

	public function new() {}

	public function onInit(gum:Gum) {
		this.gum = gum;
		peoteView = new PeoteView(gum.window);
		var w = gum.config.displayWidth == null ? gum.window.width : gum.config.displayWidth;
		var h = gum.config.displayHeight == null ? gum.window.height : gum.config.displayHeight;
		var displayWidth = gum.config.displayIsScaled ? gum.window.width : w;
		var displayHeight = gum.config.displayIsScaled ? gum.window.height : h;
		display = new Display(0, 0, displayWidth, displayHeight, Color.BLACK);
		peoteView.addDisplay(display);
		peoteView.start();
		// if (gum.config.displayIsScaled) {
		// todo ! scale display
		// }
	}

	public function onUpdate(deltaMs:Int) {}

	public function onTick(tick:Int):IsRedrawRequired {
		return false;
	}

	public function onDraw(tick:Int) {}

	public function onKeyDown(code:KeyCode, modifier:KeyModifier) {}

	public function onKeyUp(code:KeyCode, modifier:KeyModifier) {}

	public function onMouseMove(x:Float, y:Float) {}

	public function onMouseDown(x:Float, y:Float, button:MouseButton) {}

	public function onMouseUp(x:Float, y:Float, button:MouseButton) {}

	public function onMouseScroll(deltaX:Float, deltaY:Float, wheelMode:MouseWheelMode) {}

	public function onWindowResize(width:Int, height:Int) {
		peoteView.resize(width, height);
	}

	public function getFrameBufferDisplay(x:Int, y:Int, w:Int, h:Int, isPersistentFrameBuffer:Bool):FrameBuffer {
		var display = new Display(x, y, w, h);
		peoteView.addDisplay(display);
		peoteView.renderToTexture(display, 0);
		peoteView.addFramebufferDisplay(display);
		var framebuffer = new Texture(w, h);
		framebuffer.clearOnRenderInto = !isPersistentFrameBuffer;
		display.setFramebuffer(framebuffer);
		peoteView.removeDisplay(display);
		return {display: display, texture: framebuffer};
	}
}

typedef FrameBuffer = {
	texture:Texture,
	display:Display
}

class PaletteExtensions {
	public static function toRGBA(rgb:Array<Int>):Array<Color> {
		return [for (c in rgb) RGBA(c)];
	}

	public static function RGBA(rgb:Int, a:Int = 0xff):Color {
		return rgb << 8 | a;
	}

	public static function extractAlpha(rgba:Int):Int {
		return rgba & 0x000000FF;
	}

	public static function changeAlpha(rgba:Int, a:Int):Int {
		var r = (rgba & 0xFF000000) >> 24;
		var g = (rgba & 0x00FF0000) >> 16;
		var b = (rgba & 0x0000FF00) >> 8;
		// trace('r: ${StringTools.hex(r)}');
		// trace('g: ${StringTools.hex(g)}');
		// trace('b: ${StringTools.hex(b)}');
		// trace('a: ${StringTools.hex(a)}');
		return r << 24 | (g << 16) | (b << 8) | a;
	}
}

class Assets {
	var paths:Paths;

	public var fontCache(default, null):Array<Font<FontStyle>> = [];
	public var imageCache(default, null):Array<Image> = [];

	var onReady:Void->Void;

	public function new(paths:Paths) {
		this.paths = paths;
	}

	public function Preload(onReady:Void->Void) {
		trace('begin loading $paths');
		this.onReady = onReady;
		loadFonts();
	}

	function loadFonts(index:Int = 0) {
		if (index > paths.fonts.length - 1) {
			// finished
			loadImages();
		} else {
			// trace('load font $index');
			var path = paths.fonts[index];
			trace('loading font index $index ${path}');
			new Font<FontStyle>(path).load((font) -> {
				fontCache.push(font);
				index++;
				loadFonts(index);
			});
		}
	};

	function loadImages() {
		trace('load images');
		final debug = false;
		if (paths.images.length <= 0) {
			trace('asset loading finished');
			onReady();
		} else {
			trace('loading ${paths.images.length} images');
			// Loader.imageArray(paths.images, debug, onProgress, onProgressAll, onError,  onLoad);
			Loader.imageArray(paths.images, debug, null, null, (i, error) -> {
				trace(error);
				trace('starting without images');
				onReady();
			}, (images:Array<Image>) -> {
				imageCache = images;
				trace('loaded ${imageCache.length} images');
				trace('asset loading finished');
				onReady();
			});
		}
	}
}

typedef Paths = {
	fonts:Array<String>,
	images:Array<String>
}

class FontStyle {
	public var color:Color = Color.LIME;
	public var bgColor:Color = Color.BLACK;
	public var width:Float = 16;
	public var height:Float = 16;
	public var zIndex:Int = 0;
	public var tilt:Float = 0.0;
	public var weight:Float = 0.5;

	public function new() {}
}
