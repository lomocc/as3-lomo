package cc.lomo.ui
{
	import cc.lomo.core.Globals;
	import cc.lomo.core.Singleton;
	
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	
	[Event(name="keyDirectionChanged", type="cc.lomo.ui.KeyEvent")]
	
	public class Key extends EventDispatcher
	{
		protected var m_map:Object;
		
		public function Key()
		{
		}
		
		protected var m_key:uint = Key.CENTER;
		
		public function setMkey(value:uint, type:String):void
		{
			if(m_key == value)
				return;
			m_key = value;
			
			dispatchEvent(new KeyEvent(KeyEvent.KEY_DIRECTION_CHANGE, m_key, type));
		}
		
		public function init(wsad:String = "wsad"):void
		{
			setCode(wsad);
			
			if(!Globals.stage)
				throw Globals.error(this, "需要先设置Globals.stage");
			
			Globals.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			Globals.stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
		}
		
		public function setCode(wsad:String):void
		{
			wsad = wsad.toUpperCase();
			
			m_map = {};
			
			m_map[wsad.charCodeAt(0)]	= Key.UP;
			m_map[wsad.charCodeAt(1)]	= Key.DOWN;
			m_map[wsad.charCodeAt(2)]	= Key.LEFT;
			m_map[wsad.charCodeAt(3)]	= Key.RIGHT;
		}
		
		protected function keyHandler(event:KeyboardEvent):void
		{
			trace(event.keyCode);
			if(!m_map[event.keyCode])
				return;
			
			const type:String = event.type;
			const direct:uint = m_map[event.keyCode];
			
			if(type == KeyboardEvent.KEY_DOWN)
				setMkey(m_key | direct, type);
			else if(type == KeyboardEvent.KEY_UP)
				setMkey(m_key ^ direct, type);
		}
		protected function dispose():void
		{
			Globals.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			Globals.stage.removeEventListener(KeyboardEvent.KEY_UP, keyHandler);
		}
		public static function getInstance():Key
		{
			return Singleton.getInstance( Key ) as Key;
		}
		public static function deleteInstance():void
		{
			getInstance().dispose();
			
			Singleton.deleteInstance( Key );
		}
		
		public static const CENTER:uint		=	0x0;//0x0000;
		
		public static const LEFT:uint		=	0x1 << 0;//0x0001;
		public static const RIGHT:uint		=	0x1 << 1;//0x0002;
		
		public static const UP:uint			=	0x1 << 2;//0x0008;
		public static const DOWN:uint		=	0x1 << 3;//0x0010;
		
		
		public static const LEFT_UP:uint	=	LEFT | UP;//0x0001;
		public static const LEFT_DOWN:uint	=	LEFT | DOWN;//0x0001;
		public static const RIGHT_UP:uint	=	RIGHT | UP;//0x0001;
		public static const RIGHT_DOWN:uint	=	RIGHT | DOWN;//0x0001;
	}
}