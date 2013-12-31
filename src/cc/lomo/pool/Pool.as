package cc.lomo.pool
{
	import cc.lomo.interfaces.IPoolObject;
	
	import flash.utils.Dictionary;
	
	/**
	 * 
	 * @author vincent 刘峰[liufeng#vertexgame.com] <br>2013-5-31 上午10:12:37
	 */
	public class Pool
	{
		public function Pool()
		{
		}
		/**
		 * 从缓存或者 或者新建
		 * @param type
		 * @param parameters
		 * @return 
		 */		
		public static function getObject(key:*):IPoolObject
		{
			var pool:Dictionary = getPool(key);
			for(var poolObject:IPoolObject in pool) 
			{
				delete pool[poolObject];
				return poolObject;
			}
			return null;
		}
		
		/**
		 * 销毁 进入缓存 
		 * @param object
		 * @param type
		 * 
		 */		
		public static function putObject( poolObject:IPoolObject ):void
		{
			poolObject.reset();
			getPool(poolObject.key)[poolObject] = null;
		}
		////////////////////////////////////////////////////////////////////////////////
		// helper
		////////////////////////////////////////////////////////////////////////////////
		
		private static var sPoolMap:Dictionary = new Dictionary();
		private static function getPool( key:* ):Dictionary
		{
			return sPoolMap[key] ||= new Dictionary(true);
		}
	}
}