package cc.lomo.interfaces
{
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;

	public interface ILayer extends IDisposable,IEventDispatcher
	{
		
		/**
		 * 获取该层名称 
		 * @return 
		 * 
		 */		
		function get name():String;
		
		/**
		 *显示该层 
		 * 
		 */		
		function show():void;
		
		/**
		 * 隐藏该层  
		 * 
		 */		
		function hide():void;
		
		/**
		 * 显示状态 
		 * 
		 */		
		function get isShowing():Boolean;
		/**
		 * 清空层内容 
		 * 
		 */		
		function clear():void;
		/**
		 * 清除层内容 
		 * 
		 */		
		function clearAndDispose():void;
		
		/**
		 * 增加显示内容 
		 * 
		 */		
		function addContent(child:DisplayObject):void;
		
	}
}