package cc.lomo.core
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageAlign;

	public class Lomo
	{
		public function Lomo()
		{
		}
		public static function init(main:DisplayObject):void
		{
			mStage = main.stage;
			mApplication = mStage.getChildAt(0);
			
			stageSetting();
		}
		
		protected static var mApplication:Object;
		public static function get application():Object
		{
			if(!mStage)
				throw new Error("请先Lomo.init");
			return mApplication;
		}
		
		protected static var mStage:Stage;
		public static function get stage():Stage
		{
			if(!mStage)
				throw new Error("请先Lomo.init");
			return mStage;
		}
		
		public static function stageSetting(align:String = "TL", scaleMode:String = "noScale"):void
		{
			mStage.align		= align;
			mStage.scaleMode	= scaleMode;
		}
		
		public static function stringError(msg:String="", target:Object=null):void
		{
			throw new Error(target + ":" + msg);
		}
	}
}