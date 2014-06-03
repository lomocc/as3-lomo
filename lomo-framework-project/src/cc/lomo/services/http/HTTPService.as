package cc.lomo.services.http
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import cc.lomo.events.ResultEvent;
	
	public class HTTPService
	{
		private var _dataFormat:String = URLLoaderDataFormat.TEXT;
		private var _method:String = URLRequestMethod.GET;
		
		private var _url:String;
		private var _action:String;
		private var _args:Object;
		private var _params:Array;
		private var _urlLoader:URLLoader;
		private var _asyncToken:AsyncToken;
		
		public function HTTPService(asyncToken:AsyncToken)
		{
			super();
			
			this._asyncToken = asyncToken;
		}
		
		public function load(url:String, action:String, args:Object, params:Array):void
		{
			this._url = url;
			this._action = action;
			this._args = args;
			this._params = params;
			
			var request:URLRequest = new URLRequest();
			request.url = _url;
			request.method = _method;
			request.data = _args;
			
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = _dataFormat;
			_urlLoader.addEventListener(Event.COMPLETE, completeHandler);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_urlLoader.load(request);
		}
		protected function errorHandler(event:Event):void
		{
			trace(event.toString());
			_asyncToken.applyFault(new ResultEvent(ResultEvent.FAULT, null, _action, _args, _params));
		}
		
		protected function completeHandler(event:Event):void
		{
			var result:*;
			switch(_dataFormat)
			{
				case URLLoaderDataFormat.BINARY:
				{
					result = ByteArray(_urlLoader.data).readObject();
					break;
				}
				case URLLoaderDataFormat.TEXT:
				{
					result = JSON.parse(String(_urlLoader.data));
					break;
				}
				default:
				{
					break;
				}
			}
			_asyncToken.applyResult(new ResultEvent(ResultEvent.RESULT, result, _action, _args, _params));
		}
	}
}