package cc.lomo.display
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	[Event(name="complete", type="flash.events.Event")]
	
	public class TMovieClipExt extends TMovieClip
	{
		private var cFrame:Number = 1;
		
		public function TMovieClipExt(_mc:MovieClip)
		{
			super(_mc);
		}
		
		override public function onFrame(deltaTime:Number):void
		{
			if(!isPlaying || _mc == null) return;
			if(cFrame>=_mc.totalFrames)
			{
				if(loop)
				{
					cFrame = 1;
					_mc.gotoAndPlay(1);
				}else
				{
					_mc.gotoAndStop(_mc.totalFrames);
					pause();
				}
				dispatchEvent(new Event(Event.COMPLETE));
			}
			cFrame++;
		}
		
		/**
		 * 开始播放 
		 * 
		 */		
		override public function play():void
		{
			super.play();
			if(_mc==null) return;
			_mc.play();
		}
		
		override public function pause():void
		{
			super.pause();
			if(_mc==null) return;
			_mc.stop();
		}
		
		/**
		 * 停止播放  
		 * 
		 */		
		override public function stop():void
		{
			super.stop();
			cFrame = 1;
			if(_mc==null) return;
			_mc.gotoAndStop(1);
		}
	
	}
}