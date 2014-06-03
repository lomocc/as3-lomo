package cc.lomo.managers
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	
	import cc.lomo.interfaces.ILayer;
	import cc.lomo.utils.HashMap;
	
	/**
	 * 可视对象管理类 
	 */
	public class ViewManager
	{
		
		private var _root:DisplayObjectContainer;
		private var _layers:HashMap = new HashMap();
		
		public function ViewManager(pvt : SingletonEnforcer = null)
		{
			if (pvt == null) 
			{ 
				throw new Error("Please use .getInstance()");
			}
		}
		
		/**
		 * 单例 
		 */		
		private static var _instance:ViewManager;
		
		public static function getRoot():DisplayObjectContainer
		{
			return _instance._root;
		}
		
		public static function getStage():Stage
		{
			return _instance._root.stage;
		}


		public static function getInstance():ViewManager
		{
			if(_instance==null) _instance=new ViewManager(new SingletonEnforcer);
			return _instance;
		}
		
		public function init(_root:DisplayObjectContainer):void{
			if(this._root) return;
			this._root=_root;
		}
		
		
		/********************************************************/
		
		
		
		/**
		 * 按名字获取指定层
		 */
		public function getLayerByName(_name:String):ILayer
		{
			return _layers.getValue(_name);
		}
		
		
		/**
		 * 按索引获取层
		 */
		public function getLayerAt(index:int=0):ILayer
		{
			return _root.getChildAt(index) as ILayer;
		}
		
		/**
		 * 添加层
		 */
		public function addLayer(_layer:ILayer):void
		{
			addLayerAt(_layer, _root.numChildren);
		}
		
		
		/**
		 * 增加层到指定位置
		 */
		public function addLayerAt(_layer:ILayer,_index:int):void
		{
			if(!_layers.containsKey(_layer.name))
			{
				_layers.put(_layer.name, _layer);
			}
			this._root.addChildAt(_layer as DisplayObject,_index);
		}
		
		
		/**
		 * 转换两个层的深度
		 */
		public function swapLayer(layer1:ILayer,layer2:ILayer):void
		{
			if(layer1 && _layers.containsValue(layer1) && layer2 && _layers.containsValue(layer2))
			{
			
				_root.swapChildren(layer1 as DisplayObject,layer2 as DisplayObject);
			}
			else
			{
				throw new Error("层不存在舞台");
			}
		}
		
		public function swapLayerByName(name1:String,name2:String):void
		{
			swapLayer(getLayerByName(name1),getLayerByName(name2));
		}
		
		public function getLayerIndex(layer:ILayer):int
		{
			return _root.getChildIndex(layer as DisplayObject);;
		}
		
		/**
		 * 将指定层放到最上面
		 * @param _name	指定层的名字
		 */
		public function setLayerToTopByName(_name:String):void
		{
			var layer:ILayer = this.getLayerByName(_name);
			setLayerToTop(layer);
		}
		
		private function setLayerToTop(layer:ILayer):void
		{
			if(layer)
			{
				addLayer(layer);
			}
			else
			{
				throw new Error("层不存在");
			}
		}		
		
		public function removeLayerByName(_name:String):void
		{
			var layer:ILayer = this.getLayerByName(_name);
			removeLayer(layer);
		}
		
		/**
		 * 移出指定层
		 */
		public function removeLayer(layer:ILayer):void
		{
			
			if(layer && _layers.containsValue(layer))
			{
				_layers.remove(layer.name);
				_root.removeChild(layer as DisplayObject);
			}
			else
			{
				throw new Error("层不存在");
			}
		}
	
		
		
		/**
		 * 隐藏所有层
		 */
		public function hideAllLayerts():void
		{
			_layers.eachValue(
				function (_layer:ILayer):void{
					_layer.hide();
				});
		}
		
		public function hideLayer(_layer:ILayer):void{
			_layer.hide();
		}
		public function hideLayerByName(_name:String):void{
			var layer:ILayer = this.getLayerByName(_name);
			if(layer) hideLayer(layer);
		}
		
		/**
		 * 显示所有层
		 */
		public function showAllLayers():void
		{
			_layers.eachValue(
				function (_layer:ILayer):void{
					_layer.show();
				});
		}
		
		public function showLayer(_layer:ILayer):void{
			_layer.show();
		}
		public function showLayerByName(_name:String):void{
			var layer:ILayer = this.getLayerByName(_name);
			if(layer) showLayer(layer);
		}
		
		/**
		 * 获取层列表 
		 * @return 
		 * 
		 */		
		public function get layers():HashMap
		{
			return this._layers;
		}
	}
}