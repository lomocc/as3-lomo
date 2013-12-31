package cc.lomo.interfaces
{
	/**
	 * @author vincent 刘峰[liufeng#vertexgame.com] <br>2013-5-31 上午10:23:00
	 */
	public interface IPoolObject extends IDisposable
	{
		/**
		 * 储存的键名
		 * @return 
		 */		
		function get key():*;
		/**
		 * 
		 * @param args
		 * 
		 */		
		function reset():void;
	}
}