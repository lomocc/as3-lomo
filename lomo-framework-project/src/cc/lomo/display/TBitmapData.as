package cc.lomo.display
{
	import flash.display.BitmapData;

	/**
	 * 带有注册点信息的位图
	 * @author duguohui
	 * 
	 */	
	public class TBitmapData extends BitmapData
	{
		public function TBitmapData(width:int, height:int, transparent:Boolean = true, fillColor:uint = 0x00)
		{
			super(width, height, transparent, fillColor);
		}

		public var x:int;

		public var y:int;
		
	}
}
