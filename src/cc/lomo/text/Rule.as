package cc.lomo.text
{
	import flash.utils.Dictionary;

	/**
	 * 
	 * @author vincent
	 * 文本的规则
	 * 使用addRule添加规则
	 * 
	 */	
	public class Rule
	{
		protected var ruleMap:Dictionary = new Dictionary();
		
		internal var prefix:String = "[type#";//用来识别图形名的前缀
		
		internal var suffix:String = "]";//后缀
		
		internal var regexp:RegExp = /(\[type#.+?\])/;//[0xfafaf]
		
		internal var innerRegexp:RegExp = /^\[type#|\]$/g;
		
		public function Rule()
		{
		}
		/**
		 * 代表动画表情的格式
		 * 如 [#gif1],[#gif2],则前缀为"[#" 后缀为"]"
		 * @param prefix 图标前缀
		 * @param suffix 图标后缀
		 * 
		 */		
		public function setPrefixAndSuffix(prefix:String, suffix:String):void
		{
			this.prefix = prefix;
			this.suffix = suffix;
			
			prefix = regString(prefix);
			suffix = regString(suffix);
			
			this.regexp = new RegExp("(" + prefix + ".+?" + suffix + ")");
			this.innerRegexp = new RegExp("^" + prefix + "|" + suffix + "$", "g");
		}
		/**
		 * 
		 * @param $name 文本框中的名字 [type#XXX]
		 * @param $source 要显示的图形(url地址,Class,显示对象)
		 * 再次添加则覆盖
		 * 
		 */
		public function addRule($name:String, $source:Object):void
		{
			ruleMap[$name] = $source;
		}
		/**
		 * 获取名为$name的图形
		 * @param $name
		 * @return 
		 * 
		 */		
		public function getRule($name:String):Object
		{
			return ruleMap[$name];
		}
		/**
		 * 删除名为$name的图形规则
		 * @param $name
		 * 
		 */		
		public function removeRule($name:String):void
		{
			delete ruleMap[$name];
		}
		/**
		 * 删除所有规则 
		 * @param $name
		 * @param $source
		 * 
		 */		
		public function removeAllRules($name:String, $source:Object):void
		{
			ruleMap = new Dictionary();
		}
		
		//======================================================\\
		
		protected static var SPECIAL:RegExp = /(?=[\\\[\](){}<>^$-.?*])/g;
		
		/**
		 * 用来给特殊字符加转义 
		 */	
		protected static function regString(value:String):String
		{
			if(!value)
				return "";
			return value.replace(SPECIAL, "\\");
		}
	}
}