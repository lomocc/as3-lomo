package cc.lomo.proxy
{
	import cc.lomo.core.Singleton;
	
	import flash.events.TimerEvent;
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
	 * @see cc.lomo.singleton.Singleton
	 */	
	public class TimerManager
	{
		public static function getInstance():TimerManager
		{
			return Singleton.getInstance( TimerManager ) as TimerManager;
		}
		
		protected var timer:Timer;
		
		protected var listenerMap:Vector.<TimerListener>;
		
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
		public function get running():Boolean
		{
			return timer && timer.running;
		}
		protected function start():void
		{
			if(!running)
			{
				timer = new Timer( delay );
				timer.addEventListener(TimerEvent.TIMER, timerHandler);
			}
			timer.start();
		}
		protected function stop():void
		{
			if(running)
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
		public function addTimerListener(delay:int, handler:Function, repeatCount:int = 0):void
		{
			var listener:TimerListener = new TimerListener(delay, handler, repeatCount);
			
			if(!listenerMap)
				listenerMap = new <TimerListener>[listener];
			else
				listenerMap.concat(new <TimerListener>[listener]);

			!running && start();
		}
		public function removeTimerListener(delay:int, handler:Function):void
		{
			if(!listenerMap)
				return;
			
			listenerMap = listenerMap.filter(function(item:TimerListener, ...rest):Boolean
			{
				return item.handler != handler && item.delay != delay;
			});
			
			(listenerMap.length == 0) && (listenerMap = null);
		}
		protected function removeListener(listener:TimerListener):void
		{
			removeTimerListener(listener.delay, listener.handler);
		}
		protected function timerHandler(event:TimerEvent):void
		{
			const delay:int = this.delay;
			position += delay;
			
			if(!listenerMap)
			{
				stop();
				return;
			}
			
			listenerMap = listenerMap.filter(function(item:TimerListener, ...rest):Boolean
			{
				return !item.test(position);
			});

			(listenerMap.length == 0) && (listenerMap = null);
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
	function TimerListener(delay:int, handler:Function, repeatCount:int = 0)
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