package be.zajac.containers;
import be.zajac.core.FWCore;
import be.zajac.skins.ISkin;
import be.zajac.skins.PanelSkin;
import be.zajac.ui.BaseComponent;
import be.zajac.ui.Slider;
import be.zajac.ui.StyledComponent;
import haxe.Timer;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.display.Shape;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;

/**
 * ...
 * @author Aleksandar Bogdanovic
 */

class Panel extends StyledComponent {

	@style(0)	public var backgroundColor(dynamic, dynamic): Dynamic;
	@style(1)	public var backgroundAlpha(dynamic, dynamic): Dynamic;
	@style( -1)	public var borderColor(dynamic, dynamic): Dynamic;
	
	public var mouseWheelStep: Float = 10;
	
	public var content(default, null): Sprite;
	public var verticalSlider(default, null): Slider;
	public var horizontalSlider(default, null): Slider;
	
	
	
	//TODO: check if child is moved
	private var _contentSize: Point;
	
	private function resetContentSize(): Void {
		_contentSize = null;
	}
	
	private function getContentSize(): Point {
		//TODO: calculate if x and y are < 0, Maca have implemented with bitmapData
		if (_contentSize != null) {
			_contentSize.x = Math.max(content.width, _contentSize.x);
			_contentSize.y = Math.max(content.height, _contentSize.y);
		} else {
			var c_do: Dynamic;
			_contentSize = new Point(content.width, content.height);
			for (index in 0...content.numChildren) {
				c_do = content.getChildAt(index);
				_contentSize.x = Math.max(_contentSize.x, c_do.x + c_do.Width);
				_contentSize.y = Math.max(_contentSize.y, c_do.y + c_do.Height);
			}
		}
		return _contentSize;
	}
	
	
	
	public function updateScrollRect(): Void {
		var c_width: Float;
		var c_height: Float;
		if (horizontalSlider.visible) {
			c_height = Height - horizontalSlider.Height;
		} else {
			c_height = Height;
		}
		if (verticalSlider.visible) {
			c_width = Width - verticalSlider.Width;
		} else {
			c_width = Width;
		}
		content.scrollRect = new Rectangle(horizontalSlider.value, verticalSlider.value, c_width, c_height);
	}
	
	private var _dirtyScroll: Bool = true;
	
	public function invalidScroll(): Void {
		if (_dirtyScroll) return;
		_dirtyScroll = true;
		invalid();
	}
	
	private function _validateScroll(): Bool {
		if (_dirtyScroll) {
			var c_width: Float;
			var c_height: Float;
			var c_contentSize: Point = getContentSize();
			
			horizontalSlider.visible = c_contentSize.x > Width;
			verticalSlider.visible = c_contentSize.y > Height;
			
			if (horizontalSlider.visible) {
				c_height = Height - horizontalSlider.Height;
			} else {
				c_height = Height;
			}
			
			if (verticalSlider.visible) {
				c_width = Width - verticalSlider.Width;
			} else {
				c_width = Width;
			}
			
			if (verticalSlider.visible) {
				verticalSlider.x = c_width;
				verticalSlider.Height = c_height;
				verticalSlider.maxValue = c_contentSize.y - c_height;
				verticalSlider.pageSize = verticalSlider.maxValue * c_height / c_contentSize.y;
			} else {
				verticalSlider.value = 0;
			}
			
			if (horizontalSlider.visible) {
				horizontalSlider.y = c_height;
				horizontalSlider.Width = c_width;
				horizontalSlider.maxValue = c_contentSize.x - c_width;
				horizontalSlider.pageSize = horizontalSlider.maxValue * c_width / c_contentSize.x;
			} else {
				horizontalSlider.value = 0;
			}
			
			updateScrollRect();
			
			_dirtyScroll = false;
			
			return true;
		}
		return false;
	}
	
	
	
	override public function validate(): Void {
		_validateScroll();
		super.validate();
	}
	
	
	
	public function new() {
		super();
		Width = FWCore.getHeightUnit() * 5;
		Height = FWCore.getHeightUnit() * 5;
	}
	
