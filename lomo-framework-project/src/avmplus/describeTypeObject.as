package avmplus
{
	/**
	 * describeType的Json版本 去掉某些不需要的功能  速度快点
	 * @param target 目标对象
	 */		
	public function describeTypeObject(type:Class):Object
	{
		return describeTypeJSON(type, INCLUDE_VARIABLES | INCLUDE_METADATA | INCLUDE_TRAITS | USE_ITRAITS | HIDE_OBJECT);
	}
}