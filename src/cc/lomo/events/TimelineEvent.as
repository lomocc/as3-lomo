package cc.lomo.events
{
	import flash.events.Event;
	public class TimelineEvent extends Event
	{
		public static const LABEL_REACHED:String = "labelReached";
		public static const END_REACHED:String = "endReached";
		
		protected var mCurrentFrame:int;
		protected var mCurrentLabel:String;

		public function TimelineEvent(type:String, currentFrame:int = 0, currentLabel:String = null)
		{
			super(type);
			mCurrentFrame = currentFrame;
			mCurrentLabel = currentLabel;
		}
		
		override public function clone():Event
		{
			return new TimelineEvent(type, mCurrentFrame, mCurrentLabel);
		}
		
		override public function toString():String
		{
			return formatToString("TimelineEvent", "type", "bubbles", "cancelable", "eventPhase", "currentFrame", "currentLabel");
		}

		public function get currentFrame():int
		{
			return mCurrentFrame;
		}

		public function get currentLabel():String
		{
			return mCurrentLabel;
		}
	}
}