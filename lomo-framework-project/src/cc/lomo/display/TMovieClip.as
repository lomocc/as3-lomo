package cc.lomo.display
{
	import flash.display.MovieClip;
	
	public class TMovieClip extends TAnimate
	{
		
		protected var _mc:MovieClip;
		private var _numFrames:int; 
		/**
		 * 一个代码驱动的MovieClip 
		 * @param _mc 普通的Mc动画
		 * @param frameRate 默认帧速为30
		 * 
		 */		
		public function TMovieClip(_mc:MovieClip)
		{
			this._mc=_mc;
			_numFrames = _mc.totalFrames;
			super(_mc);
		}
		
		
		/** The total number of frames. */
		override protected function get numFrames():int { return _numFrames; }
		
		
		
		override protected function drawFrame():void
		{
			_mc.gotoAndStop(mCurrentFrame+1);
		}
		
		
		override public function dispose():void
		{
			super.dispose();
			_mc=null;
		}
	
		
		public function get sourceMc():MovieClip
		{
			return _mc;
		}
		
		/**
		 * 把一个普通MovieClip包装成TMovieClip
		 * @param mc
		 * @return 
		 * 
		 */		
		public static function wrapMC(mc:MovieClip):TMovieClip
		{
			return new TMovieClip(mc);
		}
		
		
	}
}