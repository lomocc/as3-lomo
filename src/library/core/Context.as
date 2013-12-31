package library.core
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	
	import library.adapters.SwiftSuspendersInjector;
	import library.adapters.SwiftSuspendersReflector;
	import library.events.ContextEvent;
	import library.interfaces.IContext;
	import library.interfaces.IDispatchObject;
	import library.interfaces.IInjector;
	import library.interfaces.IReflector;
	
	/**
	 * 对事件、显示对象容器、socket进行管理
	 * @author vincent 2012年7月24日15:53:36
	 * 
	 */	
	public class Context implements IContext
	{
		protected var mRoot:DisplayObjectContainer;
		protected var mLocalDispactcher:IDispatchObject;
		protected static var mGlobalDispactcher:IDispatchObject;
		protected var mInjector:IInjector;
		protected var mReflector:IReflector;
		/**
		 * 模块的根容器
		 */		
		final public function get root():DisplayObjectContainer{return mRoot;}
		/**
		 * 用于 [模块] 内部接收和派发事件和命令的对象
		 */	
		final public function get localDispatcher():IDispatchObject{return mLocalDispactcher ||= new Dispatcher(this, createChildInjector(), reflector);}
		/**
		 * 用于 [全局] 接收和派发事件和命令的对象
		 */		
		final public function get globalDispatcher():IDispatchObject{return mGlobalDispactcher ||= new Dispatcher(this, createChildInjector(), reflector);}

		final public function get reflector():IReflector{return mReflector ||= new SwiftSuspendersReflector();}
		final public function get injector():IInjector{return mInjector ||= new SwiftSuspendersInjector(getApplicationDomain());}
		
		public function Context(root:DisplayObjectContainer)
		{
			super();
			
			mRoot = root;
			
			mapInjections();
			
			root.stage ? startup() : root.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}		
		private function onAddedToStage(e:Event):void
		{
			root.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			startup();
		}

		private function createChildInjector():IInjector
		{
			return injector.createChild(getApplicationDomain());
		}
		private function getApplicationDomain():ApplicationDomain
		{
			if (root && root.loaderInfo)
				return root.loaderInfo.applicationDomain;
			return ApplicationDomain.currentDomain;
		}
		
		protected function mapInjections():void
		{
			//injector.mapValue(IReflector, reflector);
			//injector.mapValue(IInjector, injector);
			injector.mapValue(IContext, this);
			injector.mapValue(DisplayObjectContainer, root);
		}
		
		public function startup():void
		{
			dispatch(new ContextEvent(ContextEvent.STARTUP_COMPLETE));
		}
		
		public function shutdown():void
		{
			dispatch(new ContextEvent(ContextEvent.SHUTDOWN_COMPLETE));
		}
		////////////////////////////////// local event ////////////////////////////////////
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			localDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return localDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return localDispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			localDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return localDispatcher.willTrigger(type);
		}
		
		/////////////////////////////////  local commands  ////////////////////////////////////
		
		public function addCommand(type:String, ...args):void
		{
			localDispatcher.addCommand.apply(null, [type].concat(args));
		}

		public function addCommands(type:String, commandClass:Class, ...args):void
		{
			localDispatcher.addCommands.apply(null, [type, commandClass].concat(args));
		}
		
		public function dispatchCommand(event:Event):Boolean
		{
			return localDispatcher.dispatchCommand(event);
		}
		
		public function hasCommand(type:String):Boolean
		{
			return localDispatcher.hasCommand(type);
		}
		
		public function removeCommand(type:String, ...args):void
		{
			localDispatcher.removeCommand.apply(null, [type].concat(args));
		}
		
		public function removeCommands(type:String, commandClass:Class, ...args):void
		{
			localDispatcher.removeCommands.apply(null, [type, commandClass].concat(args));
		}
		///////////////////////////////////////  global events ///////////////////////////////////
		public function addEventListenerToModule(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			globalDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function dispatchEventToModules(event:Event):Boolean
		{
			return globalDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListenerToModules(type:String):Boolean
		{
			return globalDispatcher.hasEventListener(type);
		}
		
		public function removeEventListenerToModules(type:String, listener:Function, useCapture:Boolean=false):void
		{
			globalDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		///////////////////////////////////////  global commands ///////////////////////////////////
		public function addCommandToModules(type:String, ...args):void
		{
			globalDispatcher.addCommand.apply(null, [type].concat(args));
		}
		
		public function addCommandsToModules(type:String, commandClass:Class, ...args):void
		{
			globalDispatcher.addCommands.apply(null, [type, commandClass].concat(args));
		}
		
		public function dispatchCommandToModules(event:Event):Boolean
		{
			return globalDispatcher.dispatchCommand(event);
		}
		
		public function hasCommandToModules(type:String):Boolean
		{
			return globalDispatcher.hasCommand(type);
		}
		
		public function removeCommandToModules(type:String, ...args):void
		{
			globalDispatcher.removeCommand.apply(null, [type].concat(args));
		}
		
		public function removeCommandsToModules(type:String, commandClass:Class, ...args):void
		{
			globalDispatcher.removeCommands.apply(null, [type, commandClass].concat(args));
		}

		public function dispatch(event:Event):Boolean
		{
			var result:Boolean = dispatchEvent(event);
			return dispatchCommand(event) && result;
		}
		
		public function dispatchToModules(event:Event):Boolean
		{
			var result:Boolean = dispatchEventToModules(event);
			return dispatchCommandToModules(event) && result;
		}
		
	}
}