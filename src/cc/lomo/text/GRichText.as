package cc.lomo.text
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;

	/**
	 * FTE的简单封装 
	 * @author flashyiyi
	 * 
	 */
	public class GRichText extends Sprite
	{
		private var m_content:GroupElement;
		private var m_textBlock:TextBlock;
		private var m_groupVector:Vector.<ContentElement> = new Vector.<ContentElement>();

		protected var m_eventDispatcher:EventDispatcher;
		
		public var textWidth:int = 20000;
		
		protected var autoRefresh:Boolean = false;
		
		public function GRichText(autoRefresh:Boolean = false, defaultFormat:ElementFormat = null)
		{
			this.autoRefresh = autoRefresh;
			
			if (!defaultFormat)
				defaultFormat = new ElementFormat();
			
			m_eventDispatcher = new EventDispatcher();
			m_eventDispatcher.addEventListener(MouseEvent.MOUSE_OUT,	onMouseOutHandler);  
			m_eventDispatcher.addEventListener(MouseEvent.MOUSE_OVER,	onMouseOverHandler);  
			m_eventDispatcher.addEventListener(MouseEvent.CLICK,		onClickHandler);  
			
			m_content = new GroupElement(null,defaultFormat);
			m_textBlock = new TextBlock(content);
		}
		
		private function onClickHandler(event:MouseEvent):void
		{
			// TODO Auto Generated method stub
			trace(event.type);
		}
		
		private function onMouseOverHandler(event:MouseEvent):void
		{
			// TODO Auto Generated method stub
			trace(event.type);
		}
		
		private function onMouseOutHandler(event:MouseEvent):void
		{
			// TODO Auto Generated method stub
			trace(event.type);
		}
		
		/**
		 * 获得文字数据 
		 * @return 
		 * 
		 */
		public function get content():GroupElement
		{
			return m_content;
		}

		/**
		 * 添加一段文本
		 * @param text
		 * @param format
		 * @param textRotation
		 * 
		 */
		public function addText2(text:String,format:ElementFormat = null,textRotation:String = "rotate0"):void
		{
			if (!format)
				format = content.elementFormat;
			
			var e:TextElement = new TextElement(text,format,m_eventDispatcher,textRotation);
			m_groupVector.push(e);
			
			autoRefresh && refresh();
		}
		public function addText(text:String, color:uint=0, fontName:String="_serif", fontSize:Number=12.0, fontWeight:String="normal", alpha:Number=1.0, textRotation:String = "rotate0"):void
		{
			var fontDescription:FontDescription = new FontDescription(fontName, fontWeight); 
			var format:ElementFormat = new ElementFormat(fontDescription, fontSize, color, alpha);
			
			var textElement:TextElement = new TextElement(text, format, m_eventDispatcher, textRotation);
			m_groupVector.push(textElement);
			
			autoRefresh && refresh();
		}
		/**
		 * 添加一个图形
		 * @param graphics
		 * @param format
		 * 
		 */
		public function addGraphics(graphics:DisplayObject,format:ElementFormat = null):void
		{
			if (!format)
				format = content.elementFormat;

			var e:GraphicElement = new GraphicElement(graphics, graphics.width, graphics.height, format);
			m_groupVector.push(e);
			
			autoRefresh && refresh();
		}

		public function clearText():void
		{
			
		}
		/**
		 * 刷新显示
		 * 
		 */
		public function refresh():void
		{
			content.setElements(m_groupVector);
			createTextLines();
		}
		
		private function createTextLines():void 
		{
			var yPos:int = 0;
			var line_length:Number = textWidth;
			var textLine:TextLine = m_textBlock.createTextLine(null,line_length);
			
			while (textLine)
			{
				addChild(textLine);
				textLine.x = 15;
				yPos += textLine.height + 8;
				textLine.y = yPos;
				textLine = m_textBlock.createTextLine(textLine,line_length);
			}
		}
	}
}