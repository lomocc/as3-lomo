package cc.lomo.display
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import cc.lomo.consts.AppDomain;
	import cc.lomo.debug.console;
	import cc.lomo.managers.ResourceManager;

	public class Image extends Sprite
	{
		protected var _url:String;
		protected var _ref:String;

		public function Image(url:String, ref:String=null)
		{
			super();

			_url = url;
			_ref = ref;

			load();
		}

		private function load():void
		{
			showLoading();
			ResourceManager.getInstance().load(_url, AppDomain.singleDomain, {onPogress:onProgress, onComplete:onComplete});
		}
		
		private function onProgress(event:LoaderEvent):void
		{
			var progress:Number = LoaderMax(event.target).rawProgress;
			updateLoading(progress);
		}

		protected function updateLoading(value:Number):void
		{
			console.log(value);
			trace(value);
		}

		private function onComplete(event:LoaderEvent):void
		{
			hideLoading();
			showContent();
		}
		
		protected function showLoading():void
		{
			
		}
		
		protected function hideLoading():void
		{
			
		}

		protected function showContent():void
		{
			var display:DisplayObject;
			if(_ref)
			{
				display = ResourceManager.getInstance().createInstance(_ref, _url);
			}else
			{
				display = ResourceManager.getInstance().getContent(_url);
			}
			addChild(display);
		}
		
		/**
		 * 销毁
		 */
		public function dispose():void
		{
			hideLoading();
		}
	}
}