package library.core
{
	import flash.display.DisplayObjectContainer;
	
	import library.interfaces.IContext;
	
	public class Command
	{
		[Inject]
		public var root:DisplayObjectContainer;
		[Inject]
		public var context:IContext;

		public function Command()
		{
		}

		public function execute():void
		{
			throw new Error("必须覆盖library.core::Command的execute方法");
		}
	}
}