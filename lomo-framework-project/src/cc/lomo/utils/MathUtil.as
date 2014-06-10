package cc.lomo.utils
{
	public class MathUtil
	{
		public function MathUtil()
		{
		}
		/**
		 * 随机一个左闭右开区间 [minNum, maxNum) 里的值 当minNum大于maxNum时交换两个值
		 * @param minNum
		 * @param maxNum
		 * @param useInt 是否转为整数 默认false
		 * @return 
		 * 
		 */		
		public static function random(minNum:Number, maxNum:Number, useInt:Boolean = false):Number
		{
			var result:Number;
			if(minNum != maxNum)
			{
				result = Math.random() * (maxNum - minNum) + minNum;
			}else
			{
				result = minNum;
			}
			if(useInt)
			{
				result = int(result);
			}
			return result;
		}
		/**
		 * Keep a number between a min and a max.
		 */
		public static function clamp(v:Number, min:Number = 0, max:Number = 1):Number
		{
			if(v < min) return min;
			if(v > max) return max;
			return v;
		}
		/**
		 * Converts an angle in radians to an angle in degrees.
		 * 
		 * @param radians The angle to convert.
		 * 
		 * @return The converted value.
		 */
		public static function getDegreesFromRadians(radians:Number):Number
		{
			return radians * 180 / Math.PI;
		}
		
		/**
		 * Converts an angle in degrees to an angle in radians.
		 * 
		 * @param degrees The angle to convert.
		 * 
		 * @return The converted value.
		 */
		public static function getRadiansFromDegrees(degrees:Number):Number
		{
			return degrees * Math.PI / 180;
		}
	}
}