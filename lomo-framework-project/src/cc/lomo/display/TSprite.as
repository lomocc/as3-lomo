package cc.lomo.display
{
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import cc.lomo.events.ReleaseEvent;
	import cc.lomo.interfaces.IDisposable;
	import cc.lomo.managers.ViewManager;
	import cc.lomo.utils.DisplayUtil;
	import cc.lomo.utils.HashMap;
	
	
	
	[Event(name="release", type="com.throne.gui.events.ReleaseEvent")]
	[Event(name="releaseOutSide", type="com.throne.gui.events.ReleaseEvent")]
	
	
	public class TSprite extends Sprite implements IDisposable
	{
		
		private var _listeners:Array;
		private var clientProperty:HashMap;
		private var pressedTarget:DisplayObject;
		private var _checkClickOutSide:Boolean=false;
		
		
		public function TSprite(ui:DisplayObject=null)
		{
			super();
			
			if(ui){
				this.x=ui.x;
				this.y=ui.y;
				ui.x = 0;
				ui.y = 0;
				if(ui.parent)
				{
					var index:int = ui.parent.getChildIndex(ui);
					ui.parent.addChildAt(this,index);
				}
				addChild(ui);
			}
			clientProperty = null;
			focusRect = false;
			addEventListener(MouseEvent.MOUSE_DOWN, __spriteMouseDownListener);
			addEventListener(Event.ADDED_TO_STAGE,addedToStage);
		}
		
		public function get checkClickOutSide():Boolean
		{
			return _checkClickOutSide;
		}
		
		public function set checkClickOutSide(value:Boolean):void
		{
			
			if(value)
				ViewManager.getStage().addEventListener(MouseEvent.MOUSE_DOWN, __stageMouseDownListener);
			else
				ViewManager.getStage().removeEventListener(MouseEvent.MOUSE_DOWN, __stageMouseDownListener);
			
			
			_checkClickOutSide = value;
		}
		
		private function addedToStage(event:Event):void{
			if(checkClickOutSide){
				ViewManager.getStage().addEventListener(MouseEvent.MOUSE_DOWN, __stageMouseDownListener);
			}
			removeEventListener(Event.ADDED_TO_STAGE,addedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,removedFromStage);
			onAddToStage();
		}
		
		private function removedFromStage(event:Event):void
		{
			if(checkClickOutSide){
				ViewManager.getStage().removeEventListener(MouseEvent.MOUSE_DOWN, __stageMouseDownListener);
			}
			addEventListener(Event.ADDED_TO_STAGE,addedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE,removedFromStage);
			onRemoveFromStage();
		}
		
		
		/**
		 * Determines whether or not this component is on stage(on the display list).
		 * @return turn of this component is on display list, false not.
		 */
		public function isOnStage():Boolean{
			return stage != null;
		}
		
		
		
		/**
		 * Returns whether or not the child is this sprite's direct child.
		 */
		protected function isChild(child:DisplayObject):Boolean{
			return child.parent == this;
		}
		
		
		/**
		 * Returns whether child is directly child of this sprite, true only if getChildIndex(child) >= 0.
		 * @return true only if getChildIndex(child) >= 0.
		 */
		public function containsChild(child:DisplayObject):Boolean{
			return child.parent == this;
		}
		
		
		public function getHighestIndexUnderForeground():int{
			return numChildren - 1;
		}
		
		
		public function getLowestIndexAboveBackground():int{
			return 0;
		}
		
		
		
		/**
		 * Brings a child to top.
		 * This method will keep foreground child on top, if you bring a other object 
		 * to top, this method will only bring it on top of other objects
		 * (mean on top of others but bellow the foreground child).
		 * @param child the child to be bringed to top.
		 */
		public function bringToTop(child:DisplayObject):void{
			var index:int = numChildren-1;
			if(getChildIndex(child) == index) return;
			setChildIndex(child, index);
		}
		
		
		/**
		 * Brings a child to bottom.
		 * This method will keep background child on bottom, if you bring a other object 
		 * to bottom, this method will only bring it at bottom of other objects
		 * (mean at bottom of others but on top of the background child).
		 * @param child the child to be bringed to bottom.
		 */	
		public function bringToBottom(child:DisplayObject):void{
			if(getChildIndex(child) == 0) return;
			setChildIndex(child, 0);
		}
		
		
		private function __stageMouseDownListener(e:MouseEvent):void{
			
			ViewManager.getStage().addEventListener(MouseEvent.MOUSE_UP, __stageMouseUpListener, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, __stageRemovedFrom);
			
		}
		
		private function __spriteMouseDownListener(e:MouseEvent):void{
			pressedTarget = e.target as DisplayObject;
			
			ViewManager.getStage().addEventListener(MouseEvent.MOUSE_UP, __stageMouseUpListener, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, __stageRemovedFrom);
			
		}
		private function __stageRemovedFrom(e:Event):void{
			pressedTarget = null;
			ViewManager.getStage().removeEventListener(MouseEvent.MOUSE_UP, __stageMouseUpListener);
		}
		private function __stageMouseUpListener(e:MouseEvent):void{
			
			ViewManager.getStage().removeEventListener(MouseEvent.MOUSE_UP, __stageMouseUpListener);
			var isOutSide:Boolean = false;
			var target:DisplayObject = e.target as DisplayObject;
			if(this != target && !DisplayUtil.isAncestorDisplayObject(this, target)){
				isOutSide = true;
			}
			
			dispatchEvent(new ReleaseEvent(ReleaseEvent.RELEASE, pressedTarget, isOutSide, e));
			
			if(isOutSide){
				dispatchEvent(new ReleaseEvent(ReleaseEvent.RELEASE_OUTSIDE, pressedTarget, true, e));
			}
			
			pressedTarget = null;
		}
		
		
		
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (_listeners == null)
				_listeners = new Array();
			_listeners.push([type, listener, useCapture, priority, useWeakReference]);
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function hasEventListener2(type:String, listener:Function = null):Boolean
		{
			var superHas:Boolean = super.hasEventListener(type);
			if (listener == null)
				return superHas;
			if (superHas)
			{
				var listenerCount:uint = _listeners.length;
				for (var i:uint = 0; i < listenerCount; i++)
				{
					var listenerInfo:Array = _listeners[i];
					if (listenerInfo[0] == type && listenerInfo[1] == listener)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			if (_listeners == null)
				return;
			var listenerCount:uint = _listeners.length;
			for (var i:uint = 0; i < listenerCount; i++)
			{
				var listenerInfo:Array = _listeners[i];
				if (listenerInfo[0] == type && listenerInfo[1] == listener && listenerInfo[2] == useCapture)
				{
					super.removeEventListener(type, listener, useCapture);
					_listeners.splice(i, 1);
					break;
				}
			}
		}
		
		public function removeAllEventListener():void
		{
			if (_listeners == null)
				return;
			
			var listenerCount:uint = _listeners.length;
			for (var i:uint = 0; i < listenerCount; i++)
			{
				var listenerInfo:Array = _listeners[i];
				super.removeEventListener(listenerInfo[0], listenerInfo[1], listenerInfo[2]);
				listenerInfo.length = 0;
			}
			_listeners.length = 0;
			_listeners = null;
		}
		
		
		/**
		 * @see #setLocation()
		 */
		public function setLocationXY(x:int, y:int):void{
			this.x	=	int(x);
			this.y	=	int(y);
		}
		
		public function setLocation(pt:Point):void{
			setLocationXY(pt.x, pt.y);
		}
		
		public function getPos():Point{
			return new Point(this.x,this.y);
		}
		
		
		protected function onRemoveFromStage():void
		{
			// TODO Auto Generated method stub
			
		}	
		
		protected function onAddToStage():void
		{
			// TODO Auto Generated method stub
			
		}
		
//		public function showTip(obj:Object = null, 
//								immediatelyShowTips:Boolean = true,
//								hang:Boolean = false,
//								offsetsRelatedToMouse:Boolean = true,
//								offsets:IntPoint=null,forceCheck:Boolean = true):void
//		{
////			setToolTip(obj,immediatelyShowTips,hang,offsetsRelatedToMouse,offsets,forceCheck);
//		}
//		public function hideTip():void
//		{
//			setToolTip(null);
//		}
//		
//		
//		public function setToolTip(obj:Object = null, 
//								   immediatelyShowTips:Boolean = true,
//								   hang:Boolean = false,
//								   offsetsRelatedToMouse:Boolean = true,
//								   offsets:IntPoint=null,forceCheck:Boolean = false):void
//		{
//			
////			TToolTip.registerComponent(this,obj,immediatelyShowTips,hang,offsetsRelatedToMouse,offsets,forceCheck);
//			
//		}
		
		
		/**
		 * Returns the value of the property with the specified key. 
		 * Only properties added with putClientProperty will return a non-null value.
		 * @param key the being queried
		 * @param defaultValue if the value doesn't exists, the defaultValue will be returned
		 * @return the value of this property or null
		 * @see #putClientProperty()
		 */
		public function getClientProperty(key:*, defaultValue:*=undefined):*{
			if(clientProperty == null){
				return defaultValue;
			}
			if(clientProperty.containsKey(key)){
				return clientProperty.getValue(key);
			}else{
				return defaultValue;
			}
		}
		
		/**
		 * Adds an arbitrary key/value "client property" to this component.
		 * <p>
		 * The <code>get/putClientProperty</code> methods provide access to 
		 * a small per-instance hashtable. Callers can use get/putClientProperty
		 * to annotate components that were created by another module.
		 * For example, a
		 * layout manager might store per child constraints this way. For example:
		 * <pre>
		 * componentA.putClientProperty("to the left of", componentB);
		 * </pre>
		 * @param key the new client property key
		 * @param value the new client property value
		 * @see #getClientProperty()
		 */    
		public function putClientProperty(key:*, value:*):void{
			//Lazy initialization
			if(clientProperty == null){
				clientProperty = new HashMap();
			}
			clientProperty.put(key, value);
		}
		
		
		public function dispose():void{
			if(clientProperty) clientProperty.clear();
			clientProperty = null;
			removeFromContainer();
//			TToolTip.unregisterComponent(this);
			removeAllEventListener();
			removeChildren();
		}
		
		/**
		 * 移出舞台 
		 * 
		 */	
		public function removeFromContainer():void
		{
			DisplayUtil.remove(this);
		}
		
//		/**
//		 * 移除所有子元件
//		 * @param disposeChild 销毁子元件
//		 * 
//		 */
////		public function removeAllChildren(disposeChild:Boolean=false):void{
////			DisplayUtil.removeAllChildren(this,disposeChild);
////		}
		
//		override public function toString():String{
//			var p:DisplayObject = this;
//			var str:String = p.name;
//			while(p.parent != null){
//				var name:String = (p.parent == p.stage ? "Stage" : p.parent.name);
//				p = p.parent;
//				str = name + "." + str;
//			}
//			return str;
//		}
	}
}