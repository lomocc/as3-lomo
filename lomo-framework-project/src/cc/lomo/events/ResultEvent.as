package cc.lomo.events
{
	import flash.events.Event;
	
	public class ResultEvent extends Event
	{
		public static const FAULT:String = "Fault";
		public static const RESULT:String = "Result";
		
		private var _action:String;
		private var _result:Object;
		private var _args:Object;
		private var _params:Array;
		
		public function ResultEvent(type:String, result:Object=null, action:String=null, args:Object=null, params:Array=null)
		{
			super(type);
			this._action = action;
			this._result = result;
			this._args = args;
			this._params = params;
		}
		public function get action():String
		{
			return _action;
		}
		public function get result():Object
		{
			return _result;
		}
		public function get args():Object
		{
			return _args;
		}
		public function get params():Array
		{
			return _params;
		}
		override public function clone():Event
		{
			return new ResultEvent(type, _result, _action, _args, _params);
		}
		override public function toString():String
		{
			return formatToString("ServerEvent", "type", "result", "args", "params");
		}
	}
}