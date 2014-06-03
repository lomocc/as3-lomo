package cc.lomo.utils
{

	import flash.geom.Point;
	import flash.geom.Rectangle;
	

	public class Camera2D
	{

		private var distX:int;
		private var distY:int;
		
		/**
		 * 缓动属性
		 * @default .1
		 */
		public var ease:Number = .1;
		
		/**
		 * 目标点
		 */
		public var target:Point;
		
		private var _basePoint:Point = new Point();
		
		/**
		 * 移动范围
		 */
		private var _viewBoundary:Rectangle = new Rectangle();
		
		private var _boundary:Rectangle = new Rectangle();
		
		/**
		 * 构造函数 
		 */
		public function Camera2D(viewPortW:int,viewPortH:int)
		{
			this.viewPortW = viewPortW;
			this.viewPortH = viewPortH;
		}
		
		public function set boundary(value:Rectangle):void
		{
			_boundary = value;
			updateBoundary();
		}

		public function setViewPort(viewPortW:int,viewPortH:int):void
		{
			this.viewPortW = viewPortW;
			this.viewPortH = viewPortH;
			updateBoundary();
		}
		
		private function updateBoundary():void
		{
			
			_viewBoundary.x = _boundary.x + (viewPortW >> 1);
			_viewBoundary.width = _boundary.width - viewPortW;
			_viewBoundary.width = _viewBoundary.width<0?0:_viewBoundary.width;
			
			_viewBoundary.y = _boundary.y + (viewPortH >> 1);
			_viewBoundary.height = _boundary.height - viewPortH;
			_viewBoundary.height = _viewBoundary.height<0?0:_viewBoundary.height;
		}
		
		/**
		 *计算结果
		 */
		public function get basePoint():Point
		{
			//var rt:Point = _basePoint.clone();
			
			//rt.offset(_fxShakeOffset.x,_fxShakeOffset.y);
			//return rt;
			return _basePoint.subtract(_fxShakeOffset);
		}
		
		public function reset():void
		{
			shakeList.clear();
			_basePoint.x = _basePoint.y=0;
			_fxShakeOffset.x = _fxShakeOffset.y=0;
			_zoom = 1;
			ease = 1;
			scroll(0);
		}

		/**
		 * 如果目标点存在，向目标点移动
		 */
		public function scroll(deltaTime:Number):void
		{
			if ( target )
			{
				scrollTarget();
				//计算抖动
				if(deltaTime<=0) return;
				deltaTime*=1000;
				
				if(shakeList.isEmpty())
				{
					/*_fxShakeOffset.x = _fxShakeOffset.x-_fxShakeOffset.x*ease;
					_fxShakeOffset.y = _fxShakeOffset.y-_fxShakeOffset.y*ease;*/
					
					_fxShakeOffset.x = 0;
					_fxShakeOffset.y = 0;
					return;
				}
				
				var shakes:Array = shakeList.values();
				var shake:ShakeVo;
				
				
				//经过的路程
				var sx:int;
				var sy:int;
				
				for(var i:int = 0; i < shakes.length; i++) 
				{
					shake = shakes[i];
					shake.ct += deltaTime;
					if(shake.ct>=shake.t)
					{
						removeShake(shake.key);
						continue;
					}
					
					shake.cx += shake.directionX*shake.vx*deltaTime;
					
					shake.cy += shake.directionY*shake.vy*deltaTime;
					
					_fxShakeOffset.x = shake.cx*_zoom;
					_fxShakeOffset.y = shake.cy*_zoom;
				}
			}
		}
		
		/**
		 * @private
		 * 向目标点移动
		 */
		private function scrollTarget():void
		{	

			// horizontal
			if ( target.x < _viewBoundary.right && target.x > _viewBoundary.left )
			{
				distX = _viewBoundary.left - target.x - _basePoint.x;
				_basePoint.x += distX * ease;
			}
			else
			{
				if ( target.x >= _viewBoundary.right )
				{
					distX = _viewBoundary.left - ( _viewBoundary.right + _basePoint.x ); 
					_basePoint.x += distX * ease;
				}
				if ( target.x <= _viewBoundary.left )
				{
					distX = _viewBoundary.left - ( _viewBoundary.left + _basePoint.x ); 
					_basePoint.x += distX * ease;
				}
				
			}
			// vertical
			if ( target.y < _viewBoundary.bottom && target.y > _viewBoundary.top )
			{
				distY = _viewBoundary.top - target.y - _basePoint.y;
				_basePoint.y += distY * ease;
			}
			else
			{
				if ( target.y >= _viewBoundary.bottom )
				{
					distY = _viewBoundary.top - ( _viewBoundary.bottom + _basePoint.y ); 
					_basePoint.y += distY * ease;
				}
				
				if ( target.y <= _viewBoundary.top )
				{
					distY = _viewBoundary.top - ( _viewBoundary.top + _basePoint.y ); 
					_basePoint.y += distY * ease;
				}
				
			}
		}
		
		
		/**
		 * 震动屏幕 
		 * @param x1 	水平方向
		 * @param x2	水平方向
		 * @param vx
		 * @param y1
		 * @param y2
		 * @param vy
		 * @param t
		 * 
		 */		
		public function screenShake(x1:int,x2:int,vx:int,y1:int,y2:int,vy:int,t:int):void
		{
			addShake(new ShakeVo(x1,x2,vx,y1,y2,vy,t));
		}
		
		private function addShake(vo:ShakeVo):void
		{
			shakeList.put(vo.key,vo);
		}
		
		private function removeShake(key:int):void
		{
			if(shakeList.containsKey(key)) shakeList.remove(key);
		}
		
		
		/**
		 * The zoom level of this camera. 1 = 1:1, 2 = 2x zoom, etc.
		 */
		public function getZoom():Number
		{
			return _zoom;
		}
		
		/**
		 * @private
		 */
		public function setZoom(Zoom:Number):void
		{
			if(Zoom <= 0)
				_zoom = defaultZoom;
			else
				_zoom = Zoom;
		}
		
		
		/**
		 * While you can alter the zoom of each camera after the fact,
		 * this variable determines what value the camera will start at when created.
		 */
		static public var defaultZoom:Number = 1;
		
		
		/**
		 * Internal, used to control the "shake" special effect.
		 */
		protected var _fxShakeOffset:Point = new Point;
		
		
		/**
		 * Indicates how far the camera is zoomed in.
		 */
		protected var _zoom:Number = 1;
		
		
		protected var shakeList:HashMap = new HashMap;
		
		
		private var viewPortW:int;
		private var viewPortH:int;
		
		
	}
}


