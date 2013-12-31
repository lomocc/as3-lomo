package cc.lomo.ui
{
	import flash.events.Event;
	
	public class KeyEvent extends Event
	{
		public static const KEY_DIRECTION_CHANGE:String = "keyDirectionChanged";
		
		protected var m_action:String;
		public function get action():String
		{
			return m_action;
		}
		protected var m_directionValue:uint;
		public function get directionValue():uint
		{
			return m_directionValue;
		}
		/**
		 * 
		 <pre>directionValue:
		 case Key.UP: "UP";break;
		 case Key.DOWN: "DOWN";break;
		 case Key.LEFT: "LEFT";break;
		 case Key.RIGHT: "RIGHT";break;
		 case Key.LEFT_UP: "LEFT_UP";break;
		 case Key.LEFT_DOWN: "LEFT_DOWN";break;
		 case Key.RIGHT_UP: "RIGHT_UP";break;
		 case Key.RIGHT_DOWN: "RIGHT_DOWN";break;
		 default: "CENTER";break;</pre> 
		 * @param type
		 * @param directionValue uint四位的二进制数 用来表示上下左右方向
		 * @param action 触发事件的类型 KeyboardEvent[KEY_DOWN / KEY_UP]
		 * 
		 */		
		public function KeyEvent(type:String, directionValue:uint, action:String)
		{
			super(type);
			
			m_directionValue	= directionValue;
			m_action			= action;
		}
		protected var arr:Object = {
		};
		override public function clone():Event
		{
			return new KeyEvent(type, directionValue, action);
		}
		
	}
}