package rs.zajac.ui;
import rs.zajac.core.ZajacCore;
import rs.zajac.skins.CheckBoxSkin;
import rs.zajac.util.TextFieldUtil;
import nme.events.Event;
import nme.events.MouseEvent;
#if mobile
import nme.events.TouchEvent;
#end
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.text.TextFormatAlign;

/**
 * Check box
 * @author Ilic S Stojan
 */

class CheckBox extends StyledComponent{

	//******************************
	//		COMPONENT STATES
	//******************************
	
	inline public static var UP:			String = 'up';
	inline public static var OVER:			String = 'over';
	inline public static var DOWN:			String = 'down';
	inline public static var SELECTED_UP:	String = 'sel_up';
	inline public static var SELECTED_OVER:	String = 'sel_over';
	inline public static var SELECTED_DOWN:	String = 'sel_down';
	
	//******************************
	//		PUBLIC VARIABLES
	//******************************
	
	/**
	 * Styled property defining text color.
	 */
	@style public var color: Int = 0;
	
	/**
	 * Styled property defining background color.
	 */
	@style public var backgroundColor: Int = 0xffffff;
	
	/**
	 * Styled property for icon color.
	 */
	@style public var iconColor: Int = 0x666666;
	
	/**
	 * Styled property button roundness.
	 */
	@style public var roundness: Int = 0;
	
	/**
	 * Styled property button border color.
	 */
	@style public var borderColor: Int = -1;
	
	//******************************
	//		GETTERS/SETTERS
	//******************************
	
	/**
	 * Styled property - size of checked icon in pixels
	 */
	@style public var buttonSize(get_buttonSize, default):Float;
	private function get_buttonSize():Float {
		return Math.min(_getStyleProperty("buttonSize", ZajacCore.getHeightUnit()), Height);
	}
	
	override private function get_state(): String {
		if (selected) return 'sel_'+state;
		return state;
	}

	/**
	 * [Read only] reference to label field 
	 */
	public var labelField(get_tLabel, null):TextField;
	private var _tLabel:TextField;
	private function get_tLabel():TextField {
		return _tLabel;
	}
	
	private var _isOver:Bool;

	/**
	 * Check box label string
	 */
	public var label(get_label, set_label):String;
	private var _label:String;
	private function get_label():String {
		return _label;
	}
	private function set_label(value:String):String {
		if (value == null) _label = ""
			else _label = value;
		_tLabel.text = _label;
		invalidSkin();
		return _label;
	}

	/**
	 * Selected state (true if checkbox is selected, false if it isn't)
	 */
	public var selected(get_selected, set_selected):Bool;
	private var _selected:Bool;
	private function get_selected():Bool {
		return _selected;
	}
	private function set_selected(value:Bool):Bool {
		var c_changed:Bool = false;
		
		if (_selected != value) c_changed = true;
		
		_selected = value;
		
		
		if (_isOver) state = OVER
			else state = UP;
		
		if (c_changed) dispatchEvent(new Event(Event.CHANGE));
		return _selected;
	}
	
	//******************************
	//		PUBLIC METHODS
	//******************************
	
	public function new() {
		super();
		defaultWidth = ZajacCore.getHeightUnit() * 5;
		defaultHeight = ZajacCore.getHeightUnit();
		
		_tLabel = new TextField();
		TextFieldUtil.fillFieldFromObject(_tLabel, { align:TextFormatAlign.LEFT, multiline:false, autoSize:TextFieldAutoSize.LEFT, selectable:false, mouseEnabled:false, size: ZajacCore.getFontSize() } );
		addChild(_tLabel);
		
		#if mobile
		addEventListener(TouchEvent.TOUCH_BEGIN,onTouchBegin);
		addEventListener(TouchEvent.TOUCH_END, 	onTouchEnd);
		addEventListener(TouchEvent.TOUCH_OVER,	onTouchOver);
		addEventListener(TouchEvent.TOUCH_OUT,	onTouchOut);
		#else
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_UP, 	onMouseUp);
		addEventListener(MouseEvent.ROLL_OVER, 	onMouseOver);
		addEventListener(MouseEvent.ROLL_OUT, 	onMouseOut);
		buttonMode = true;
		#end
		addEventListener(MouseEvent.CLICK, 		onClick);
		
	}
	
	//******************************
	//		PRIVATE METHODS
	//******************************
	
	override private function initialize(): Void {
		skinClass = CheckBoxSkin;
		state = UP;
	}
	
	#if mobile
	
	private function onTouchBegin(e: TouchEvent): Void {
		if (!enabled) return;
		state = DOWN;
	}
	
	private function onTouchEnd(e: TouchEvent): Void {
		if (!enabled) return;
		state = UP;
	}
	
	private function onTouchOver(e: TouchEvent): Void {
		if (!enabled) return;
		state = DOWN;
	}
	
	private function onTouchOut(e: TouchEvent): Void {
		if (!enabled) return;
		state = UP;
	}
	
	#else
	private function onMouseDown(e:MouseEvent):Void {
		if (!enabled) return;
		state = DOWN;
	}
	
	private function onMouseUp(e:MouseEvent):Void {
		if (!enabled) return;
		if (_isOver) state = OVER
			else state = UP;
	}
	
	private function onMouseOver(e:MouseEvent):Void {
		if (!enabled) return;
		_isOver = true;
		state = OVER;
	}
	
	private function onMouseOut(e:MouseEvent):Void {
		if (!enabled) return;
		_isOver = false;
		state = UP;
	}
	#end
	
	private function onClick(e:MouseEvent):Void {
		selected = !_selected;
	}
}