package cc.lomo.patterns.core
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.core.LoaderCore;
	
	import flash.utils.Dictionary;
	
	import cc.lomo.consts.AppDomain;
	import cc.lomo.debug.console;
	import cc.lomo.interfaces.IPreloaderDisplay;
	import cc.lomo.managers.ResourceManager;
	import cc.lomo.patterns.observer.Notification;
	import cc.lomo.utils.Injector;
	import cc.lomo.utils.Method;
	
	public class BaseMediator extends Mediator
	{
		/**
		 * 当前加载状态 （用LoaderEvent.UNLOAD，LoaderEvent.PROGRESS，LoaderEvent.COMPLETE 来表示）
		 */		
		private var currentState:int = LoaderStatus.READY;
		
		/**
		 * CallBak
		 */		
		//		private var _methods:Array = [];
		
		/**
		 * CallBak
		 */		
		private var methodsMap:Dictionary = new Dictionary();
		private var preloader:IPreloaderDisplay;
		
		public function BaseMediator()
		{
			preloader = Injector.getInstance(IPreloaderDisplay);
		}
		
		/**
		 * @return 是否已经初始化
		 */		
		public function get inited():Boolean
		{
			return currentState == LoaderStatus.COMPLETED;
		}
		protected function addStartupNotifyListener(notificationName:String, listener:Function) : void
		{
			var methods:Array = methodsMap[notificationName];
			if(!methods)
			{
				methodsMap[notificationName] = [listener];
				addNotifyListener( notificationName, startupNotifyHandler);
			}else if(methods.indexOf(listener) == -1)
			{
				methods.push(listener);
			}
		}
		protected function removeStartupNotifyListener(notificationName:String, listener:Function=null) : void
		{
			var methods:Array = methodsMap[notificationName];
			if(methods)
			{
				if(listener != null)
				{
					methods = methods.filter(
						function(item:Function, ...args):Boolean
						{
							return item != listener;
						});
					if(methods.length == 0)
					{
						removeNotifyListener(notificationName, startupNotifyHandler);
						delete methodsMap[notificationName];
					}else
					{
						methodsMap[notificationName] = methods;
					}
				}else
				{
					removeNotifyListener(notificationName, startupNotifyHandler);
					delete methodsMap[notificationName];
				}
			}
		}
		
		private function startupNotifyHandler(note:Notification):void
		{
			if(!libraryPath)
			{
				currentState = LoaderStatus.COMPLETED;
				initView();
			}
			if(inited)
			{
				excuteCallBack(note);
				return;
			}
			if(currentState == LoaderStatus.LOADING)
			{
				return;
			}
			
			currentState = LoaderStatus.LOADING;
			ResourceManager.getInstance().addQueue(libraryPath, AppDomain.currentDomain)
				.loadQueue({onOpen:onOpen, onProgress:onResProgress, onComplete:onResComplete, method:new Method(excuteCallBack, [note])});
		}
		private function onOpen(event:LoaderEvent):void
		{
			preloader.show();
		}
		private function onResProgress(event:LoaderEvent):void
		{
			console.log(LoaderCore(event.target).progress);
			preloader.value = LoaderCore(event.target).progress;
		}
		
		private function onResComplete(event:LoaderEvent):void
		{
			currentState = LoaderStatus.COMPLETED;
			initView();
			var method:Method = event.target.vars.method;
			method.excute();
			preloader.hide();
		}
		
		protected function initView():void
		{
			
		}
		private function excuteCallBack(note:Notification):void
		{
			var methods:Array = methodsMap[note.getName()];
			if(!methods)
				return;
			//执行callback
			var temp:Array = methods.splice(0);
			for (var i:int = 0, l:int = temp.length; i < l; i++) 
			{
				var fun:Function = temp[i];
				if(fun.length == 0)
				{
					fun();
				}else
				{
					fun(note);
				}
			}
		}
		/**
		 * 依赖的资源地址  String 或者 Array of String
		 * @return 
		 */		
		protected function get libraryPath():Object
		{
			return null;
		}
	}
}