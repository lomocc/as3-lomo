package library.interfaces
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 *  
	 * @author vincent 2012年7月26日15:27:18
	 * 
	 */	
	[ExcludeClass]
	public interface IDispatchObject extends IEventDispatcher
	{
		/**
		 * 添加Command<br>
		 * 用法：addCommand(type, Command1, Command2, Command3,……)
		 * @param type 消息类型
		 * @param args 多个command
		 * 
		 */
		function addCommand(type:String, ...args):void;
		
		/**
		 * 添加多个Command
		 * @param type 事件类型
		 * @param command 对应的Command
		 * @param args type,command, type,command, type,command [,……,……]
		 */		
		function addCommands(type:String, commandClass:Class,...args):void;
		/**
		 * 移除Command<br>
		 * 用法：removeCommand(type, Command1, Command2, Command3,……)
		 * @param type 要移除的事件的类型
		 * @param args 要移除的Command类
		 */		
		function removeCommand(type:String, ...args):void;
		/**
		 * 删除多个Command 
		 * @param type
		 * @param command
		 * @param args
		 */		
		function removeCommands(type:String, commandClass:Class,...args):void;

		/**
		 * 通知Command们（只通知Command类型，不执行IEventDispatcher.dispatchEvent方法），是时候执行了
		 * @param event 消息体
		 * @return 
		 */		
		function dispatchCommand(event:Event):Boolean;
		/**
		 * 包含ICommandDispatcher.dispatchCommand,IEventDispatcher.dispatchEvent的顺序执行（先command后event）
		 * @param event 消息体
		 * @return 
		 * @see #dispatchCommand() dispatchCommand()
		 * @see flash.events.IEventDispatcher#dispatchEvent() flash.events.IEventDispatcher.dispatchEvent()
		 */
		
		function hasCommand(type:String):Boolean;
	}
}