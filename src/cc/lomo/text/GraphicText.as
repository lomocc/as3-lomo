package cc.lomo.text
{
	import cc.lomo.scroll.LineScrollBar;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.FlowOperationEvent;
	import flashx.textLayout.events.ScrollEvent;
	import flashx.textLayout.events.TextLayoutEvent;
	import flashx.textLayout.operations.FlowOperation;
	import flashx.textLayout.operations.PasteOperation;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.UndoManager;
	
	public class GraphicText extends Sprite
	{		
		protected var inputTextFlow:TextFlow;
		
		protected var inputController:ContainerController
		
		protected var inputEditManager:EditManager;
		
		public var scrollBar:LineScrollBar;
		
		public var rule:Rule;//文本的图形规则
		
		protected var content:Sprite;
		
		protected var m_width:Number;
		
		protected var m_height:Number;
		
		public function GraphicText(width:Number = 500, height:Number = 400, rule:Rule = null)
		{
			super();
			
			this.m_width = width;
			
			this.m_height = height;
			
			this.rule = rule?rule:new Rule();
			
			initialize();
		}
		protected function drawBg():void
		{
			var g:Graphics = this.graphics;
			g.clear();
			g.beginFill(0xeeeeee);
			g.drawRect(0, 0, m_width, m_height);
			g.endFill();
		}
		protected function initialize():void
		{
			inputTextFlow = new TextFlow();
			
			drawBg();
			
			inputController = new ContainerController(content = new Sprite, m_width, m_height);
			
			addChild(content);
			
			inputTextFlow.flowComposer = new StandardFlowComposer();
			
			inputTextFlow.flowComposer.addController(inputController);
			
			inputEditManager = new EditManager(new UndoManager());
			
			inputTextFlow.interactionManager = inputEditManager;
			
			inputTextFlow.addEventListener(FlowOperationEvent.FLOW_OPERATION_END, onOperationEnd);
			
			inputTextFlow.addEventListener(TextLayoutEvent.SCROLL,scroll);
			
			inputTextFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, compositionComplete);
			
			inputEditManager.unfocusedSelectionFormat = inputEditManager.focusedSelectionFormat;
			
			inputEditManager.selectRange(0,0);
		}
		protected function compositionComplete(event:CompositionCompleteEvent):void
		{
			if(inputController.getContentBounds().height <= inputController.compositionHeight)
			{
				if(scrollBar)
				{
					scrollBar.removeEventListener(TextLayoutEvent.SCROLL,scroll);
					removeChild(scrollBar);
					scrollBar = null;
				}
				return;
			}
			if(!scrollBar)
			{
				scrollBar = new LineScrollBar(m_height);
				scrollBar.x = inputController.compositionWidth;
				scrollBar.addEventListener(TextLayoutEvent.SCROLL,scroll);
				addChild(scrollBar);
			}
			scrollBar.maxVerticalScrollPosition = inputController.getContentBounds().height - inputController.compositionHeight;
		}
		protected function scroll(event:ScrollEvent):void
		{
			if(!scrollBar)return;
			var target:Object = event.target;
			if(target == scrollBar)
			{
				inputController.verticalScrollPosition = event.delta;
			}else if(target == inputTextFlow)
			{
				scrollBar.verticalScrollPosition = inputController.verticalScrollPosition;
				trace(inputController.verticalScrollPosition,inputController.compositionHeight,inputController.getContentBounds().height,"==inputController.verticalScrollPosition");
				//scrollBar.drawScrollBar(inputController.verticalScrollPosition, inputController.getContentBounds().height);
			}
		}
		protected function onOperationEnd(event:FlowOperationEvent):void
		{
			if(event.error)
			{
				event.preventDefault();
				return;
			}
			var operation:FlowOperation = event.operation;
			if(operation is PasteOperation)
			{
				if(scrollBar)
				{
					scrollBar.removeEventListener(TextLayoutEvent.SCROLL,scroll);
					removeChild(scrollBar);
					
					scrollBar = new LineScrollBar(m_height);
					scrollBar.x = inputController.compositionWidth;
					scrollBar.addEventListener(TextLayoutEvent.SCROLL,scroll);
					addChild(scrollBar);
				}
				var formatText:String = exportFormatText((operation as PasteOperation).textScrap.textFlow);
				var result:Array = rule.regexp.exec(formatText);
				
				//如果新粘贴进来的文本包含图片（带有@source的即为图片）, 则更新
				if(result)
					updateAfterPasteOperation();
			}
		}
		public function setWidthAndHeight(w:Number,h:Number):void
		{
			this.m_width = w;
			
			this.m_height = h;
			
			inputController.setCompositionSize(w, h);
			
			drawBg();
		}
		public function insertGraphic($name:String):void
		{
			inputEditManager.insertInlineGraphic(rule.getRule($name), "auto", "auto");
		}
		public function insertText(text:String):void
		{
			inputEditManager.insertText(text);
		}
		
		public function exportFormatText(param:FlowElement=null):String
		{
			var result:String = "";
			if(!param)
				param = inputTextFlow;
			
			if(param is SpanElement)
			{
				result = (param as SpanElement).text;
			}else if(param is InlineGraphicElement)
			{
				var $name:String = (param as InlineGraphicElement).source + "";
				$name = this.classToPrefixSuffix($name);//.replace("[class ",this.prefix ).replace("]", this.suffix);
				result = $name;
			}else if(param is FlowGroupElement)
			{
				var p:FlowGroupElement = param as FlowGroupElement;
				for(var i:int = 0, l:int = p.numChildren ; i < l; i++)
				{
					result += arguments.callee( p.getChildAt(i) );
				}
				if(param is ParagraphElement)
					result += "\n";
			}
			return result;
		}
		public function appendFormatText(text:String):void
		{
			var result:Array = text.split( rule.regexp );
			for(var i:int = 0, l:int = result.length; i < l; i++)
			{
				var item:String = result[i];
				var result2:Array = rule.regexp.exec( item );
				if(result2)
				{
					//图标
					var $name:String = item.replace(rule.innerRegexp, "");
					insertGraphic($name);
				}else
				{
					insertText(item);
				}
			}
		}
		protected function classToPrefixSuffix(value:String):String
		{
			return value.replace("[class ",rule.prefix ).replace("]", rule.suffix);
		}
		public function updateAfterPasteOperation(param:FlowElement=null):void
		{
			if(!param)
				param = inputTextFlow;
			
			if(param is InlineGraphicElement)
			{
				var img:InlineGraphicElement = param as InlineGraphicElement;
				var $name:String = img.source + "";
				$name = classToPrefixSuffix($name);
				$name = $name.replace(rule.innerRegexp, "");
				
				img.source = rule.getRule($name);
			}else if(param is FlowGroupElement)
			{
				var p:FlowGroupElement = param as FlowGroupElement;
				for(var i:int = 0, l:int = p.numChildren ; i < l; i++)
				{
					arguments.callee( p.getChildAt(i) );
				}
			}
		}
		/**
		 * 清空文本 
		 * 
		 */		
		public function clear():void
		{
			inputEditManager.selectAll();
			inputEditManager.deleteText();
		}
		
		tlf_internal function parseXML(xml:XML):FlowElement
		{
			var i:int, l:int;
			var type:String = xml.localName();
			switch(type)
			{
				case "span":
					var span:SpanElement = new SpanElement();
					span.text = xml.toString();
					return span;
				case "img":
					var img:InlineGraphicElement = new InlineGraphicElement();
					var $name:String = xml.@source;
					$name = $name.replace(rule.innerRegexp, "");
					img.source = rule.getRule($name);
					return img;
				case "p":
					var p:ParagraphElement = new ParagraphElement();
					for(i = 0, l = xml.children().length(); i < l; i++)
					{
						p.addChild( arguments.callee(XML(xml.child(i))) );
					}
					return p;
				case "TextFlow":
					var container:TextFlow = inputTextFlow;
					for(i = 0, l = xml.children().length(); i < l; i++)
					{
						container.addChild( arguments.callee(XML(xml.child(i))) );
					}
					break;
			}
			return null;
		}
		
		tlf_internal function exportXML(param:FlowElement):XML
		{
			var i:int, l:int;
			var result:XML;
			if(!param)
				return result;
			
			if(param is SpanElement)
			{
				result = <span/>;
				result.appendChild((param as SpanElement).text);
			}else if(param is InlineGraphicElement)
			{
				result = <img/>;
				var ie:InlineGraphicElement = param as InlineGraphicElement;
				var $name:String = ie.source + "";
				$name =  this.classToPrefixSuffix($name);//.replace("[class ",this.prefix ).replace("]", this.suffix);
				result.@source = $name;
				
			}else if(param is ParagraphElement)
			{
				result = <p/>;
				var p:ParagraphElement = param as ParagraphElement;
				for(i = 0, l = p.numChildren ; i < l; i++)
				{
					result.appendChild( arguments.callee(p.getChildAt(i)) );
				}
			}else if(param is TextFlow)
			{
				result = <TextFlow xmlns="http://ns.adobe.com/textLayout/2008"/>;
				
				var tf:TextFlow = param as TextFlow;
				for(i = 0, l = tf.numChildren ; i < l; i++)
				{
					result.appendChild( arguments.callee(tf.getChildAt(i)) );
				}
			}
			return result;
		}
	}
}