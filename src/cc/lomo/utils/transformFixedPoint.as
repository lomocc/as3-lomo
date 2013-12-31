package cc.lomo.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	/**
	 * 
	 * @param target
	 * @param regpoint 注册点(相对于target)
	 * @param prop 要改变的属性
	 * @param value
	 * 
	 */
	public function transformFixedPoint(target:DisplayObject, regpoint:Point, ...rest):void
	{
		//必须是偶数
		if(rest.length & 1 != 0)
			return;
		
		//转换为全局坐标
		var oldPoint:Point = target.parent.globalToLocal(target.localToGlobal(regpoint));
		
		for(var i:int = 0, l:int = rest.length; i < l; i++)
		{
			var prop:String = rest[i];
			var value:Number = rest[i + 1];
			
			if("x,y".indexOf(prop) != -1)
			{
				target[prop] = value - regpoint[prop];
			}else
			{
				target[prop] = value;
			}
		}
		var newPoint:Point = target.parent.globalToLocal(target.localToGlobal(regpoint));
		//把注册点从B点移到A点
		target.x += oldPoint.x - newPoint.x;
		target.y += oldPoint.y - newPoint.y;
		
		/*if(prop == "x" || prop == "y")
		{
			target[prop] = value - regpoint[prop];
		}else
		{
			target[prop] = value;
			//执行旋转等属性后，再重新计算全局坐标
			var newPoint:Point = target.parent.globalToLocal(target.localToGlobal(regpoint));
			//把注册点从B点移到A点
			target.x += oldPoint.x - newPoint.x;
			target.y += oldPoint.y - newPoint.y;
		}*/
	}
}