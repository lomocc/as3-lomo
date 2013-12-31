package library.core
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import library.interfaces.IDispatchObject;
	import library.interfaces.IInjector;
	import library.interfaces.IReflector;
	
	[ExcludeClass]
	/**
	 * 处理侦听（包括Command）和派发全局事件
	 * 
	 * 无聊~ 发消息
	 * @author vincent 2012年7月25日16:28:27
	 * 
	 * @see add addCommand系列方法
	 */	
	
	public class Dispatcher extends EventDispatcher implements IDispatchObject
	{
		protected var injector:IInjector;
		protected var reflector:IReflector;
		protected var mCommandMap:Dictionary = new Dictionary();
		
		public function Dispatcher(target:IEventDispatcher, injector:IInjector, reflector:IReflector)
		{
			super(target);
			
			this.injector = injector;
			this.reflector = reflector;
		}
		
		public function addCommand(type:String, ...args):void
		{
			var classes:Vector.<Class> = mCommandMap[type];
			if(!classes)
				mCommandMap[type] = Vector.<Class>(args);
			else
				mCommandMap[type] = classes.concat(Vector.<Class>(args));
		}
		
		public function addCommands(type:String, commandClass:Class,...args):void
		{
			var len:int = args.length, i:int = 0;
			if(len == 0 || len & 1 != 0)
				return;
			
			for(; i < len; i += 2)
			{
				addCommand.apply(null, args.slice(i, i + 2));
			}
		}
		public function removeCommand(type:String, ...args):void
		{
			var classes:Vector.<Class> = mCommandMap[type];
			
			if(classes)
			{
				for each(var commandClass:Class in args)
				{
					var index:int = classes.indexOf(commandClass);
					if(index > 0)
						classes.splice(index, 1);
				}
				if(classes.length == 0)mCommandMap[type] = null;
			}
		}
		
		public function removeCommands(type:String, commandClass:Class,...args):void
		{
			var len:int = args.length, i:int = 0;
			if(len == 0 || len & 1 != 0)
				return;
			
			for(; i < len; i += 2)
			{
				removeCommand.apply(null, args.slice(i, i + 2));
			}
		}
		
		public function dispatch(event:Event):Boolean
		{
			return dispatchCommand(event) && dispatchEvent(event);
		}
		
		public function dispatchCommand(event:Event):Boolean
		{
			var classes:Vector.<Class> = mCommandMap[event.type];
			if(!classes)
				return false;
			for(var i:int = 0, l:int = classes.length; i < l; i++)
				execute(classes[i], event);
			return true;
		}
		
		public function execute(commandClass:Class, event:Event):void
		{
			var eventClass:Class= reflector.getClass(event);
			var notEvent:Boolean = eventClass != Event;
			
			notEvent && injector.mapValue(Event, event);
			injector.mapValue(eventClass, event);
			
			var command:Object = injector.instantiate(commandClass);
			
			notEvent && injector.unmap(Event);
			injector.unmap(eventClass);
			
			command.execute();
		}
		
		public function hasCommand(type:String):Boolean
		{
			var classes:Vector.<Class> = mCommandMap[type];
			return classes && classes.length > 0;
		}
	}
}