package cc.lomo.interfaces
{
	import flash.events.IEventDispatcher;

	public interface ITMovieClip extends IAnimatedObject,IEventDispatcher,IDisposable
	{
		function play():void;
		function stop():void;
		function pause():void;
		function set scaleTime(_s:Number):void;
		function get scaleTime():Number;
		function get loop():Boolean;
		function set loop(value:Boolean):void;

		function get isPlaying():Boolean;
		
		/**
		 *  
		 * @return 总时间 (s)
		 * 
		 */		
		function get totalTime():Number;
	}
}