internal class ShakeVo
{
	private static var index:int=0;
	
	
	public var x1:int;
	public var x2:int;
	public var vx:Number;
	public var y1:int;
	public var y2:int;
	public var vy:Number;
	public var key:int;
	
	//public var t:int;
	//方向
	public var directionX:int = 1;
	public var directionY:int = 1;
	
	private var _cx:Number = 0;
	private var _cy:Number = 0;
	
	public var t:int;
	public var ct:int = 0;
	
	
	public function ShakeVo(x1:int,x2:int,vx:int,y1:int,y2:int,vy:int,t:int):void
	{
		this.key = index;
		index++;
		this.t = t;
		this.x1 = x1;
		this.x2 = x2;
		this.vx = vx/1000;
		
		this.y1 = y1;
		this.y2 = y2;
		this.vy = vy/1000;
		
	}
	
	public function get cy():Number
	{
		return _cy;
	}

	public function set cy(value:Number):void
	{
		if(value>y2){value=y2;directionY*=-1}
		if(value<y1){value=y1;directionY*=-1}
		_cy = value;
	}

	public function get cx():Number
	{
		return _cx;
	}

	public function set cx(value:Number):void
	{
		if(value>x2){value=x2;directionX*=-1}
		if(value<x1){value=x1;directionX*=-1}
		_cx = value;
	}
}