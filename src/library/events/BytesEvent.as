package library.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import library.events.EventBase;
	
	/**
	 * 
	 * @author vincent 2012年7月26日12:03:10
	 * 
	 */	
	public class BytesEvent extends EventBase
	{
		public static const READ_COMPLETE:String		= "readComplete";
		public static const READ_ERROR:String			= "readError";
		
		public static const PARSE_COMPLETE:String	= "parseComplete";
		public static const PARSE_ERROR:String			= "parseError";
		
		public static const FLUSH_COMPLETE:String	= "flushComplete";
		public static const FLUSH_ERROR:String			= "flushError";
		
		public var bytes:ByteArray;

		public function BytesEvent(type:String, bytes:ByteArray=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.bytes = bytes;
		}
		override public function clone():Event
		{
			return new BytesEvent(type, bytes, bubbles, cancelable);
		}
	}
}