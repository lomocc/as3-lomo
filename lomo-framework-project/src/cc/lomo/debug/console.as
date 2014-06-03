/**
 * Created with IntelliJ IDEA.
 * User: vincent
 * Time: 2014/4/23 10:47
 * To change this template use File | Settings | File Templates.
 */
package cc.lomo.debug
{
	import flash.external.ExternalInterface;

	public class console
	{
		public function console()
		{
		}
		
		private static function call(type:String, args:Array):void
		{
			if(ExternalInterface.available)
			{
				args = args.filter(function(p:*, ...args):String{return p && p.toString()});
				ExternalInterface.call.apply(null, [type].concat(args));
			}
		}
		/**
		 * 打印log信息 log/info/warn/error打印的文字颜色不同 (text, text, text, ..., target)
		 * @param text 文本信息
		 * @param text 文本信息
		 * @param text 文本信息
		 * ...
		 * @param target 所在的对象
		 */
		public static function log(...args):void
		{
			call("console.log", args);
		}
		/**
		 * 打印log信息 log/info/warn/error打印的文字颜色不同 (text, text, text, ..., target)
		 * @param text 文本信息
		 * @param text 文本信息
		 * @param text 文本信息
		 * ...
		 * @param target 所在的对象
		 */
		public static function info(...args):void
		{
			call("console.info", args);
		}
		/**
		 * 打印警告 (text, text, text, ..., target)
		 * @param text 文本信息
		 * @param text 文本信息
		 * @param text 文本信息
		 * ...
		 * @param target 所在的对象
		 */
		public static function warn(...args):void
		{
			call("console.warn", args);
		}
		/**
		 * 打印错误信息 (text, text, text, ..., target)
		 * @param text 文本信息
		 * @param text 文本信息
		 * @param text 文本信息
		 * ...
		 * @param target 所在的对象
		 */
		public static function error(...args):void
		{
			call("console.error", args);
		}
		/**
		 * 打印log信息 log/info/warn/error打印的文字颜色不同 (text, text, text, ..., target)
		 * @param channel 频道
		 * @param text 文本信息
		 * @param text 文本信息
		 * ...
		 * @param target 所在的对象
		 */
		public static function logch(...args):void
		{
			call("console.log", args);
		}
		/**
		 * 打印log信息 log/info/warn/error打印的文字颜色不同 (text, text, text, ..., target)
		 * @param channel 频道
		 * @param text 文本信息
		 * @param text 文本信息
		 * ...
		 * @param target 所在的对象
		 */
		public static function infoch(...args):void
		{
			call("console.info", args);
		}
		/**
		 * 打印警告 (text, text, text, ..., target)
		 * @param channel 频道
		 * @param text 文本信息
		 * @param text 文本信息
		 * ...
		 * @param target 所在的对象
		 */
		public static function warnch(...args):void
		{
			call("console.warn", args);
		}
		/**
		 * 打印错误信息 (text, text, text, ..., target)
		 * @param channel 频道
		 * @param text 文本信息
		 * @param text 文本信息
		 * ...
		 * @param target 所在的对象
		 */
		public static function errorch(...args):void
		{
			call("console.error", args);
		}
	}
}
