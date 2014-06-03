package cc.lomo.managers
{
	import cc.lomo.services.http.AsyncToken;
	import cc.lomo.services.http.HTTPService;
	import cc.lomo.utils.HashMap;

	public class ServiceManager
	{
		private var _url:String;
		
		private var responderMap:HashMap;
		
		public function ServiceManager(pvt:SingletonEnforcer)
		{
			if (pvt == null) 
			{ 
				throw new Error("Please use .getInstance()");
			}
		}
		public function addResponder(action:String, responderClass:Class):void
		{
			var token:AsyncToken = responderMap.get(action);
			if(!token)
			{
				token = new AsyncToken();
				responderMap.put(action, token);
			}
			token.addResponder(responderClass);
		}
		public function removeResponder(action:String):void
		{
			responderMap.remove(action);
		}
		
		public function init(url:String):void
		{
			this._url = url;
		}
		
		public function load(action:String, args:Object=null, params:Array=null):void
		{
			var asyncToken:AsyncToken = responderMap.get(action);
			if(!asyncToken)
			{
				throw new Error("必须先调用addResponder方法注册回调！");
			}
			var	service:HTTPService = new HTTPService(asyncToken);
			service.load(this._url, action, args, params);
		}
	}
}