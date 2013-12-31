package cc.lomo.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	[Event(name="readComplete", type="ClientEvent")]
	[Event(name="readError", type="ClientEvent")]
	[Event(name="flushComplete", type="ClientEvent")]
	[Event(name="flushError", type="ClientEvent")]
	
	/**
	 * 用于与服务器通信的客户端
	 * @author vincent 2012年7月31日15:27:17
	 * 
	 */	
	public class Client extends EventDispatcher
	{
		protected var mHost:String = "localhost";//"qq9386133.oicp.net";
		protected var mPort:int = 12315;
		protected var mSocket:Socket;

		public function Client(host:String=null, port:int=0, endian:String=null)
		{
			super();
			
			if(host)mHost = host;
			if(port)mPort = port;
			
			mSocket = new Socket;
			mSocket.endian = endian || Endian.BIG_ENDIAN;
		}
		
		public function connect(host:String=null, port:int=0):void
		{
			if(mSocket.connected)
				throw new Error("Socket已经连接过了");
			
			if(host)mHost = host;
			if(port)mPort = port;
			
			mSocket.addEventListener(Event.CONNECT, connectHandler);
			mSocket.connect(mHost, mPort);
		}
		public function close():void
		{
			mSocket.connected && mSocket.close();
		}
		protected function connectHandler(event:Event ):void
		{
			mSocket.removeEventListener(Event.CONNECT, connectHandler);
			
			mSocket.addEventListener(Event.CLOSE, errorHandler);
			mSocket.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			mSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			
			mSocket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler );
		}
		
		protected function errorHandler(event:Event):void
		{
			mSocket.removeEventListener(Event.CLOSE, errorHandler);
			mSocket.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			mSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			
			//print(event.type, this);
			
			dispatchEvent(event);
		}
		
		protected function socketDataHandler(event:ProgressEvent):void
		{
			read();
		}
		
		//////////////////////////////////////   BytesReader  ////////////////////////////////////////////
		/** 消息头长度( 4 Byte = 32 bit )*/
		protected const HEAD_LENGTH:int		= 4; //消息头长度( 4 Byte = 32 bit )
		/** 是否完成*/		
		protected var mCompleted:Boolean	= true;
		/** 本次数据的总长度*/
		protected var mLength:uint			= 0;
		/** 读取到的数据结果*/
		protected var mOutput:ByteArray		= new ByteArray();		//输出的数据
		
		/**
		 * 读取数据包
		 * 
		 */		
		protected function read():void
		{
			if(mSocket.bytesAvailable < HEAD_LENGTH)
				return;
			
			if(mCompleted)
			{
				mLength = mSocket.readUnsignedInt();//读出指示后面的数据有多大 
				//找到长度，开始本回合的读取
				if(!mOutput)
					mOutput	= new ByteArray();
				else
					mOutput.length = 0;
				
				if(mLength == 0)
					dispatchEvent(new ClientEvent(ClientEvent.READ_ERROR));
				else
				{
					mCompleted = false;//开始本回合读取了（没完）
					arguments.callee();//本次结束了哦 下一个
				}
			}
			else
			{
				//数据流里的数据足够多，读取mLength
				if(mSocket.bytesAvailable >= mLength)
				{
					mSocket.readBytes(mOutput, mOutput.position, mLength);
					
					mOutput.position = 0;
					//本回合读完
					mCompleted = true;
					dispatchEvent(new ClientEvent(ClientEvent.READ_COMPLETE, mOutput));
					
					//本次结束了哦
					arguments.callee();
				}
				else
				{
					//数据流里的数据少于mLength，读取全部
					mLength -= mSocket.bytesAvailable;
					
					mSocket.readBytes(mOutput, mOutput.position);
				}
			}
		}
		
		//////////////////////////////////////   BytesWriter  ////////////////////////////////////////////
		/** bytearray备份，以备写入socket*/	
		protected var mTempByte:ByteArray = new ByteArray();
		
		/**
		 * 创建bytearray备份，以备写入socket
		 * @param input 要发送的数据内容
		 * @param autoFlush 是否立即发送？
		 */	
		
		public function write(input:ByteArray, autoFlush:Boolean = false):void
		{
			mTempByte.writeBytes(input);
			
			autoFlush && flush();
		}
		/**
		 * 正式写入到socket 并发送到服务端
		 */		
		public function flush():void
		{
			mSocket.writeUnsignedInt(mTempByte.length);
			mSocket.writeBytes(mTempByte);
			mSocket.flush();
			mTempByte.length = 0;
			
			dispatchEvent(new ClientEvent(ClientEvent.FLUSH_COMPLETE));
		}
	}
}