package cc.lomo.utils
{
	import flash.utils.Dictionary;
	
	/**
	 * 操作数组的一些常用方法
	 * @author vincent 2012年8月10日8:51:54
	 * 
	 */	
	public class ArrayUtil
	{
		public function ArrayUtil()
		{
		}
		/**
		 * 去掉重复的数据之后的结果（原数组不变）
		 * @param a
		 * @return 
		 * 
		 */		
		public static function createUniqueCopy(a:Array):Array
		{
			var temp:Array = [], dict:Dictionary = new Dictionary(), i:int, j:*;
			for each (j in a) 
			dict[j] = j;
			
			for each (j in dict) 
			temp[i++] = j;
			
			return temp;
		}
		/**
		 * 洗牌算法，打乱数组顺序（原数组被打乱顺序）
		 * @param a 需要打乱内容顺序的数组
		 * 
		 */		
		public static function shuffle(a:Array):void
		{
			for (var i:int = a.length - 1; i > 0; --i) 
			{
				var p:int = Math.random() * (i + 1);
				if (p == i) continue;
				var tmp:* = a[i];
				a[i] = a[p];
				a[p] = tmp;
			}
		}
	}
}