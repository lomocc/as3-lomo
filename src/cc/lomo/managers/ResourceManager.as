package cc.lomo.managers
{
	import cc.lomo.utils.HashMap;
	
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.core.LoaderItem;
	
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * 
	 * @author vincent 刘峰[liufeng#vertexgame.com] <br>2013-6-10 下午3:40:06
	 */
	public class ResourceManager
	{
		protected var mLoaders:HashMap = new HashMap();
		
		public function ResourceManager()
		{
		}
		
		protected function wrapVersion(url:String):String
		{
			return url;
		}
		
		protected function put(url:String, domain:ApplicationDomain=null):LoaderItem
		{
			mLoaders.put(url, new SWFLoader(wrapVersion(url), {context:new LoaderContext(false, domain || ApplicationDomain.currentDomain)});
		}
		
		public function contains(url:String):Boolean
		{
			return mLoaders.containsKey(url);
		}
		
		public function loadUI(res_id:*, onComplete:Function=null, onCompleteParams:Array=null):void
		{
			if(res_id is Array)
			{
				var needLoading:Boolean = false;
				var queue:Array = [];
				for (var i:int = 0; i < res_id.length; i++) 
				{
					var url:String = res_id[i];
					var loader:LoaderItem = mLoaders.get(url);
					if(!loader)
					{
						put(url);
					}else if(loader.status != LoaderStatus.COMPLETED && loader.status != LoaderStatus.DISPOSED)
					{
						queue.push(url);
						needLoading = true;
					}
				}
				if(needLoading)
				{
					loadMulti(queue, onComplete, onCompleteParams);
					return;
				}
			}else if(res_id is String)
			{
				if(!isLoaded(res_id))
				{
					load(res_id, onComplete, onCompleteParams);
				}
			}
			doInited();
		}
		/**
		 * 某个地址是否加载完成
		 * @param url
		 */		
		public function isLoaded(url:String):void
		{
			var loader:LoaderItem = mLoaders.get(url);
			return loader && (loader.status == LoaderStatus.COMPLETED || loader.status == LoaderStatus.DISPOSED);
		}
		
		public function load(url:String, onComplete:Function, onCompleteParams:Array, onFault:Function, onFaultParams:Array):void
		{
			if(conta)
		}
		public function loadMulti(url:Array, onComplete:Function, onCompleteParams:Array, onFault:Function, onFaultParams:Array):void
		{
			var loaderMax:LoaderMax = new LoaderMax({on})
			if(cont)
		}
	}
}