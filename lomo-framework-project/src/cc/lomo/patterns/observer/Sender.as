package cc.lomo.patterns.observer
{
	[ExcludeClass]
	public class Sender
	{
		public function Sender()
		{
		}
		
		public function sendNotification( notificationName:String, body:Object=null, type:String=null ):void 
		{
			facade.sendNotification( notificationName, body, type );
		}
		
		// Local reference to the Facade Singleton
		protected var facade:Facade = Facade.getInstance();
	}
}