package cc.lomo.utils
{
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.core.LoaderCore;
	
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	/**
	 * 某些游戏里边用到的资源的一些管理的方法，本来是可以用ResMng里的，但是这里单独出来，这样不会影响旧的代码
	 * <br>主要实现：
	 * <li>资源版本控制</li>
	 * <li>后台加载</li>
	 * @author vincent 刘峰[liufeng#vertexgame.com] <br>2013-6-14 下午1:40:23
	 */
	public class ResUtil
	{
		/**
		 * 后台记载(手动加载) 
		 */		
		public static const MANUAL:int = 0;	
		
		/**
		 * 自动加载 
		 */		
		public static const AUTO:int = 1;	
		
		/**
		 * 条件加载 
		 */		
		public static const CONDITION:int = 2;
		
		
		/**
		 * 音效
		 */		
		public static const SOUND:int = 1;	
		/**
		 * SWF
		 */		
		public static const SWF:int = 2;	
		/**
		 * xml
		 */		
		public static const XML:int = 4;
		/**
		 * zip
		 */		
		public static const ZIP:int = 8;
		
		LoaderMax.defaultAuditSize = false;
		
		/**
		 * 在后台加载所有未加载对象的加载器 忙碌的搬运工
		 */		
		protected static var sBackendLoader:LoaderMax = new LoaderMax({/*,onProgress:progressHandler*/maxConnections:1});
		//资源缓存
		protected static var sLoaders:HashMap = new HashMap();
		
		public function ResUtil()
		{
		}
		/**
		 * 后台加载器
		 * @param urlOrArray 加载的资源 可以是"a.swf" 或者["a.swf", "b.swf"]
		 */	
		
		public static function addToBackend(url:String, domain:ApplicationDomain=null):void
		{
			var loader:SWFLoader = sLoaders.get(url);
			if(!loader)
			{
				loader = new SWFLoader(wrapVersion(url), {/*onComplete:onItemComp,*/context:new LoaderContext(false, domain)});
				sLoaders.put(url, loader);
			}
			sBackendLoader.append(loader);
		}
		
		public static function startLoadBackend():void
		{
			sBackendLoader.load();
		}
		public static function isLoaded(url:String):Boolean
		{
			return sLoaders.containsKey(url) && isLoaderLoaded(LoaderCore(sLoaders.get(url)));
		}
		
		public static function isLoading(url:String):Boolean
		{
			return sLoaders.containsKey(url) && isLoaderLoading(LoaderCore(sLoaders.get(url)));
		}
		
		private static function isLoaderLoading(loader:LoaderCore):Boolean
		{
			return loader.status == LoaderStatus.LOADING;
		}
		/**
		 * 
		 * @param urlOrArray 加载的资源 可以是"a.swf" 或者["a.swf", "b.swf"]
		 * @param onComplete
		 * @param onProgress (event.target as LoaderMax).rawProgress 进度
		 * @param domain
		 */		
		public static function load(urlOrArray:*, onComplete:Function=null, onProgress:Function=null, domain:ApplicationDomain=null):void
		{
			if(domain == null) domain = AppDomain.currentDomain;
			var loaderMax:LoaderMax = new LoaderMax({maxConnections:3, onProgress:onProgress, onComplete:onComplete, context:new LoaderContext(false, domain)/*, autoDispose:true*/});
			var loader:SWFLoader;
			var url:String;
			if(urlOrArray is Array)
			{
				for (var i:int = 0, l:int = urlOrArray.length; i < l; i++) 
				{
					url = urlOrArray[i];
					loader = sLoaders.get(url);
					if(!loader)
					{
						loader = new SWFLoader(wrapVersion(url));
						sLoaders.put(url, loader);
					}
					loaderMax.append(loader);
				}
			}else if(urlOrArray is String)
			{
				url = urlOrArray;
				loader = sLoaders.get(url);
				if(!loader)
				{
					loader = new SWFLoader(wrapVersion(url));
					sLoaders.put(url, loader);
				}
				loaderMax.append(loader);
			}
			loaderMax.load();
		}
		
		public static function loadByClassName(className:String, onComplete:Function=null, onProgress:Function=null, domain:ApplicationDomain=null):void
		{
			var url:String = SwfMapUtil.getURL(className);
			load(url, onComplete, onProgress, domain);
		}
		/**
		 * 获取一个Class 
		 * @param ref
		 * @param applicationDomain
		 * @return 
		 * 
		 */		
		public static function getClass(ref:String, applicationDomain:ApplicationDomain=null):Class
		{
			return Reflection.getClass(ref, applicationDomain) as Class;
		}
		/**
		 * 获取加载的地址里的内容 一般是图片或者音乐Sound 或者movieclip之类 替代ResCacheMng.instance.getRes
		 * @param url
		 * @return 
		 */		
		public static function getContent(url:String):*
		{
			var loader:LoaderCore = sLoaders.get(url);
			return loader && isLoaderLoaded(loader)?loader.content:null;
		}
		
		public static function createInstance(fullClassName:String, params:Array=null, applicationDomain:ApplicationDomain=null):*
		{
			return Reflection.createInstance(fullClassName, params, applicationDomain);
		}
		/**
		 * 获取一个资源是否存在 
		 * @param url
		 * @return 
		 * 
		 */		
		protected static function hasSource(url:String):Boolean
		{
			//如果有资源
			return sLoaders.containsKey(url);
		}
		
		protected static function isLoaderLoaded(loader:LoaderCore):Boolean
		{
			return loader.status == LoaderStatus.COMPLETED || loader.status == LoaderStatus.DISPOSED;
		}
		
		/**
		 * 清除内容 释放内存 
		 * 
		 */		
		public static function clearAll():void
		{
			sLoaders.eachValue(function(value:LoaderCore):void
			{
				value.dispose(true);
			});
			sLoaders.clear();
		}
		
		protected static function wrapVersion(url:String):String
		{
			return VersionUtil.wrapVersion(url);
		}
	}
}