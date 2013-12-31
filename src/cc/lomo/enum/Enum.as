package cc.lomo.enum
{
	/**
	 *
	 * 枚举基类，所有纯枚举类型和 不能被实例化的类型继承此类
	 * @author vincent
	 * 
	 */	
	public class Enum
	{
		public function Enum()
		{
			throw new Error( "[" + this + " is a Enum Class.]" );
		}
	}
}