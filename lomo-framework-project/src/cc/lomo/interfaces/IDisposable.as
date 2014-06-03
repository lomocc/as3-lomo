package cc.lomo.interfaces
{
	/**
	 * 定义该类可以被销毁 
	 * @author heven
	 * 
	 */	
	public interface IDisposable 
	{
		
		/**
		 * 销毁 释放内存 
		 * 
		 */		
		function dispose() : void;		
	}

}