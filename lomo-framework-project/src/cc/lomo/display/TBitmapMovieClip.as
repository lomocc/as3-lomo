package cc.lomo.display
{
    import flash.display.Bitmap;
    import flash.display.PixelSnapping;
    import flash.events.Event;
    
    
    /** Dispatched whenever the movie has displayed its last frame. */
    [Event(name="complete", type="flash.events.Event")]
    
    
    public class TBitmapMovieClip extends TAnimate
    {
        private var mFrames:/*Vector.<Frame>*/Array;
       // private var mStartTimes:/*Vector.<Number>*/Array = [];
        

		private var canvas:Bitmap = new Bitmap(null,PixelSnapping.AUTO,true);
		private var mFrameIndexs:/*Vector.<int>*/Array;
		private var currentIndex:int = -1;
        
        /** Creates a moviclip from the provided textures and with the specified default framerate.
         *  The movie will have the size of the first frame. */  
        public function TBitmapMovieClip(mFrames:/*Vector.<Frame>*/Array,frameIndexs:/*Vector.<int>*/Array)
        {            
			this.mFrames = mFrames;
			this.mFrameIndexs = frameIndexs;
			super(canvas);
        }
		
        
		public function get frameIndexs():/*Vector.<int>*/Array
		{
			return mFrameIndexs;
		}

		public function set frameIndexs(value:/*Vector.<int>*/Array):void
		{
			mFrameIndexs = value;
			updateStartTimes();
		}

		override protected function drawFrame():void
		{
			var previousIndex:int = currentIndex;
			currentIndex = frameIndexs[mCurrentFrame];
			if(currentIndex != previousIndex)
			{
				
				var frame:Frame = mFrames[currentIndex];
				canvas.bitmapData = frame.bitmapData;
				canvas.x = -frame.pivotX;
				canvas.y = -frame.pivotY;
			}
		}
		
        /** Always returns <code>false</code>. */
        public function get isComplete():Boolean 
        {
            return false;
        }
        
        override protected function get numFrames():int { return frameIndexs.length; }
        
   
        
		override protected function set currentFrame(value:int):void
		{
			mCurrentFrame = value;
			mCurrentTime = 0.0;
			
			for (var i:int=0; i<value; ++i)
				mCurrentTime += mDuration;
			
			drawFrame();
			
		}
		
		
		
		override public function dispose():void
		{
			super.dispose();
			
			mFrames/*Vector.<Frame>*/ = null;
			//mStartTimes/*Vector.<Number>*/ = null;
			canvas = null;
			mFrameIndexs/*Vector.<int>*/ = null;
		}
    }
}