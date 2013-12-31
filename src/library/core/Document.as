package library.core
{	
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 文档类的基类<br>
	 * 修正Event.ADDED_TO_STAGE和 stage Event.RESIZE时stage宽高为0的问题。
	 * @author vincent 2012年8月1日13:28:46
	 * 
	 */	
	public class Document extends Sprite
	{
		public function Document()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 999);
		}
		private function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			event.stopImmediatePropagation();

			stage.align = "TL";
			stage.scaleMode = "noScale";

			stage.addEventListener(Event.RESIZE, resizeHandler, false, 999);
			resizeHandler(null);
		}
		private function resizeHandler(event:Event):void
		{
			if(stage.stageWidth > 0 && stage.stageHeight > 0)
			{
				stage.removeEventListener(Event.RESIZE, resizeHandler);

				dispatchEvent(new Event(Event.ADDED_TO_STAGE));

				stage.dispatchEvent(new Event(Event.RESIZE));
			}else event && event.stopImmediatePropagation();
		}
	}
}