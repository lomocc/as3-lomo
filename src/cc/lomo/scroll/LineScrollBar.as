package cc.lomo.scroll
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.events.ScrollEvent;
	import flashx.textLayout.events.TextLayoutEvent;
	
	public class LineScrollBar extends Sprite
	{
		protected var m_width:Number;
		protected var m_height:Number
		protected var m_thumbHeight:Number;
		protected var thumb:Sprite;
		protected var background:Sprite;
		
		protected var bounds:Rectangle;

		protected var m_downY:Number;
		protected function m_mouseDownHandler(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, m_mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, m_mouseUpHandler);
			
			thumb.startDrag(false, bounds);
			m_downY = mouseY;
		}
		protected function m_bgClick(event:MouseEvent):void
		{
			thumb.y = event.localY;
			var delta:Number = thumb.y / (m_height - m_thumbHeight) * m_maxVerticalScrollPosition;
			this.dispatchEvent(new ScrollEvent(TextLayoutEvent.SCROLL, false, false, null, delta));
		}
		protected function m_mouseMoveHandler(event:MouseEvent):void
		{

			setThumbY(thumb.y);
			
		}
		protected function m_mouseUpHandler(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, m_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, m_mouseUpHandler);
			
			thumb.stopDrag();
		}
		protected var m_verticalScrollPosition:Number;
		public function get verticalScrollPosition():Number
		{
			return m_verticalScrollPosition;
		}
		public function set verticalScrollPosition(value:Number):void
		{
			if(value > m_maxVerticalScrollPosition)
				value = m_maxVerticalScrollPosition;
			else if(value < 0)
				value = 0;
			
			m_verticalScrollPosition = value;
			trace(m_verticalScrollPosition,"/",m_maxVerticalScrollPosition, "*",(m_height - m_thumbHeight));
			thumb.y = m_verticalScrollPosition/m_maxVerticalScrollPosition * (m_height - m_thumbHeight);
		}
		protected var m_maxVerticalScrollPosition:Number;
		public function get maxVerticalScrollPosition():Number
		{
			return m_maxVerticalScrollPosition;
		}
		public function set maxVerticalScrollPosition(value:Number):void
		{
			m_maxVerticalScrollPosition = value;
			var thumbY:Number = thumb.y;
			
			//verticalScrollPosition = 
		}
		public function LineScrollBar(height:Number=100, width:Number=10, thumbHeight:Number=30)
		{
			super();
			
			m_width = width;
			
			m_height = height;
			
			m_thumbHeight = thumbHeight;
			
			
			addChild( background = newFillBox(m_width, m_height, 0xdddddd) );
			
			addChild( thumb = newFillBox(m_width, m_thumbHeight, 0x0) );

			bounds = new Rectangle(0, 0, 0, m_height - m_thumbHeight);
			
			thumb.buttonMode = true;
			
			var g:Graphics = thumb.graphics;
			
			g.lineStyle(1, 0xcccccc);
			
			line(g, thumbHeight*2/6);
			line(g, thumbHeight*3/6);
			line(g, thumbHeight*4/6);

			background.addEventListener(MouseEvent.MOUSE_DOWN, bgMouseDown);
			
			//background.addEventListener(MouseEvent.CLICK, m_bgClick);
			thumb.addEventListener(MouseEvent.MOUSE_DOWN, m_mouseDownHandler);
		}
		protected function bgMouseDown(event:MouseEvent):void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_UP, bgMouseUp);
		}
		protected function bgMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, bgMouseUp);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		protected function onEnterFrame(event:Event):void
		{
			var speed:Number = (mouseY - thumb.y) / 10;
			
			setThumbY(thumb.y + speed);
		}
		protected function setThumbY(value:Number):void
		{
			if(value > m_height - m_thumbHeight || value < 0)
				return;
			if(thumb.y != value)
				thumb.y = value;
			var delta:Number = value / (m_height - m_thumbHeight) * m_maxVerticalScrollPosition;
			this.dispatchEvent(new ScrollEvent(TextLayoutEvent.SCROLL, false, false, null, delta));
		}
		protected function line(g:Graphics, y:Number):void
		{
			g.moveTo(m_width * 0.2, y);
			g.lineTo(m_width * 0.8, y);
		}
		public function newFillBox(width:Number, height:Number, color:uint):Sprite
		{
			var sprite:Sprite = new Sprite();
			var g:Graphics = sprite.graphics;
			g.beginFill(color);
			g.drawRect(0, 0, width, height);
			g.endFill();
			return sprite;
		}
	}
}