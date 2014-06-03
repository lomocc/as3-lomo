package cc.lomo.display
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import cc.lomo.interfaces.ITMovieClip;
	import cc.lomo.managers.EnterFrameManager;
	
	public class TAnimate extends TSprite implements ITMovieClip
	{
		
		protected var mTotalTime:Number = 0;
		protected var mCurrentTime:Number = 0;
		protected var mDuration:Number = 0;
		protected var mCurrentFrame:int = 0;
		
		
		protected var mPlaying:Boolean;
		
		private var mLoop:Boolean=true;
		private var _scaleTime:Number = 0;
		
		private var enabled:Boolean = true;
		
		
		/**
		 * 一个代码驱动的MovieClip
		 * @param frameRate 默认帧速为30
		 * 
		 */		
		public function TAnimate(ui:DisplayObject = null)
		{
			super(ui);
			scaleTime = 1;
			updateStartTimes();
			drawFrame();
			EnterFrameManager.getInstance().addAnimatedObject(this);
		}
		
		public function get totalTime():Number
		{
			return mTotalTime;
		}
		
		protected function updateStartTimes():void
		{
			var _numFrames:int = numFrames;
			mTotalTime = mDuration*_numFrames;
		}
		
		/** The total number of frames. */
		protected function get numFrames():int { return 0; }
		
		public function get loop():Boolean
		{
			return mLoop;
		}
		
		public function set loop(value:Boolean):void
		{
			mLoop = value;
		}
		
		/**
		 * 时间缩放比率
		 */
		public function get scaleTime():Number
		{
			return _scaleTime;
		}
		
		/**
		 * @private
		 */
		public function set scaleTime(value:Number):void
		{
			if(_scaleTime == value) return;
			_scaleTime = value;
			//mCurrentTime *= value;
			mDuration = EnterFrameManager.TICK_RATE*value;
			mCurrentTime = mCurrentFrame * mDuration;
			updateStartTimes();
		}
		
		public function onFrame(deltaTime:Number):void
		{
			if (mLoop && mCurrentTime == mTotalTime) mCurrentTime = 0.0;
			if (!mPlaying || deltaTime == 0.0 || mCurrentTime == mTotalTime) return;
			
			mCurrentTime += deltaTime;
			
			var _numFrames:int = numFrames;
			var previousFrame:int = mCurrentFrame;
			while (mCurrentTime >= mCurrentFrame*mDuration + mDuration)
			{
				if (++mCurrentFrame == _numFrames)
				{
					if (hasEventListener(Event.COMPLETE))
					{
						dispatchEvent(new Event(Event.COMPLETE));
						
						// user might have stopped movie in event handler
						if (!mPlaying)
						{
							mCurrentTime = mTotalTime;
							mCurrentFrame = _numFrames - 1;
							break;
						}
					}
					
					if (mLoop)
					{
						mCurrentTime -= mTotalTime;
						mCurrentFrame = 0;
					}
					else
					{
						mCurrentTime = mTotalTime;
						mCurrentFrame = _numFrames - 1;
						break;
					}
				}
			}
			if(!enabled) return;
			if (mCurrentFrame != previousFrame)
			{  
				drawFrame();
			} 
			
		}
		
		protected function drawFrame():void
		{
			
		}
		
		/** Starts playback. Beware that the clip has to be added to a juggler, too! */
		public function play():void
		{
			mPlaying = true;
			EnterFrameManager.getInstance().addAnimatedObject(this);
		}
		
		/** Pauses playback. */
		public function pause():void
		{
			mPlaying = false;
			EnterFrameManager.getInstance().removeAnimatedObject(this);
		}
		
		/** Stops playback, resetting "currentFrame" to zero. */
		public function stop():void
		{
			mPlaying = false;
			currentFrame = 0;
			EnterFrameManager.getInstance().removeAnimatedObject(this);
		}
		
		
		/** Indicates if the clip is still playing. Returns <code>false</code> when the end 
		 *  is reached. */
		public function get isPlaying():Boolean 
		{
			if (mPlaying)
				return mLoop || mCurrentTime < mTotalTime;
			else
				return false;
		}
		
		protected function set currentFrame(value:int):void
		{
			mCurrentFrame = value;
			mCurrentTime =value*mDuration;
			drawFrame();
		}
		
		override public function dispose():void
		{
			enabled = false;
			EnterFrameManager.getInstance().removeAnimatedObject(this);
			super.dispose();
			
		}
		
		
	}
}