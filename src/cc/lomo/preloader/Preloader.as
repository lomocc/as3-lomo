package cc.lomo.preloader
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	/**
	 * 功能：SWF自身的加载条<br/>
	 * 用法：在需要实现自加载的类声明前加上<code>[Frame(factoryClass="cc.lomo.preloader.Preloader")]</code>
	 * @author vincent
	 */	
	public class Preloader extends MovieClip
	{
		/**
		 * 是否本地运行 
		 */
		protected var mNative:Boolean;
		/**
		 * 模拟当前加载量(本地运行时)
		 */
		protected var mIndex:int	= 0;
		/**
		 * 模拟最大加载量(本地运行时)
		 */
		protected const mMax:int	= 100;
	
		public function Preloader()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		protected function addedToStageHandler(e:*):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			//如果已经加载完，那估计就是本地运行了，这时候我们只有搞个假的Preloader了
			mNative = loaderInfo.bytesLoaded == loaderInfo.bytesTotal;
			
			addListeners();
		}
		/**
		 * 
		 * 侦听加载事件
		 */		
		protected function addListeners():void
		{
			if(mNative)
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			else
			{
				loaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				loaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			}
		}
		/**
		 * 
		 * 移除加载事件
		 */		
		protected function removeListeners():void
		{
			if(mNative)
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			else
			{
				loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
				loaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			}
		}
		/**
		 * 用ENTER_FRAME模拟加载事件(本地运行时)
		 * @param e
		 * 
		 */		
		protected function enterFrameHandler(event:Event):void
		{
			mIndex ++;
			setProgress(mIndex / mMax);
			mIndex > mMax && completeHandler(null);
		}
		/**
		 * 显示进度条
		 * @param value 进度比 0.0 ~ 1.0
		 * 
		 */		
		protected function setProgress(value:Number):void
		{
			graphics.clear();
			if(value == 1)
				return;
			graphics.beginFill(0);
			graphics.drawRect(0,stage.stageHeight/2, value * stage.stageWidth, 1);
			graphics.endFill();
		}
		/**
		 * 加载事件
		 * @param e
		 * 
		 */		
		protected function progressHandler(e:*):void
		{
			setProgress(loaderInfo.bytesLoaded/loaderInfo.bytesTotal)
		}
		protected function completeHandler(event:Event):void
		{
			removeListeners();
			
			addEventListener(Event.ENTER_FRAME, init);
		}
		/**
		 * 加载完成后 构造主程序
		 */
		protected function init(event:Event):void
		{
			//currentLabels[1].name 获得第二帧的标签 也就是主程序的类名以"_"连接如：com_adobe_class_Main,我们需要将其转换为com.adobe.class::Main这样的格式
			var prefix:Array = currentLabels[1].name.split("_");
			var suffix:String = prefix.pop();
			var cName:String =	prefix.join(".") + "::" + suffix;
			//判断是否存在主程序的类
			if(loaderInfo.applicationDomain.hasDefinition(cName))
			{
				//知道存在主程序的类了，删除enterFrame的侦听
				removeEventListener(event.type, arguments.callee);
				
				var cls:Class = loaderInfo.applicationDomain.getDefinition(cName) as Class;
				var main:DisplayObject = new cls();
				parent.addChild( main );
				parent.removeChild(this);
			}
		}
		
	}
}