package cc.lomo.patterns.core
{
	import cc.lomo.patterns.observer.Notifier;

	[ExcludeClass]
	public class Mediator extends Notifier
	{
		public function Mediator()
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