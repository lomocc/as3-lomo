package cc.lomo.interfaces
{
	import flash.events.IEventDispatcher;

	/**
	 * @author vincent 刘峰[liufeng#vertexgame.com] <br>2013-6-5 下午4:19:30
	 */
	public interface IQueue extends IEventDispatcher
	{
		function excute():void;
	}
}