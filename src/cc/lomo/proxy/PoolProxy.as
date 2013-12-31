package cc.lomo.proxy
{
	import cc.lomo.core.Singleton;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	public class PoolProxy
	{
		protected var poolMap:Dictionary;
		
		/**
		 * 从对象池里取出来（没有的话就实例化新的）
		 * @param class
		 * 
		 */
		public function pop(cls:Class):Object
		{
			var type:String = getQualifiedClassName(cls);
			
			if (poolMap)
			{
				var instances:Dictionary = poolMap[type];
				if(instances)
				{
					for(var p:Object in instances)
					{
						delete instances[p];
						return p;
					}
				}
			}
			return new cls();
		}
		/**
		 * 往对象池里存 （回收）
		 * @param instance
		 * 
		 */
		public function push(instance:Object):void
		{
			if(!poolMap)
				poolMap = new Dictionary();
			
			var type:String = getQualifiedClassName(instance);
			
			poolMap[type] ||= new Dictionary(true);
			
			poolMap[type][instance] = null;
		}
		/**
		 * 清空对象池中某个类型的所有实例 
		 * @param cls 类型
		 * 
		 */		
		public function clear(cls:Class = null):void
		{
			var type:String = getQualifiedClassName(cls);
			
			if (type && poolMap)
				delete poolMap[type];
			else
				poolMap = null;
		}
		public function length(cls:Class):int
		{
			var type:String = getQualifiedClassName(cls);
			var l:int = 0;
			if (poolMap)
			{
				var instances:Dictionary = poolMap[type];
				if(instances)
				{
					for(var p:Object in instances)
						l ++;
				}
			}
			return l;
		}
		/**
		 * 
		 * @return 
		 * 
		 */		
		public static function getInstance():PoolProxy
		{
			return Singleton.getInstance( PoolProxy ) as PoolProxy;
		}
	}
}