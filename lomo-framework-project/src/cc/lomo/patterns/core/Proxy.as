package cc.lomo.patterns.core
{
	import cc.lomo.patterns.observer.Sender;

	[ExcludeClass]
	public class Proxy extends Sender
	{
		public function Proxy()
		{
		}
		
		/**
		 * Called by the View when the Mediator is registered
		 */ 
		public function onRegister( ):void {}
		
		/**
		 * Called by the View when the Mediator is removed
		 */ 
		public function onRemove( ):void {}
	}
}