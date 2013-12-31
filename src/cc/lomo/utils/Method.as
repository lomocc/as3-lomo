package cc.lomo.utils
{
	/** 
	 * 存放方法和参数的类型
	 * @author vincent 刘峰[liufeng#vertexgame.com] <br>2013-3-18 下午6:08:56
	 */
	public class Method
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function Method(func:Function,
										   args:Array /* of Object */ = null)
		{
			super();
			
			this.func = func;
			this.args = args;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  method
		//----------------------------------
		
		/**
		 *  A reference to the method to be called.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public var func:Function;
		
		//----------------------------------
		//  args
		//----------------------------------
		
		/**
		 *  The arguments to be passed to the method.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public var args:Array /* of Object */;
		
		public function excute():*
		{
			return func!=null?func.apply(null, args):null;
		}
	}
}