package cc.lomo.proxy
{
	import cc.lomo.core.Singleton;
	
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * 
	 * Timer事件处理管理类,单例类型（用cc.lomo.singleton.Singleton 实现）, 
	 * 所有的事件处理函数统一用一个timer侦听，可能需要按照项目需求来设定此timer的delay.
	 * <pre><i>exmaple:</i>
	 * TimerProxy.getInstance().delay = 100;
	 * TimerProxy.getInstance().addTimerListener(500, handler,2500);
	 * function handler():void
	 * {
	 * 	//to do
	 * }
	 * </pre>
	 * 
	 * @author vincent 2011年12月29日
	 * @see cc.lomo.core.Singleton
	 */	
	public class TimerProxy
	{
		public static function getInstance():TimerProxy
		{
			return Singleton.getInstance( TimerProxy ) as TimerProxy;
		}
		
		protected var timer:Timer;
		
		protected var listenerMap:Dictionary;
		
		protected var position:int;
		
		private var _delay:int = 1000;
		
		public function get delay():int
		{
			return _delay;
		}
		/**
		 * 
		 * @param value 设置timer的delay参数
		 * 
		 */		
		public function set delay(value:int):void
		{
			if ( _delay != value )
			{
				_delay = value;
				
				for(var listener:* in listenerMap)
				{
					(listener as TimerListener).startPosition = 0;
				}
				position = 0;
				restart();
			}
		}
		protected function start():void
		{
			if(!timer)
			{
				timer = new Timer( delay );
				timer.addEventListener(TimerEvent.TIMER, timerHandler);
			}
			timer.start();
		}
		protected function stop():void
		{
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				timer = null;
			}
		}
		protected function restart():void
		{
			stop();
			start();
		}
		/**
		 * 添加timer事件 当首次添加时 timer将自动start
		 * @param delay 执行时间间隔（毫秒）
		 * @param handler 执行方法
		 * @param repeatCount 执行次数 0:无数次
		 * 
		 */	
		public function addTimerListener(delay:Number, handler:Function, repeatCount:int = 0):void
		{
			if( !listenerMap )
			{
				listenerMap = new Dictionary();
			}
			
			var listener:TimerListener = getTimerlistener( delay, handler );
			
			if ( !listener )
			{
				listener = new TimerListener( delay, handler, repeatCount );
				listener.startPosition = this.position;
				
				listenerMap[listener] = true;
			}
			start();
		}
		public function removeTimerListener(delay:Number, handler:Function):void
		{
			if( !listenerMap )
			{
				return;
			}
			var listener:TimerListener = getTimerlistener( delay, handler );
			if ( listener )
			{
				removeListener( listener );
			}
			stopTest();
		}
		protected function removeListener( listener:Object ):void
		{
			listenerMap[listener] = null;
			delete listenerMap[listener];
		}
		protected function getTimerlistener(delay:int, handler:Function):TimerListener
		{
			for(var listener:* in listenerMap)
			{
				if(listener.handler != handler || listener.delay != delay)
				{
				}else
				{
					return listener as TimerListener;
				}
			}
			return null;
		}
		
		protected function timerHandler(event:TimerEvent):void
		{
			const delay:int = this.delay;
			position += delay;
			
			for (var listener:* in listenerMap)
			{
				//delay was changed~
				if(this.delay != delay)
					return;
				
				var result:Boolean = (listener as TimerListener).test(position);
				if (result)
				{
					removeListener( listener );
				}
			}
			
			stopTest();
		}
		protected function stopTest():void
		{
			var hasListener:Boolean = false;
			for (var listener:* in listenerMap)
			{
				hasListener = true;
				break;
			}
			if(!hasListener)
			{
				stop();
			}
		}
	}
}
class TimerListener
{
	public var handler:Function;
	public var delay:int;
	public var repeatCount:int;
	
	public var startPosition:int;
	
	/**
	 * 
	 * @param delay 执行时间间隔（毫秒） 最小为1
	 * @param handler 执行方法
	 * @param repeatCount 执行次数 0:无数次
	 * 
	 */	
	function TimerListener(delay:Number, handler:Function, repeatCount:int = 0)
	{
		this.handler = handler;
		this.delay = delay;
		this.repeatCount = repeatCount;
	}
	
	/**
	 * 
	 * @param position timer指针位置
	 * @return 是否删除
	 * 
	 */	
	public function test(position:int):Boolean
	{
		var result:Boolean = (position - startPosition) % delay == 0;
		if( !result )
		{
			return false;
		}
		
		this.handler();
		
		if( repeatCount == 1)
		{
			//gameover
			return true;
		}else if( repeatCount == 0 )
		{
			// repeatCount <= 0      :     forever
			return false;
		}
		
		repeatCount --;
		return false;
	}
}