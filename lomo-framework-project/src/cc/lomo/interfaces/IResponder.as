package cc.lomo.interfaces
{
	import cc.lomo.events.ResultEvent;

	public interface IResponder
	{
		/**
		*  This method is called by a service when the return value
		*  has been received. 
		*  While <code>data</code> is typed as Object, it is often
		*  (but not always) an mx.rpc.events.ResultEvent.
		*/
		function result(event:ResultEvent):void;
		
		/**
		 *  This method is called by a service when an error has been received.
		 *  While <code>info</code> is typed as Object it is often
		 *  (but not always) an mx.rpc.events.FaultEvent.
		 */
		function fault(event:ResultEvent):void;
	}
}