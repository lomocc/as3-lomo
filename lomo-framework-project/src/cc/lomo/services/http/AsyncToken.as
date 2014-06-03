package cc.lomo.services.http
{
	import cc.lomo.events.ResultEvent;
	import cc.lomo.interfaces.IResponder;

	public class AsyncToken
	{
		public function AsyncToken()
		{
		}
		/**
		 *  @private
		 */
		private var _responders:Array;
		
		//--------------------------------------------------------------------------
		//
		// Methods
		// 
		//--------------------------------------------------------------------------
		
		/**
		 *  <code>addResponder</code> adds a responder to an Array of responders. 
		 *  The object assigned to the responder parameter must implement
		 *  <code>mx.rpc.IResponder</code>.
		 *
		 *  @param responder A handler which will be called when the asynchronous request completes.
		 * 
		 *  @see	mx.rpc.IResponder
		 */
		public function addResponder(responderClass:Class):void
		{
			if (_responders == null)
				_responders = [];
			
			_responders.push(responderClass);
		}
		
		/**
		 * @private
		 */
		internal function applyFault(event:ResultEvent):void
		{
			if (_responders != null)
			{
				for (var i:uint = 0; i < _responders.length; i++)
				{
					var responderClass:Class = _responders[i];
					var responder:IResponder = new responderClass();
					if (responder != null)
					{
						responder.fault(event);
					}
				}
			}
		}
		
		/**
		 * @private
		 */
		internal function applyResult(event:ResultEvent):void
		{
			if (_responders != null)
			{
				for (var i:uint = 0; i < _responders.length; i++)
				{
					var responderClass:Class = _responders[i];
					var responder:IResponder = new responderClass();
					if (responder != null)
					{
						responder.result(event);
					}
				}
			}
		}
	}
}