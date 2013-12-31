package cc.lomo.queue
{
	import cc.lomo.interfaces.IQueue;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="complete",type="flash.events.Event")]
	
	public class Queue extends EventDispatcher
	{
		protected var mQueue:Vector.<IQueue> = new <IQueue>[];
		
		public function Queue()
		{
		}
		
		public function addCommand(item:IQueue):void
		{
			item.addEventListener(Event.COMPLETE, itemComplete);
			mQueue.push(item);
		}
		public function excute():void
		{
			executeNext();
		}
		
		private function itemComplete(event:Event):void
		{
			IQueue(event.target).removeEventListener(Event.COMPLETE, itemComplete);
			executeNext();
		}
		
		protected function executeNext():void
		{
			if(mQueue.length > 0)
			{
				mQueue.pop().excute();
			}else
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
	}
}