package cc.lomo.managers
{
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.core.LoaderCore;
	
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	public class ResourceManager
	{
		/**
		 * 主要的加载器
		 */		
		protected var mainLoader:LoaderMax;
		protected var loaderMap:Dictionary;
		
		protected var queue:Array = [];
		LoaderMax.defaultAuditSize = false;
		
		public function ResourceManager(pvt:SingletonEnforcer)
		{
			if (pvt == null) 
			{ 
				throw new Error("Please use .getInstance()");
			}
			
			mainLoader = new LoaderMax();
			mainLoader.maxConnections = 5;
			
			loaderMap = new Dictionary();
		}
		
		private function createLoader(url:String, applicationDomain:ApplicationDomain=null, vars:Object=null):LoaderCore
		{
			var loader:LoaderCore = loaderMap[url];
			if(!loader)
			{
				if(applicationDomain)
				{
					if(!vars)
					{
						vars = {};
					}
					vars.context = new LoaderContext(false, applicationDomain);
				}
				loader = LoaderMax.parse(url, vars);
				loaderMap[url] = loader;
			}
			return loader;
		}
		
		private function isLoaderLoaded(loader:LoaderCore):Boolean
		{
			return loader.status == LoaderStatus.COMPLETED || loader.status == LoaderStatus.DISPOSED;
		}
		
		public function load(url:Object, applicationDomain:ApplicationDomain=null, vars:Object=null, prioritize:Boolean=false):void
		{
			var moduleLoader:LoaderMax = new LoaderMax(vars);
			moduleLoader.autoLoad = true;
			var loader:LoaderCore;
			if(url is String)
			{
				loader = createLoader(url as String, applicationDomain);
				moduleLoader.append(loader);
			}else if(url is Array)
			{
				for (var i:int = 0, l:int = url.length; i < l; i++) 
				{
					loader = createLoader(url[i], applicationDomain);
					moduleLoader.append(loader);
				}
			}
			mainLoader.append(moduleLoader);
			prioritize && moduleLoader.prioritize();
		}
		/**
		 * 加入待加载url, 下一次调用load时将会加载之前append的url
		 * @param url String or Array
		 * @param applicationDomain
		 * @param vars
		 */		
		public function addQueue(url:Object, applicationDomain:ApplicationDomain=null, vars:Object=null):ResourceManager
		{
			var loader:LoaderCore;
			if(url is String)
			{
				loader = createLoader(url as String, applicationDomain, vars);
				queue.push(loader);
			}else if(url is Array)
			{
				for (var i:int = 0, l:int = url.length; i < l; i++) 
				{
					loader = createLoader(url[i], applicationDomain, vars);
					queue.push(loader);
				}
			}
			return this;
		}
		/**
		 * 开始加载 append,append,append,loadQueue
		 * @param vars
		 * @see cc.lomo.managers.ResourceManager#append()
		 */		
		public function loadQueue(vars:Object=null, prioritize:Boolean=false):void
		{
			if(queue.length == 0)
				return;
			var moduleLoader:LoaderMax = new LoaderMax(vars);
			moduleLoader.autoLoad = true;
			for(var i:int = 0, l:int = queue.length; i < l; i++)
			{
				moduleLoader.append(queue[i]);
			}
			queue.length = 0;
			mainLoader.append(moduleLoader);
			prioritize && moduleLoader.prioritize();
		}
		public function unload(url:String):void
		{
			var loader:LoaderCore = loaderMap[url];
			if(loader)
			{
				loader.dispose(true);
				delete loaderMap[url];
			}
		}
		/**
		 * 尝试缓存
		 * @param urls [url, url, url, url]
		 */		
		public function backendLoad(urls:Array):void
		{
			if(!urls || urls.length == 0)
				return;
			var lazyLoader:LoaderMax = new LoaderMax();
			lazyLoader.autoDispose = true;
			lazyLoader.maxConnections = 1;
			for(var i:int = 0, l:int = urls.length; i < l; i++)
			{
				lazyLoader.append(new DataLoader(urls[i]));
			}
			lazyLoader.load(true);
		}
		
//		public function isLoaded(urls:Array):Boolean
//		{
//			for(var i:int = 0, l:int = urls.length; i < l; i++)
//			{
//				var loader:LoaderCore = loaderMap[urls[i]];
//				if(!loader || !isLoaderLoaded(loader))
//				{
//					return false;
//				}
//			}
//			return true;
//		}
		
		public function getClass(fullClassName:String, applicationDomainOrURL:Object=null):Class
		{
			if(applicationDomainOrURL is String)
			{
				var loader:SWFLoader = loaderMap[applicationDomainOrURL];
				if(loader)
				{
					return loader.getClass(fullClassName);
				}
			}else
			{
				var applicationDomain:ApplicationDomain = applicationDomainOrURL as ApplicationDomain || ApplicationDomain.currentDomain;
				if(applicationDomain.hasDefinition(fullClassName))
					return applicationDomain.getDefinition(fullClassName) as Class;
			}
			return null;
		}
		
		public function createInstance(fullClassName:String, applicationDomainOrURL:Object=null):*
		{
			var defClazz:Class = getClass(fullClassName, applicationDomainOrURL);
			return defClazz?new defClazz():null;
		}
		
		public function getContent(url:String):*
		{
			var loader:LoaderCore = loaderMap[url];
			return loader && loader.content;
		}
		
		LoaderMax.activate([SWFLoader, DataLoader, MP3Loader]);
		
		private static var _instance:ResourceManager;
		
		public static function getInstance():ResourceManager
		{
			return _instance ||= new ResourceManager(new SingletonEnforcer());
		}
	}
}