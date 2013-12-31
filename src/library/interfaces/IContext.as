package library.interfaces
{
	import flash.events.Event;

	public interface IContext extends IDispatchObject
	{
		/**#模块
		 * 添加Command<br>
		 * 用法：addCommand(type, Command1, Command2, Command3,……)
		 * @param type 消息类型
		 * @param args 多个command
		 * 
		 */
		function addCommandToModules(type:String, ...args):void;
		
		/**#模块
		 * 添加多个Command
		 * @param type 事件类型
		 * @param command 对应的Command
		 * @param args type,command, type,command, type,command [,……,……]
		 */		
		function addCommandsToModules(type:String, commandClass:Class,...args):void;
		/**#模块
		 * 移除Command<br>
		 * 用法：removeCommand(type, Command1, Command2, Command3,……)
		 * @param type 要移除的事件的类型
		 * @param args 要移除的Command类
		 */		
		function removeCommandToModules(type:String, ...args):void;
		/**#模块
		 * 删除多个Command 
		 * @param type
		 * @param command
		 * @param args
		 */		
		function removeCommandsToModules(type:String, commandClass:Class,...args):void;
		
		/**#模块
		 * 通知Command们（只通知Command类型，不执行IEventDispatcher.dispatchEvent方法），是时候执行了
		 * @param event 消息体
		 * @return 
		 */		
		function dispatchCommandToModules(event:Event):Boolean;
		/**#模块
		 * 包含ICommandDispatcher.dispatchCommand,IEventDispatcher.dispatchEvent的顺序执行（先command后event）
		 * @param event 消息体
		 * @return 
		 * @see #dispatchCommand() dispatchCommand()
		 * @see flash.events.IEventDispatcher#dispatchEvent() flash.events.IEventDispatcher.dispatchEvent()
		 */
		function dispatch(event:Event):Boolean;
		/**#模块
		 * 发送时间和命令到各个Module
		 * @param event
		 * @return 
		 * 
		 */		
		function dispatchToModules(event:Event):Boolean;
		
		/**#模块
		 * 是否已存在type类型的模块Command
		 * @param type
		 * @return 
		 * 
		 */		
		function hasCommandToModules(type:String):Boolean;

		///////////////////////////////////// events ////////////////////////////////////////////////
		/**#模块
		 * 侦听模块之间的事件
		 * @param type
		 * @param listener
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 * 
		 */		
		function addEventListenerToModule(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void;
		/**#模块
		 * 移除模块事件
		 * @param type
		 * @param listener
		 * @param useCapture
		 * 
		 */		
		function removeEventListenerToModules(type:String, listener:Function, useCapture:Boolean=false):void;
		/**#模块
		 * 发送模块事件
		 * @param event
		 * @return 
		 * 
		 */		
		function dispatchEventToModules(event:Event):Boolean;
		/**#模块
		 * 是否存在type类型的模块事件
		 * @param type
		 * @return 
		 * 
		 */		
		function hasEventListenerToModules(type:String):Boolean;
	}
}