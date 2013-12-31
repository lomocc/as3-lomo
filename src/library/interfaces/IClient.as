package library.interfaces
{
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	public interface IClient extends IEventDispatcher
	{
		function connect(host:String, port:int):void;
		function close():void;
		function read():void;
		function write(input:ByteArray, autoFlush:Boolean = false):void;
		function flush():void;
	}
}