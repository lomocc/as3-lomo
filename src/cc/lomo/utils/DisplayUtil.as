package common.utils
{
	import cc.lomo.utils.Method;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * 显示对象方面的小功能 一些常用的关于显示的方法都可以在这里边找一找 没有的话也可以加进来 集中在一起
	 * 如果有重复的 麻烦告诉我一下
	 * @author vincent 刘峰[liufeng#vertexgame.com] <br>2013-2-28 上午9:40:03
	 */
	public class DisplayUtil
	{
		public function DisplayUtil()
		{
		}
		/**
		 * 用新的显示对象替换显示对象 这个方法主要是为了在fla文件中放好一个占位符 然后运行时用组件或其他显示对象替换 这样就不需要在代码中设置坐标[增加无意义的魔术字]
		 * @param oldDisplayObject 要移除的原来的显示
		 * @param newDisplayObject 要添加的新的显示
		 */		
		public static function replace(oldDisplayObject:DisplayObject, newDisplayObject:DisplayObject):void
		{
			const parent:DisplayObjectContainer = oldDisplayObject.parent;
			if(parent)
			{
				const index:int = parent.getChildIndex(oldDisplayObject);
				
				newDisplayObject.filters		=	oldDisplayObject.filters;
				newDisplayObject.rotation		=	oldDisplayObject.rotation;
				newDisplayObject.scaleX			=	oldDisplayObject.scaleX;
				newDisplayObject.scaleY			=	oldDisplayObject.scaleY;
				newDisplayObject.x				=	oldDisplayObject.x;
				newDisplayObject.y				=	oldDisplayObject.y;
				// ... 其他属性
				
				parent.removeChildAt(index);
				parent.addChildAt(newDisplayObject, index);
				
				const name:String = newDisplayObject.name = oldDisplayObject.name;
				// 动态属性值也赋上去
				if(ObjectUtil.isDynamicObject(parent) && name)
				{
					try
					{
						//防止类型不对 报错
						parent[name] = newDisplayObject;
					} 
					catch(error:Error) 
					{
						
					}
				}
			}
		}
		/**
		 *  获得截屏的位图 
		 * @param target 目标
		 * @param rect 要截取的矩形区域
		 * @return 
		 */		
		public static function transferToBitmap(target:DisplayObject, rect:Rectangle=null):Bitmap
		{
			rect ||= target.getBounds(target);
			var bmpd:BitmapData = snapshot(target, rect);
			//去空白
			var	rectTar:Rectangle = bmpd.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if(rectTar.isEmpty())
				return new Bitmap();
			var	tempTarBitmapdata:BitmapData = new BitmapData(rectTar.width, rectTar.height, true, 0x0);
			tempTarBitmapdata.copyPixels(bmpd, rectTar, new Point());
			bmpd.dispose();
			
			var bmp:Bitmap = new Bitmap(tempTarBitmapdata, "auto", true);
			bmp.x = target.x + rect.x + rectTar.x;
			bmp.y = target.y + rect.x + rectTar.y;
			return bmp;
		}
		/**
		 * 截屏 
		 * @param target 目标
		 * @param rect 要截取的矩形区域
		 * @return 
		 */		
		public static function snapshot(target:DisplayObject, rect:Rectangle=null):BitmapData
		{
			rect ||= target.getBounds(target);
			if(rect.isEmpty()) return new BitmapData(1, 1, true, 0x0);
			var mtx:Matrix = new Matrix();
			mtx.translate(-rect.x, -rect.y);
			
			var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true, 0x0);
			bitmapData.draw(target, mtx);
			return bitmapData;
		}
		/**
		 * 替换为位图 
		 * @param target			目标
		 * @param getVisible		是否只取可见部分
		 * 
		 */		
		public static function replaceWithBitmap(target:DisplayObject):void
		{
			if(target.parent)
			{
				var bmp:Bitmap = DisplayUtil.transferToBitmap(target);
				DisplayUtil.replace(target, bmp);
			}
		}
		/**
		 * 获得可视区域(不透明区域)
		 * @param source
		 * @return 
		 */		
		public static function getVisibleBounds(source:DisplayObject):Rectangle
		{
			//Get the bounds of the source object with respect to itself.
			//So as to calculate the registration point offset.
			var bounds:Rectangle = source.getBounds(source);
			
			var clipRectangle:Rectangle = new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
			if(clipRectangle.isEmpty()) return clipRectangle;
			//Translate the bounds x,y coordinates so that it will clip even source objec
			var matrix:Matrix = new Matrix();
			matrix.translate(-clipRectangle.x, -clipRectangle.y);
			
			//Create the bitmap data
			var bmp:BitmapData = new BitmapData(clipRectangle.width, clipRectangle.height, true, 0x00000000);
			//Draw the item, including the translation
			bmp.draw(source, matrix, null, null, new Rectangle(0,0, clipRectangle.width, clipRectangle.height));
			
			var visibleBounds:Rectangle = bmp.getColorBoundsRect(0xFFFFFFFF, 0x000000, false);
			bmp.dispose();
			visibleBounds.x += clipRectangle.x;
			visibleBounds.y += clipRectangle.y;
			return visibleBounds;
		}
		/**
		 * 检测点是不是在矩形中
		 * @param x
		 * @param y
		 * @param rect
		 */		
		public static function inRect(x:Number, y:Number, rect:Rectangle):Boolean
		{
			return x >= rect.x && x <= rect.x + rect.width && y >= rect.y && y <= rect.y + rect.height;
		}
		/**
		 * 判断触碰 写这几个方法是为了更方便统一修改
		 * @param displayObject1
		 * @param displayObject2
		 * @return 
		 * 
		 */		
		public static function hitTest(displayObject1:DisplayObject, displayObject2:DisplayObject):Boolean
		{
			return displayObject1.hitTestObject(displayObject2);
		}
		/**
		 * 判断点在显示对象内 写这几个方法是为了更方便统一修改
		 * @param displayObject
		 * @param x 相对于舞台的坐标x
		 * @param y 相对于舞台的坐标y
		 * @param shapeFlag 是否根据实际像素 false则只检测矩形边框
		 * @return 
		 * 
		 */		
		public static function hitTestPoint(displayObject:DisplayObject, x:Number, y:Number, shapeFlag:Boolean = false):Boolean
		{
			if(displayObject is Sprite && (displayObject as Sprite).hitArea)
				return (displayObject as Sprite).hitArea.hitTestPoint(x, y, shapeFlag);
			return displayObject.hitTestPoint(x, y, shapeFlag);
		}
		/**
		 * 创建层
		 * @param width 宽度
		 * @param height 高度
		 * @param bgColor 背景色
		 * @param alpha 透明度
		 * @return
		 *
		 */
		public static function createSprite(width:int, height:int, bgColor:uint = 0xFFFFFF, alpha:Number = 1):Sprite
		{
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(bgColor, alpha);
			sp.graphics.drawRect(0, 0, width, height);
			sp.graphics.endFill();
			return sp;
		}
		
		/**
		 * 创建一个矩形矢量
		 * @param width
		 * @param height
		 * @param bgColor
		 * @param alpha
		 * @return
		 *
		 */
		public static function createShape(width:int, height:int, bgColor:uint = 0xFFFFFF, alpha:Number = 1):Shape
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(bgColor, alpha);
			shape.graphics.drawRect(0, 0, width, height);
			shape.graphics.endFill();
			return shape;
		}
		
		/**
		 * 对交互对象禁用鼠标
		 * @param item 要禁用鼠标交互的对象
		 */		
		public static function disableMouse(item:InteractiveObject):void
		{
			item.mouseEnabled = false;
			if(item is DisplayObjectContainer)
				(item as DisplayObjectContainer).mouseChildren = false;
		}
		/**
		 * 启用鼠标交互
		 * @param item
		 * @param mouseChildren
		 */		
		public static function enableMouse(item:InteractiveObject, mouseChildren:Boolean = true):void
		{
			item.mouseEnabled = true;
			if(item is DisplayObjectContainer)
				(item as DisplayObjectContainer).mouseChildren = mouseChildren;
		}
        /**
         * 对交互对象解除禁用
         * @param item  要解除禁用的交互对象
         * 
         */        
        public static function releaseMouse(item:InteractiveObject):void
        {
            item.mouseEnabled = true;
            if(item is DisplayObjectContainer)
                (item as DisplayObjectContainer).mouseChildren = true;
        }
        
		/**
		 * 替换文本框（解决运行时素材文件中放好的文本无法使用嵌入字体的bug）
		 * @param tf	待替换的文本框
		 * @return 		替换后的新文本
		 */		
		public static function replaceTextField(tf:TextField):TextField
		{
			var t:TextField = new TextField;
			/*var description:XML = describeType(tf);
			
			for each (var item:XML in description.accessor)
			{
			// clone passed textfield properties that are not readonly
			if (item.@access == "readwrite" && ignoreList.indexOf(String(item.@name))==-1){ t[item.@name] = tf[item.@name];}
			}*/
			
			t.displayAsPassword 	=	tf.displayAsPassword;
			t.alpha					=	tf.alpha;
			t.defaultTextFormat 	=	tf.defaultTextFormat;
			t.htmlText				=	tf.htmlText;
			t.embedFonts			=	tf.embedFonts;
			t.antiAliasType			=	tf.antiAliasType;
			t.gridFitType			=	tf.gridFitType;
			
			t.width					=	tf.width;
			t.height				=	tf.height;
			t.wordWrap				=	tf.wordWrap;
			t.autoSize				=	tf.autoSize;
			t.blendMode				=	tf.blendMode;
			t.border				=	tf.border;
			t.borderColor			=	tf.borderColor;
			t.cacheAsBitmap			=	tf.cacheAsBitmap;
			t.multiline				=	tf.multiline;
			t.selectable			=	tf.selectable;
			
			//			t.name					= tf.name;
			
			DisplayUtil.replace(tf, t);
			return t;
		}
		
		/**
		 * 设置使用设备字体的文字（解决设备字体不能设置alpha的问题）
		 * @param tf 文本框
		 * @param text 内容
		 * @param isHtml 是否html文本
		 * 
		 */		
		public static function deviceFontSetText(tf:TextField, text:String, isHtml:Boolean = false):void
		{
			var textPropName:String = isHtml?"htmlText":"text";
			var filters:Array = tf.filters;
			tf.filters = null;
			tf[textPropName] = text;
			tf.filters = filters || [new BlurFilter(0, 0, 1)];
		}
		/**
		 * 移除
		 * @param child
		 */		
		public static function remove(child:DisplayObject):void
		{
			if(child && child.parent) child.parent.removeChild(child);
		}
		//		/**
		//		 * 下一帧调用函数 （功能和callLater类似）
		//		 * @param view 只能对可以触发Event.ENTER_FRAME的对象使用这个方法
		//		 * @param method
		//		 * @param params
		//		 * 
		//		 */		
		//		public static function callNextFrame(view:IEventDispatcher, method:Function, 
		//											 params:Array = null):void
		//		{
		//			view.addEventListener(Event.ENTER_FRAME,
		//				function(event:Event):void
		//				{
		//					view.removeEventListener(Event.ENTER_FRAME, arguments.callee);
		//					method.apply(null, params);
		//				}
		//			);
		//		}
		/**
		 * 删除所有子元件 
		 * @param target 操作对象
		 * @param recursive 是否递归删除子子子子元件
		 * @param stopMc 子元件如果是mc 会被stop
		 */		
		public static function removeAllChildren(target:DisplayObjectContainer, recursive:Boolean=false, stopMc:Boolean=true):void
		{
			var numChildren:int = target.numChildren;
			while(numChildren--)
			{
				var child:DisplayObject = target.getChildAt(0);
				if(child is DisplayObjectContainer)
				{
					if(recursive)
						removeAllChildren(child as DisplayObjectContainer, true, stopMc);
					if(stopMc && child is MovieClip)
						(child as MovieClip).stop();
				}
				target.removeChild(child);
			}
		}
		/**
		 * 停止mc
		 * @param tar
		 * @param recursive 递归
		 * @param removeChild 是不是需要从显示列表移除
		 */		
		public static function stop(tar:DisplayObjectContainer, recursive:Boolean=false, removeChild:Boolean=false):void
		{
			var numChildren:int = tar.numChildren;
			while(numChildren--)
			{
				var child:DisplayObject = tar.getChildAt(0);
				if(recursive && (child is DisplayObjectContainer))
				{
					arguments.callee(child as DisplayObjectContainer, recursive, removeChild);
				}
				if(child is MovieClip)
					(child as MovieClip).stop();
				removeChild && remove(child);
			}
		}
		/**
		 * 播放mc
		 * @param tar
		 * @param recursive 递归
		 */		
		public static function play(tar:DisplayObjectContainer, recursive:Boolean=false):void
		{
			var numChildren:int = tar.numChildren;
			while(numChildren--)
			{
				var child:DisplayObject = tar.getChildAt(0);
				if(recursive && (child is DisplayObjectContainer))
				{
					arguments.callee(child as DisplayObjectContainer, recursive);
				}
				if(child is MovieClip)
					(child as MovieClip).play();
			}
		}
		/**
		 * 对MovieClip进行帧播放判断 达到第frames帧就执行onComplete方法 （需要注意的是这个mc这一帧上原有的代码将会被删除）<br>
		 * 要在movieClip最后一帧执行方法的 以后不要侦听enterFrame事件去检测currentFrame==totalFrams了
		 * @param mc
		 * @param onComplete
		 * @param params
		 * @param autoUnwatch 在执行时移除这个帧方法
		 * @param autoStop 在执行onComplete时停止这个MovieClip
		 * @param frames 在第几帧执行方法  可以为帧标签或帧数(从0到totalFrams-1) 默认值为mc的最后一帧
		 */		
		public static function watchMovieClip(mc:MovieClip, onComplete:Function, params:Array=null, autoUnwatch:Boolean=true, autoStop:Boolean=true, autoRemove:Boolean=false, frames:*=NaN):void
		{
			if(isNaN(frames))
				frames = mc.totalFrames - 1;
			mc.addFrameScript(frames, 
				function():void
				{
					new Method(onComplete, params).excute();
					if(autoStop)
						mc.stop();
					if(autoRemove)
						DisplayUtil.remove(mc);
					if(autoUnwatch)
						mc.addFrameScript(frames, null);
				}
			);
		}
		/**
		 * 移除watchMovieClip方法对MovieClip添加的帧方法
		 * @param mc
		 * @param stop
		 * @param frames
		 */		
		public static function unWatchMovieClip(mc:MovieClip, frames:*=NaN):void
		{
			if(isNaN(frames))
				frames = mc.totalFrames - 1;
			mc.addFrameScript(frames, null);
		}
        /**
         * 显示对象居中
         * @param displayObj    显示对象
         * @param parentWidth   父对象宽度
         * @param xAlign        是否在x轴上对齐
         * @param parentHeight  父对象高度
         * @param yAlign        是否在y轴上对齐
         * 
         */        
        public static function alignCenter(displayObj:DisplayObject, 
                                           parentWidth:int = 0, 
                                           xAlign:Boolean = false, 
                                           parentHeight:int = 0, 
                                           yAlign:Boolean = false):void
        {
            if (xAlign)
                displayObj.x = parentWidth - displayObj.width >> 1;
            if (yAlign)
                displayObj.y = parentHeight - displayObj.height >> 1;
        }
        
        /**
         * by Liosixer 刘绍雄 [2013.3.29 11:40] <br/>
         * 复制对象，和替换对象有不同之处.
         * duplicateDisplayObject   
         * creates a duplicate of the DisplayObject passed.
         * similar to duplicateMovieClip in AVM1
         * @param target the display object to duplicate
         * @param autoAdd if true, adds the duplicate to the display list
         * in which target was located
         * @return a duplicate instance of target
         */
        public static function duplicateDisplayObject(target:DisplayObject, autoAdd:Boolean = false):DisplayObject {
            // create duplicate
            var targetClass:Class = Object(target).constructor;
            var duplicate:DisplayObject = new targetClass();
            
            // duplicate properties
            duplicate.transform = target.transform;
            duplicate.filters = target.filters;
            duplicate.cacheAsBitmap = target.cacheAsBitmap;
            duplicate.opaqueBackground = target.opaqueBackground;
            if (target.scale9Grid) {
                var rect:Rectangle = target.scale9Grid;
                // WAS Flash 9 bug where returned scale9Grid is 20x larger than assigned
                // rect.x /= 20, rect.y /= 20, rect.width /= 20, rect.height /= 20;
                duplicate.scale9Grid = rect;
            }
            
            // add to target parent's display list
            // if autoAdd was provided as true
            if (autoAdd && target.parent) {
                target.parent.addChild(duplicate);
            }
            return duplicate;
        }
	}
}