	override private function initialize(): Void {
		content = new Sprite();
		content.addEventListener(Event.RESIZE, _onContentSize);
		super.addChild(content);
		
		verticalSlider = new Slider();
		verticalSlider.direction = Slider.DIRECTION_VERTICAL;
		verticalSlider.minValue = 0;
		verticalSlider.x = 0;
		verticalSlider.Width = 15;
		verticalSlider.visible = false;
		super.addChild(verticalSlider);
		
		horizontalSlider = new Slider();
		horizontalSlider.direction = Slider.DIRECTION_HORIZONTAL;
		horizontalSlider.minValue = 0;
		horizontalSlider.y = 0;
		horizontalSlider.Height = 15;
		horizontalSlider.visible = false;
		super.addChild(horizontalSlider);
		
		#if mobile
			horizontalSlider.mouseChildren = false;
			horizontalSlider.mouseEnabled = false;
			verticalSlider.mouseChildren = false;
			verticalSlider.mouseEnabled = false;
			addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
		#else
			verticalSlider.addEventListener(Event.CHANGE, _onVerticalSlider);
			horizontalSlider.addEventListener(Event.CHANGE, _onHorizontalSlider);
			addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
		#end
		
		skinClass = PanelSkin;
	}
	
	

	private function _onContentSize(evt: Event): Void {
		invalidScroll();
	}
	
	private var _globalPoint: Point;
	
	private function _onMouseDown(evt: MouseEvent): Void {
		_globalPoint = new Point(evt.stageX, evt.stageY);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
	}
	
	private function _onMouseMove(evt: MouseEvent): Void {
		var c_point: Point = new Point(evt.stageX, evt.stageY);
		var t: Float;
		if (verticalSlider.visible) {
			t = verticalSlider.value + -c_point.y + _globalPoint.y;
			if (t < verticalSlider.minValue) {
				verticalSlider.minValue = t;
			} else if (t > verticalSlider.maxValue) {
				verticalSlider.maxValue = t;
			}
			verticalSlider.value = t;
			updateScrollRect();
		}
		_globalPoint = c_point;
	}
	
	private function _onMouseUp(evt: MouseEvent): Void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
	}
	
	private function _onVerticalSlider(e: Event): Void {
		updateScrollRect();
	}
	
	private function _onHorizontalSlider(e: Event): Void {
		updateScrollRect();
	}
	
	private function _onMouseWheel(evt: MouseEvent): Void {
		if (!evt.ctrlKey && verticalSlider.visible) {
			verticalSlider.value += mouseWheelStep * ((evt.delta < 0) ? 1 : -1);
			updateScrollRect();
		}
		if (evt.ctrlKey && horizontalSlider.visible) {
			horizontalSlider.value += mouseWheelStep * ((evt.delta < 0) ? 1 : -1);
			updateScrollRect();
		}
	}
	
	
	
	override public function addChild(child: DisplayObject): DisplayObject {
		resetContentSize();
		invalidScroll();
		return content.addChild(child);
	}
	
	override public function addChildAt(child : DisplayObject, index : Int) : DisplayObject {
		resetContentSize();
		invalidScroll();
		return content.addChildAt(child, index);
	}
	
	override public function contains(child : DisplayObject) : Bool {
		return content.contains(child);
	}
	
	override public function getChildAt(index : Int) : DisplayObject {
		return content.getChildAt(index);
	}
	
	override public function getChildByName(name : String) : DisplayObject {
		return content.getChildByName(name);
	}
	
	override public function getChildIndex(child : DisplayObject) : Int {
		return content.getChildIndex(child);
	}
	
	override public function removeChild(child : DisplayObject) : DisplayObject {
		resetContentSize();
		invalidScroll();
		return content.removeChild(child);
	}
	
	override public function removeChildAt(index : Int) : DisplayObject {
		resetContentSize();
		invalidScroll();
		return content.removeChildAt(index);
	}
	
	override public function setChildIndex(child : DisplayObject, index : Int) : Void {
		content.setChildIndex(child, index);
	}
	
	override public function swapChildren(child1 : DisplayObject, child2 : DisplayObject) : Void {
		content.swapChildren(child1, child2);
	}
	
	override public function swapChildrenAt(index1 : Int, index2 : Int) : Void {
		content.swapChildrenAt(index1, index2);
	}
	
}