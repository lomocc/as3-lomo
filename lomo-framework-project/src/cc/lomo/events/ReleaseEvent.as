package cc.lomo.events
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class ReleaseEvent extends MouseEvent{
		
		
		public static const RELEASE:String = "release";	
		
		
		public static const RELEASE_OUTSIDE:String = "releaseOutSide";		
		
		private var pressTarget:DisplayObject;
		private var releasedOutSide:Boolean;
		
		public function ReleaseEvent(type:String, pressTarget:DisplayObject, releasedOutSide:Boolean, e:MouseEvent){
			super(type, false, false, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown);
			this.pressTarget = pressTarget;
			this.releasedOutSide = releasedOutSide;
		}
		
		/**
		 * Returns the target for of the press phase.
		 * @return the press target
		 */
		public function getPressTarget():DisplayObject{
			return pressTarget;
		}
		
		/**
		 * Returns whether or not this release is acted out side of the pressed display object.
		 * @return true if out side or false not.
		 */
		public function isReleasedOutSide():Boolean{
			return releasedOutSide;
		}
		
		override public function clone():Event{
			return new ReleaseEvent(type, getPressTarget(), isReleasedOutSide(), this);
		}
		
	}
}