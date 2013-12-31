package library.loaders
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	
	[Event(name="complete", type="flash.events.Event")]
	/**
	 * 多语言支持
	 * 用法：<pre>
	 * load("www.e.com/lan/zh_cn.lang");
	 * completed:
	 * getString("@zh_cn.hit");
	 * </pre>
	 * @author flashyiyi
	 * modified by vincent 2012年7月31日9:32:04
	 */
	public class StringLoader extends EventDispatcher
	{
		protected var mTotalNum:uint = 0;
		protected var mCurrentNum:uint = 0;
		
		protected var resource:Object = new Dictionary();

		public function StringLoader():void
		{
			super();
		}
		
		/**
		 * 加载语言包。properties文件的格式和FLEX的多语言相同，主要为了利用IDE的代码分色。详情请参考FLEX帮助。
		 * 注意，此方法可多次使用。
		 * 
		 * @param url   语言文件路径
		 * @param args    语言文件路径们
		 * 
		 */
		public function load(url:String, ...args):void
		{
			if(mTotalNum != 0)
			{
				trace("已经加载过了");
				return;
			}
			args.unshift(url);
			mTotalNum = args.length;
			mCurrentNum = 0;
			var loader:NamedURLLoader = new NamedURLLoader();
			for(var i:int = 0, l:int = args.length; i < l; i++)
			{
				loader = new NamedURLLoader();
				loader.addEventListener(Event.COMPLETE, completeHandler);
				loader.load(new URLRequest(args[i]));
			}
		}
		
		private function completeHandler(event:Event):void
		{
			var loader:NamedURLLoader = event.currentTarget as NamedURLLoader;
			loader.removeEventListener(Event.COMPLETE, completeHandler)

			add(loader.fileName, loader.data.toString());
			
			mCurrentNum++;
			if(mCurrentNum == mTotalNum)
				dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * 增加多语言文本
		 *  
		 * @param textType      类别
		 * @param text  内容
		 * 
		 */
		public function add(textType:String,text:String):void
		{
			resource[textType] = {};
			
			//消除文件头
			if (text.charCodeAt(0) == 65279)
				text = text.slice(1);
			
			var texts:Array = text.split(/\r?\n/);
			var key:String; 
			for (var i:int=0;i < texts.length;i++)
			{
				var textLine:String = texts[i] as String;
				if (textLine && textLine.substr(0,2)!="//")
				{
					textLine = textLine.replace(/\s*(=)\s*/, "$1");

					if (/^.+=.+/.test(textLine))
					{
						var pos:int = textLine.indexOf("=");
						
						key = textLine.slice(0,pos);
						var value:String = textLine.slice(pos + 1);
						resource[textType][key] = value;
					}
					else if (key && textLine.length > 0)
					{
						resource[textType][key] += "\n" + textLine;//没有=则是上一行的继续
					}
				}
			}
		}
		
		/**
		 * 获得未经转换的多语言文本
		 * 
		 * @param res   文本标示，格式为@type.name。
		 * 不以@开头则返回原始文本，缺少.则在多个语言包里进行遍历查找
		 * @return 
		 * 
		 */             
		public function getOriginString(res:String):String
		{
			var bundle:Object;
			var result:String;
			if (res.charAt(0)=="@")
			{
				if (res.charAt(res.length - 1)=="\r")
					res = res.slice(0,res.length - 1);
				
				var dot:int = res.indexOf(".");
				if (dot == -1)
				{
					for each(bundle in resource)
					{
						result = bundle[res.slice(1)];
						if (result)
							return result;
					}
				}
				else
				{
					bundle = resource[res.slice(1,dot)];
					if (bundle && bundle[res.slice(dot + 1)])
						return bundle[res.slice(dot + 1)];
				}
			}
			return res;
		}
		
		/**
		 * 获得经过转换的文本
		 * 
		 * @param res   文本标示，格式为@文件名.标签名
		 * @param parms 替换参数，将会按顺序替换文本里的{0},{1},{2}
		 * @return 
		 * 
		 */             
		public function getString(res:String, ...args):String
		{
			var result:String = getOriginString(res);
			
			if (result == null)
				return null;
			else
				return result.replace(/\{(.+?)\}/g,replaceFun);
			
			function replaceFun(matchedSubstring:String,capturedMatch:String,index:int,str:String):String 
			{ 
				var n:Number = parseFloat(capturedMatch);
				if (!isNaN(n))
				{
					if (n < args.length)
						return args[n];
				}
				else
				{
					return getString(capturedMatch);
				}
				return capturedMatch;
			}
		}
	}
}
import flash.net.URLLoader;
import flash.net.URLRequest;

class NamedURLLoader extends URLLoader
{
	/**
	 * 文件名（不带后缀）
	 */	
	public var fileName:String;
	override public function load(request:URLRequest):void
	{
		fileName = request.url.replace(/^.*\/|\..*$/g, "");
		super.load(request);
	}
}