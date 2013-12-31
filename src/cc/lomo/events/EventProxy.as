package cc.lomo.events
{
	import cc.lomo.core.Singleton;
	
	import flash.events.EventDispatcher;

	/**
	 *
	 * 用于全局侦听、派发事件的类 
	 * @author vincent
	 * 
	 */	
	public class EventProxy extends EventDispatcher
	{
		public static function getInstance():EventProxy
		{
			return Singleton.getInstance( EventProxy ) as EventProxy;
		}
	}
}