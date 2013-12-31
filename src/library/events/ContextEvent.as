package library.events
{
	import flash.events.Event;

	public class ContextEvent extends EventBase
	{

		public static const STARTUP_COMPLETE:String		= "startupComplete";
		
		public static const SHUTDOWN_COMPLETE:String	= "shutdownComplete";
		
		public function ContextEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ContextEvent(type, bubbles, cancelable);
		}
	}
}