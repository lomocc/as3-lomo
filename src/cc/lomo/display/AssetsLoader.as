package cc.lomo.display
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * 加载swf，通过linkName获取实例
	 * @author vincent
	 */	
	public class AssetsLoader extends Loader
	{
		protected var applicationDomain:ApplicationDomain;
		
		protected var symbolMap:Vector.<AssetsItem> = new Vector.<AssetsItem>();
		
		protected var completed:Boolean = false;
		
		public function AssetsLoader()
		{
			contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		protected function completeHandler(event:Event):void
		{
			contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			
			for each(var p:AssetsItem in symbolMap)
			{
				p.update();
			}
			
			completed = true;
		}
		/**
		 * 
		 * @param url 加载的swf地址
		 * 
		 */		
		override public function load(request:URLRequest, context:LoaderContext=null):void
		{
			super.load(request, getContext(context));
		}
		override public function loadBytes(bytes:ByteArray, context:LoaderContext=null):void
		{
			super.loadBytes(bytes, getContext(context));
		}
		protected function getContext(context:LoaderContext):LoaderContext
		{
			context == null && (context = new LoaderContext());
			context.applicationDomain == null && (context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain));
			applicationDomain = context.applicationDomain;
			return context;
		}
		/**
		 * 
		 * @param linkName 类名
		 * 
		 */	
		public function getClass(linkName:String):Class
		{trace(linkName);
			if (!applicationDomain.hasDefinition(linkName))
				throw new Error("没有在库中找到：[ " + linkName + " ]");
			return applicationDomain.getDefinition(linkName) as Class;
		}
		
		public function getAssetsItem(linkName:String):AssetsItem
		{
			var symbol:AssetsItem = new AssetsItem(this, linkName);
			if( completed )
			{
				symbol.update();
			}else
			{
				symbolMap.push( symbol );
			}
			return symbol;
		}
		public function getObject(linkName:String):Object
		{
			var Clazz:Class = getClass(linkName);
			return new Clazz();
		}
		public function getDisplayObject(linkName:String):DisplayObject
		{
			return getObject(linkName) as DisplayObject;
		}
		public function getSound(linkName:String):Sound
		{
			return getObject(linkName) as Sound;
		}
		public function getBitmapData(linkName:String):BitmapData
		{
			return getObject(linkName) as BitmapData;
		}
	}
}