package cc.lomo.net
{
	import flash.net.SharedObject;
	
	/**
	 * 实现本地储存的简单功能 
	 * @author vincent
	 * 
	 */	
	public class LocalStorage
	{
		protected static const LAST_TIME:String = "lastTime";
		
		protected var mSharedObject:SharedObject;
		protected var mMinDiskSpace:int;
		protected var mAutoFlush:Boolean;
		
		/**
		 * 
		 * @param name 缓存的名称
		 * @param autoFlush setValue后是否自动写入缓存，如果值为false则需要手动调用flush方法写入缓存,默认值为true
		 * @param minDiskSpace 一个值，当写入的缓存大小大于这个值时将会弹出提示,默认值为0
		 * 
		 * @see #setValue() setValue()
		 * @see #flush() flush()
		 */		
		public function LocalStorage(name:String, autoFlush:Boolean = true, minDiskSpace:int = 0)
		{
			this.mSharedObject	= SharedObject.getLocal(name);
			this.mMinDiskSpace	= minDiskSpace;
			this.mAutoFlush		= autoFlush;
		}
		
		/**
		 * 设置要储存的数据,如果初始化时LocalStorage的参数autoFlush为true,那么每次调用此方法时会自动将数据写入缓存,如果值为false,那么设置之后需要手动调用flush方法才能写入缓存
		 * @param key 要设置的键名
		 * @param value 要储存的值
		 * @see #flush() flush()
		 * @see #LocalStorage() new LocalStorage()
		 */		
		public function set(key:String, value:Object):void
		{
			mSharedObject.setProperty(key, value);
			mAutoFlush && flush();
		}
		public function get(key:String):Object
		{
			return mSharedObject.data[key];
		}
		
		public function getLastTime():Date
		{
			return get(LAST_TIME) as Date;
		}
		public function get data():Object
		{
			return mSharedObject.data;
		}
		/**
		 * 将 setValue的数据写入本地缓存
		 * @see #setValue() setValue()
		 * @see #LocalStorage() new LocalStorage()
		 */		
		public function flush():void
		{
			mSharedObject.setProperty(LAST_TIME, new Date());
			try
			{
				mSharedObject.flush(mMinDiskSpace);
			}catch(e:Error){}
		}
	}
}