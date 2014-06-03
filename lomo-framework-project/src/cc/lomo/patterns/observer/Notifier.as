package cc.lomo.patterns.observer
{
	import cc.lomo.patterns.core.Mediator;
	import cc.lomo.patterns.core.Proxy;
	import cc.lomo.utils.Method;

	[ExcludeClass]
	public class Notifier extends Sender
	{
		public function Notifier()
		{
		}

		public function addNotifyListener ( notificationName:String, notifyMethod:Function, notifyParams:Array=null) : void
		{
			facade.registerObserver(notificationName, new Method(notifyMethod, notifyParams, this));
		}
		
		public function removeNotifyListener( notificationName:String, notifyMethod:Function=null):void
		{
			facade.removeObserver(notificationName, this, notifyMethod);
		}
		
		public function registerProxy(proxyName:String, proxyClass:Class ) : void
		{
			facade.registerProxy(proxyName, proxyClass);
		}
		
		public function retrieveProxy( proxyName:String ) : Proxy
		{
			return facade.retrieveProxy(proxyName);
		}
		
		public function hasProxy( proxyName:String ) : Boolean
		{
			return facade.hasProxy(proxyName);
		}
		
		public function removeProxy( proxyName:String ) : Proxy
		{
			return facade.removeProxy(proxyName);
		}
		
		public function registerMediator(mediatorName:String, mediatorClass:Class ) : void
		{
			facade.registerMediator(mediatorName, mediatorClass);
		}
		
		public function retrieveMediator( mediatorName:String ) : Mediator
		{
			return facade.retrieveMediator(mediatorName);
		}
		
		public function removeMediator( mediatorName:String ) : Mediator
		{
			return facade.removeMediator(mediatorName);
		}
		
		public function hasMediator( mediatorName:String ) : Boolean
		{
			return facade.hasMediator(mediatorName);
		}
		public function registerCommand( notificationName : String, commandClassRef : Class) : void
		{
			facade.registerCommand(notificationName, commandClassRef, this);
		}
		
		public function hasCommand( notificationName:String ) : Boolean
		{
			return facade.hasCommand(notificationName);
		}
		
		public function removeCommand( notificationName : String ) : void
		{
			facade.removeCommand(notificationName, this);
		}
	}
}