package cc.lomo.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;

	[Event(name="complete",type="flash.events.Event")]
	public class AssetsItem extends Sprite
	{
		protected var linkName:String;
		protected var loader:AssetsLoader;
		
		public var content:Object;
		
		public function AssetsItem(loader:AssetsLoader, linkName:String)
		{
			super();
			
			this.loader = loader;
			this.linkName = linkName;
		}

		/**
		 *  供AssetsLoader调用
		 * 
		 */		
		public function update():void
		{
			var cls:Class = loader.getClass(linkName);
			content = new cls();

			var child:DisplayObject;
			if(content is Sound)
			{
				return;
			}else if(content is DisplayObject)
			{
				child = content as DisplayObject;
				addChildAt(child, 0);
			}else if(content is BitmapData)
			{
				child = new Bitmap(content as BitmapData);
				addChildAt(child, 0);
			}

			loader = null;
			linkName = null;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}

		
	}
}