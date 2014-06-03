/**
 * Created with IntelliJ IDEA.
 * User: vincent
 * Time: 2014/4/19 12:43
 * To change this template use File | Settings | File Templates.
 */
package cc.lomo.utils
{
	public class Method
	{
		public var fun:Function;

		public var params:Array;

		public var context:Object;

		public function Method(fun:Function, params:Array=null, context:Object=null)
		{
			this.fun = fun;
			this.params = params;
		}
		public function excute(newParams:Array=null):*
		{
			if(!newParams)
			{
				return fun.apply(context, params);
			}
			return fun.apply(context, newParams);
		}
	}
}
