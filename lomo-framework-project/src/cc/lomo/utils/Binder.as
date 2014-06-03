package cc.lomo.utils
{
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	/**
	 * 绑定
	 * @author vincent 刘峰[liufeng#vertexgame.com] <br>2013年5月22日15:25:37
	 */
	public class Binder
	{
		private var _watchers:Array = [];
		
		public function Binder()
		{
		}
		/**
		 * 清理（在不使用时需要调用这个方法）
		 */		
		public function unBinding():void
		{
			for each (var item:ChangeWatcher in _watchers) 
			{
				item.unwatch();
			}
			_watchers.length = 0;
		}
		/**
		 * 绑定属性
		 * @param site 对象
		 * @param prop 属性名
		 * @param host 源对象
		 * @param chain 属性[链]
		 * @param commitOnly
		 * @param useWeakReference
		 */		
		public function bindProperty(site:Object, prop:String,
									 host:Object, chain:Object,
									 commitOnly:Boolean = false,
									 useWeakReference:Boolean = false):void
		{
			_watchers.push(BindingUtils.bindProperty(site,prop,host,chain,commitOnly,useWeakReference));
		}
		
		/**
		 * 绑定方法
		 * @param setter 方法
		 * @param host 源对象
		 * @param chain 属性[链]
		 * @param commitOnly
		 * @param useWeakReference
		 * 
		 */		
		public function bindSetter(setter:Function, host:Object,
								   chain:Object,
								   commitOnly:Boolean = false,
								   useWeakReference:Boolean = false):void
		{
			_watchers.push(BindingUtils.bindSetter(setter,host,chain,commitOnly,useWeakReference));
		}
	}
}