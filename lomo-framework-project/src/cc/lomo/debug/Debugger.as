package cc.lomo.debug
{
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.KeyBind;
	import com.junkbyte.console.core.Executer;
	
	import flash.display.DisplayObject;

	/**
	 * Debugger工具 输入 * 时弹出/隐藏控制台
	 * 再次封装flash console的功能，方便发布时删除无用代码
	 * @author vincent 刘峰[liufeng#vertexgame.com] <br>2013-2-21 下午4:19:17
	 * @see Debugger#log()		Debugger.log()		打印普通log
	 * @see Debugger#warn()		Debugger.warn()		打印警告信息
	 * @see Debugger#error()	Debugger.error()	打印错误信息
	 * @see Debugger#explode()	Debugger.explode()	将Object输出为String
	 * @see Debugger#bindKey()	Debugger.bindKey()	为方法绑定一个快捷键
	 */
	public class Debugger
	{
		public function Debugger()
		{
		}
		/**
		 * 初始化Debugger
		 * @param root 显示对象
		 * @param password 输入此密码时弹出/隐藏控制台
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * 
		 */		
		public static function startup(root:DisplayObject, x:Number=0, y:Number=0, width:Number=700, height:Number=300):void
		{
			CONFIG::debug
			{
				Cc.startOnStage(root, "*"); // 按"*"调出控制台 再按则关闭
				Cc.commandLine = true;
				Cc.config.commandLineAllowed = true;
				Cc.width = width;
				Cc.height = height;
				Cc.x = x;
				Cc.y = y; 
				
				Cc.displayRoller = true;
				Cc.setRollerCaptureKey("c");
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
			CONFIG::debug
			{
				Cc.log.apply(null, args);
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
		public static function info(...args):void
		{
			CONFIG::debug
			{
				Cc.info.apply(null, args);
			}
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
			CONFIG::debug
			{
				Cc.warn.apply(null, args);
			}
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
			CONFIG::debug
			{
				Cc.error.apply(null, args);
			}
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
			CONFIG::debug
			{
				Cc.logch.apply(null, args);
			}
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
			CONFIG::debug
			{
				Cc.infoch.apply(null, args);
			}
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
			CONFIG::debug
			{
				Cc.warnch.apply(null, args);
			}
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
			CONFIG::debug
			{
				Cc.errorch.apply(null, args);
			}
		}
		/**
		 * 把Object内部数据输出为String
		 * @param object 需要输出为字符串的对象
		 * @param depth
		 */		
		public static function explode(object:Object, depth:int=3):void
		{
			CONFIG::debug
			{
				Cc.explode.apply(null, arguments);
			}
		}
		/**
		 * 把Object内部数据输出为String
		 * @param channel 频道
		 * @param object 需要输出为字符串的对象
		 * @param depth
		 */		
		public static function explodech(channel:*, obj:Object, depth:int = 3):void
		{
			CONFIG::debug
			{
				Cc.explodech.apply(null, arguments);
			}
		}
		/**
		 * 绑定一个按键 （方便测试调用方法）
		 * @param key 按键的字符串或数字，如"a"（或65）
		 * @param callBack 执行的方法
		 * @param args
		 * @param shift
		 * @param ctrl
		 * @param alt
		 * @param onUp
		 * 
		 */		
		public static function bindKey(key:*, callBack:Function=null, args:Array=null, shift:Boolean=false, ctrl:Boolean=false, alt:Boolean=false, onUp:Boolean=false):void
		{
			CONFIG::debug
			{
				Cc.bindKey(new KeyBind(key, shift, ctrl, alt, onUp), callBack, args);
			}
		}
		/**
		 * 记录错误
		 */		
		public static function logError(name:String=null):void
		{
			CONFIG::debug
			{
				Cc.errorch(name || "默认", new Error());
			}
		}
		/**
		 * <ul>
		 * <li>Example:</li>
		 * <li><code>Cc.addSlashCommand("test2", function(param:String):void{Cc.log("Do the test2 with param string:", param);});</code></li>
		 * <li>user type "/test2 abc 123" in commandLine to call function with param "abc 123".</li>
		 * </ul> 
		 * @param name
		 * @param callback
		 * @param description
		 * @param alwaysAvailable
		 * @param endOfArgsMarker
		 * 
		 */		
		public static function addCommand(name:String, callback:Function, description:String = "", alwaysAvailable:Boolean = true, endOfArgsMarker:String = ";"):void
		{
			CONFIG::debug
			{
				Cc.addSlashCommand.apply(null, arguments);
			}
		}

		public static function execute(code:String, scope:*=null):*
		{
			CONFIG::debug
			{
				return Executer.Exec(scope, code);
			}
		}
	}
}