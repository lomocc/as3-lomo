package cc.lomo.display
{
	import flash.display.BitmapData;

	/**
	 * 帧数据 
	 * @author Heven
	 * 
	 */	
	public class Frame
	{
		
		public function Frame(bitmapData:BitmapData,pivotX:int=0,pivotY:int=0)
		{
			this.bitmapData = bitmapData;
			this.pivotX = pivotX;
			this.pivotY = pivotY;
		}
		
		public var bitmapData:BitmapData;
		
		public var pivotX:int = 0;
		
		public var pivotY:int = 0;
		
	}
}