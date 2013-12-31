package cc.lomo.display
{	
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 增加移除所有事件，修正Event.ADDED_TO_STAGE和 stage Event.RESIZE时stage宽高为0的问题。
	 * @author vincent
	 * 
	 */	
	public class Document extends Sprite
	{
		/**
		 * listenerMap用来储存addEventListener添加的事件
		 * @see #addEventListener() addEventListener()
		 */
		protected var mListenerMap:Vector.<EventListener>;
		/**
		 * constructor 
		 * 
		 */		
		public function Document()
		{
			stage && stage.addEventListener(Event.RESIZE, resizeHandler, false, 1);
			addOnceEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 1);
		}
		private function addedToStageHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			
			stage.align = "TL";
			stage.scaleMode = "noScale";
			
			stage.addEventListener(Event.RESIZE, resizeHandler, false, 1);
			resizeHandler();
		}
		
		private function resizeHandler(event:Event=null):void
		{
			if(stage.stageWidth > 0 && stage.stageHeight > 0)
			{
				stage.removeEventListener(Event.RESIZE, resizeHandler);
				//Event.ADDED_TO_STAGE
				dispatchEvent(new Event(Event.ADDED_TO_STAGE));
				//Event.RESIZE
				stage.dispatchEvent(new Event(Event.RESIZE));
			}else event && event.stopImmediatePropagation();
		}
		
		/**
		 * 重写addEventListener,用来储存事件,以便一次性removeAllEventListeners
		 * @param type
		 * @param listener
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 * @see #listenerMap listenerMap
		 * @see #removeAllEventListeners() removeAllEventListeners()
		 */		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if(hasEventListenerStrict(type, listener, useCapture))
				return;
			const el:EventListener = new EventListener(type, listener, useCapture);
			if(!mListenerMap)
				mListenerMap = new <EventListener>[el];
			else
				mListenerMap = mListenerMap.concat(new <EventListener>[el]);
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public function hasEventListenerStrict(type:String, listener:Function, useCapture:Boolean=false):Boolean
		{
			return mListenerMap && mListenerMap.some(
				function(item:EventListener, ...rest):Boolean
				{ return item.type == type && item.listener == listener && item.useCapture == useCapture; });
		}
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if(!mListenerMap)
				return;
			mListenerMap = mListenerMap.filter(
				function(item:EventListener, ...rest):Boolean
				{ return !(item.type == type && item.listener == listener && item.useCapture == useCapture); });
			
			if (mListenerMap.length == 0)
				mListenerMap = null;
			super.removeEventListener(type, listener, useCapture);
		}
		/**
		 * 一次性移除所有添加的事件（addEventListener时添加到listenerMap中）
		 * @see #listenerMap listenerMap
		 * @see #addEventListener() addEventListener()
		 */
		public function removeAllEventListeners():void
		{
			if(!mListenerMap)
				return;
			for each(var p:EventListener in mListenerMap)
			{
				super.removeEventListener(p.type, p.listener, p.useCapture);
			}
			mListenerMap = null;
		}
		public function removeAllChildren():void
		{
			var n:int = numChildren;
			while(n-- > 0)
			{
				removeChildAt(0);
			}
		}
		/**
		 * 添加侦听一次就移除的事件
		 * @param type
		 * @param listener
		 * 
		 */		
		public function addOnceEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			addEventListener(
				type,
				function(event:Event):void{
					removeEventListener(type, arguments.callee, useCapture);
					listener.length == 0 ? listener():listener.apply(null, [event]);
				},
				useCapture,
				priority,
				useWeakReference
			);
		}
	}
}
class EventListener
{
	public var type:String;
	public var listener:Function;
	public var useCapture:Boolean;
	
	public function EventListener(type:String, listener:Function, useCapture:Boolean)
	{
		this.type = type;
		this.listener = listener;
		this.useCapture = useCapture;
	}
}
