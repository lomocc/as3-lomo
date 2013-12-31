package cc.lomo.events
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class TimelineWatcher extends EventDispatcher
	{
		protected var mMovieClip:MovieClip;
		protected var mPreviousLabel:String;
		
		public function TimelineWatcher(target:MovieClip)
		{
			super();

			mMovieClip = target;
			mMovieClip && mMovieClip.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		protected function enterFrame(event:Event):void
		{
			const cf:int = mMovieClip.currentFrame;
			const cl:String = mMovieClip.currentLabel;
			cl !== mPreviousLabel && dispatchEvent(new TimelineEvent(TimelineEvent.LABEL_REACHED, cf, cl));
			cf == mMovieClip.totalFrames && dispatchEvent(new TimelineEvent(TimelineEvent.END_REACHED, cf, cl));
			mPreviousLabel = cl;
		}
		public function dispose():void
		{
			mMovieClip && mMovieClip.removeEventListener(Event.ENTER_FRAME, enterFrame);
			mMovieClip = null;
		}
	}
}