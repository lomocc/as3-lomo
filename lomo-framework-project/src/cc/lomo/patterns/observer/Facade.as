package cc.lomo.patterns.observer
{
	import flash.utils.Dictionary;
	
	import cc.lomo.patterns.command.ICommand;
	import cc.lomo.patterns.core.Mediator;
	import cc.lomo.patterns.core.Proxy;
	import cc.lomo.utils.Injector;
	import cc.lomo.utils.Method;
	
	public class Facade
	{
		// Mapping of Notification names to Observer lists
		protected var observerMap : Dictionary = new Dictionary();
		// Mapping of proxyNames to IProxy instances
		protected var proxyMap : Dictionary = new Dictionary();
		// Mapping of Notification names to Command Class references
		protected var commandMap : Dictionary = new Dictionary();
		// Mapping of Mediator names to Mediator instances
		protected var mediatorMap : Dictionary = new Dictionary();
		
		public function Facade()
		{
		}
		
		/**
		 * Create and send an <code>INotification</code>.
		 * 
		 * <P>
		 * Keeps us from having to construct new notification 
		 * instances in our implementation code. </P>
		 * @param notificationName the name of the notiification to send
		 * @param body the body of the notification (optional)
		 * @param type the type of the notification (optional)
		 */ 
		public function sendNotification( notificationName:String, body:Object=null, type:String=null ):void 
		{
			notifyObservers( new Notification( notificationName, body, type ) );
		}
		
		
		/**
		 * Register an <code>IObserver</code> to be notified
		 * of <code>INotifications</code> with a given name.
		 * 
		 * @param notificationName the name of the <code>INotifications</code> to notify this <code>IObserver</code> of
		 * @param observer the <code>IObserver</code> to register
		 */
		public function registerObserver ( notificationName:String, observer:Method ) : void
		{
			var observers:Array = observerMap[ notificationName ];
			if( observers ) {
				observers.push( observer );
			} else {
				observerMap[ notificationName ] = [ observer ];	
			}
		}
		/**
		 * Remove the observer for a given notifyContext from an observer list for a given Notification name.
		 * 
		 * @param notificationName which observer list to remove from 
		 * @param notifyContext remove the observer with this object as its notifyContext
		 */
		public function removeObserver( notificationName:String, notifyContext:Object, notifyMethod:Function=null ):void
		{
			// the observer list for the notification under inspection
			var observers:Array = observerMap[ notificationName ];
			
			// find the observer for the notifyContext
			for ( var i:int=0; i<observers.length; i++ ) 
			{
				if ( observers[i].context == notifyContext )
				{
					if(notifyMethod == null)
					{
						observers.splice(i,1);
						break;
					}else if(observers[i].fun == notifyMethod)
					{
						observers.splice(i,1);
						break;
					}
				}
			}
			
			// Also, when a Notification's Observer list length falls to 
			// zero, delete the notification key from the observer map
			if ( observers.length == 0 ) {
				delete observerMap[ notificationName ];		
			}
		} 
		/**
		 * Notify the <code>IObservers</code> for a particular <code>INotification</code>.
		 * 
		 * <P>
		 * All previously attached <code>IObservers</code> for this <code>INotification</code>'s
		 * list are notified and are passed a reference to the <code>INotification</code> in 
		 * the order in which they were registered.</P>
		 * 
		 * @param notification the <code>INotification</code> to notify <code>IObservers</code> of.
		 */
		public function notifyObservers( notification:Notification ) : void
		{
			if( observerMap[ notification.getName() ] != null ) {
				
				// Get a reference to the observers list for this notification name
				var observers_ref:Array = observerMap[ notification.getName() ];
				
				// Copy observers from reference array to working array, 
				// since the reference array may change during the notification loop
				var observers:Array = new Array(); 
				var observer:Method;
				for (var i:Number = 0; i < observers_ref.length; i++) { 
					observer = observers_ref[ i ];
					observers.push( observer );
				}
				
				// Notify Observers from the working array				
				for (i = 0; i < observers.length; i++) {
					observer = observers[ i ];
					
					var newParams:Array = observer.params?[notification].concat(observer.params):[notification];
					observer.excute(newParams);
				}
			}
		}
		
		
		
		/**
		 * Register an <code>IProxy</code> with the <code>Model</code>.
		 * 
		 * @param proxy an <code>IProxy</code> to be held by the <code>Model</code>.
		 */
		public function registerProxy(proxyName:String, proxyClass:Class ) : void
		{
			var proxy:Proxy = new proxyClass();
			proxyMap[ proxyName ] = proxy;
			Injector.map(proxyClass, proxy);
			proxy.onRegister();
		}
		
		/**
		 * Retrieve an <code>IProxy</code> from the <code>Model</code>.
		 * 
		 * @param proxyName
		 * @return the <code>IProxy</code> instance previously registered with the given <code>proxyName</code>.
		 */
		public function retrieveProxy( proxyName:String ) : Proxy
		{
			return proxyMap[ proxyName ];
		}
		
		/**
		 * Check if a Proxy is registered
		 * 
		 * @param proxyName
		 * @return whether a Proxy is currently registered with the given <code>proxyName</code>.
		 */
		public function hasProxy( proxyName:String ) : Boolean
		{
			return proxyMap[ proxyName ] != null;
		}
		
		/**
		 * Remove an <code>IProxy</code> from the <code>Model</code>.
		 * 
		 * @param proxyName name of the <code>IProxy</code> instance to be removed.
		 * @return the <code>IProxy</code> that was removed from the <code>Model</code>
		 */
		public function removeProxy( proxyName:String ) : Proxy
		{
			var proxy:Proxy = proxyMap [ proxyName ];
			if ( proxy ) 
			{
				proxyMap[ proxyName ] = null;
				proxy.onRemove();
				Injector.unmap(proxy["constructor"]);
			}
			return proxy;
		}
		
		/**
		 * Register an <code>IMediator</code> instance with the <code>View</code>.
		 * 
		 * <P>
		 * Registers the <code>IMediator</code> so that it can be retrieved by name,
		 * and further interrogates the <code>IMediator</code> for its 
		 * <code>INotification</code> interests.</P>
		 * <P>
		 * If the <code>IMediator</code> returns any <code>INotification</code> 
		 * names to be notified about, an <code>Observer</code> is created encapsulating 
		 * the <code>IMediator</code> instance's <code>handleNotification</code> method 
		 * and registering it as an <code>Observer</code> for all <code>INotifications</code> the 
		 * <code>IMediator</code> is interested in.</P>
		 * 
		 * @param mediatorName the name to associate with this <code>IMediator</code> instance
		 * @param mediator a reference to the <code>IMediator</code> instance
		 */
		public function registerMediator(mediatorName:String, mediatorClass:Class ) : void
		{
			// do not allow re-registration (you must to removeMediator fist)
			if ( mediatorMap[ mediatorName ] != null ) return;
			
			var mediator:Mediator = new mediatorClass();
			// Register the Mediator for retrieval by name
			mediatorMap[ mediatorName ] = mediator;
			Injector.injectInto(mediator);
			Injector.map(mediatorClass, mediator);
			// alert the mediator that it has been registered
			mediator.onRegister();
			
		}
		
		/**
		 * Retrieve an <code>IMediator</code> from the <code>View</code>.
		 * 
		 * @param mediatorName the name of the <code>IMediator</code> instance to retrieve.
		 * @return the <code>IMediator</code> instance previously registered with the given <code>mediatorName</code>.
		 */
		public function retrieveMediator( mediatorName:String ) : Mediator
		{
			return mediatorMap[ mediatorName ];
		}
		
		/**
		 * Remove an <code>IMediator</code> from the <code>View</code>.
		 * 
		 * @param mediatorName name of the <code>IMediator</code> instance to be removed.
		 * @return the <code>IMediator</code> that was removed from the <code>View</code>
		 */
		public function removeMediator( mediatorName:String ) : Mediator
		{
			// Retrieve the named mediator
			var mediator:Mediator = mediatorMap[ mediatorName ];
			
			if ( mediator ) 
			{
				//				// for every notification this mediator is interested in...
				//				var interests:Array = mediator.listNotificationInterests();
				//				for ( var i:Number=0; i<interests.length; i++ ) 
				//				{
				//					// remove the observer linking the mediator 
				//					// to the notification interest
				//					removeObserver( interests[i], mediator );
				//				}	
				
				// remove the mediator from the map		
				delete mediatorMap[ mediatorName ];
				
				// alert the mediator that it has been removed
				mediator.onRemove();
				Injector.unmap(mediator["constructor"]);
			}
			
			return mediator;
		}
		
		/**
		 * Check if a Mediator is registered or not
		 * 
		 * @param mediatorName
		 * @return whether a Mediator is registered with the given <code>mediatorName</code>.
		 */
		public function hasMediator( mediatorName:String ) : Boolean
		{
			return mediatorMap[ mediatorName ] != null;
		}
		
		
		
		/**
		 * If an <code>ICommand</code> has previously been registered 
		 * to handle a the given <code>INotification</code>, then it is executed.
		 * 
		 * @param note an <code>INotification</code>
		 */
		protected function executeCommand( note : Notification ) : void
		{
			var commandClassRef : Class = commandMap[ note.getName() ];
			if ( commandClassRef == null ) return;
			
			var commandInstance : ICommand = new commandClassRef();
			Injector.injectInto(commandInstance);
			commandInstance.execute( note );
		}
		
		/**
		 * Register a particular <code>ICommand</code> class as the handler 
		 * for a particular <code>INotification</code>.
		 * 
		 * <P>
		 * If an <code>ICommand</code> has already been registered to 
		 * handle <code>INotification</code>s with this name, it is no longer
		 * used, the new <code>ICommand</code> is used instead.</P>
		 * 
		 * The Observer for the new ICommand is only created if this the 
		 * first time an ICommand has been regisered for this Notification name.
		 * 
		 * @param notificationName the name of the <code>INotification</code>
		 * @param commandClassRef the <code>Class</code> of the <code>ICommand</code>
		 */
		public function registerCommand( notificationName : String, commandClassRef : Class, context:Object=null ) : void
		{
			if ( commandMap[ notificationName ] == null ) {
				registerObserver( notificationName, new Method( executeCommand, null, context) );
			}
			commandMap[ notificationName ] = commandClassRef;
		}
		
		/**
		 * Check if a Command is registered for a given Notification 
		 * 
		 * @param notificationName
		 * @return whether a Command is currently registered for the given <code>notificationName</code>.
		 */
		public function hasCommand( notificationName:String ) : Boolean
		{
			return commandMap[ notificationName ] != null;
		}
		
		/**
		 * Remove a previously registered <code>ICommand</code> to <code>INotification</code> mapping.
		 * 
		 * @param notificationName the name of the <code>INotification</code> to remove the <code>ICommand</code> mapping for
		 */
		public function removeCommand( notificationName : String, context:Object ) : void
		{
			// if the Command is registered...
			if ( hasCommand( notificationName ) )
			{
				// remove the observer
				removeObserver( notificationName, context );
				
				// remove the command
				commandMap[ notificationName ] = null;
			}
		}
		
		protected static var instance:*;
		
		public static function getInstance():Facade
		{
			return instance ||= new Facade();
		}
	}
}


