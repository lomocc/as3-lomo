package library.utils
{
	import flash.utils.Dictionary;

	/**
	 *
	 * 单例类型的注册中心，用{key:Class, value:new Class()}方式来存取其他单实例类型  
	 * @see cc.lomo.proxy.TimerProxy
	 * @author vincent 2011年12月1日
	 * 
	 */	
	public class Singleton
	{
		protected static var classMap:Dictionary = new Dictionary();
		
		public static function getInstance(cls:Class):Object
		{
			return classMap[cls] ||= new cls;
		}
		public static function deleteInstance(cls:Class):void
		{
			delete classMap[cls];
		}
	}
}