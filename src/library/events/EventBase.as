package library.events
{
	import flash.events.Event;
	
	import library.core.Command;
	import library.core.Dispatcher;
	import library.core.Context;
	
	import mx.core.mx_internal;
	
	/**
	 * 事件父类类，不作为普通事件发送。方便调试
	 * @author vincent 2012年7月24日15:55:23
	 * 
	 */	
	public class EventBase extends Event
	{
		public function EventBase(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}