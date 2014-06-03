package cc.lomo.utils
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import avmplus.describeTypeObject;
	
	import cc.lomo.debug.console;
	
	//[ExcludeClass]
	/**
	 *
	 */
	public class Injector
	{
		/**
		 * 储存的映射规则 key: class/instance
		 */		
		private static var sValueMap:Dictionary = new Dictionary();
		
		/**
		 * 获取完全限定类名
		 */		
		private static function getKey(key:Object, name:String):String
		{
			if(key is String)
				return key + "#" + name;
			return getQualifiedClassName(key) + "#" + name;
		}
		
		/**
		 * 以类定义为值进行映射注入，只有第一次请求它的单例时才会被实例化。
		 * @param interfaceOrClass 注册的类型或接口/也可以是字符串 getInstance的时候也要一样的值
		 * @param instanceOrClass 注册的实体类或实例 （如果是类 那么第一次调用getInstance时会创建一个实例） 如果这个参数为空 那么使用interfaceOrClass（必须为Class）
		 * @param name 可选参数 作为interfaceOrClass之外额外的key
		 */		
		public static function map(interfaceOrClass:Object, instanceOrClass:Object=null, name:String=""):void
		{
			if(!instanceOrClass)
			{
				sValueMap[getKey(interfaceOrClass, name)] = interfaceOrClass;
			}else
			{
				sValueMap[getKey(interfaceOrClass, name)] = instanceOrClass;
			}
		}
		/**
		 * map 相反
		 * @param interfaceOrClass
		 * @param name
		 */		
		public static function unmap(interfaceOrClass:Object, name:String=""):void
		{
			delete sValueMap[getKey(interfaceOrClass, name)];
		}
		/**
		 * 检查指定的映射规则是否存在
		 * @param interfaceOrClass 注册的类型
		 * @param name 可选参数 作为interfaceOrClass之外额外的key
		 */		
		public static function hasMapping(interfaceOrClass:Object, name:String=""):Boolean
		{
			return sValueMap[getKey(interfaceOrClass, name)];
		}
		/**
		 * 获取指定类映射的单例
		 * @param interfaceOrClass 注册的类型
		 * @param name 可选参数 作为interfaceOrClass之外额外的key
		 * @return 
		 */		
		public static function getInstance(interfaceOrClass:Object, name:String=""):*
		{
			var key:String = getKey(interfaceOrClass, name);
			var instanceOrClass:Object = sValueMap[key];
			if(instanceOrClass)
			{
				if(instanceOrClass is Class)
				{
					instanceOrClass = new instanceOrClass();
					sValueMap[key] = instanceOrClass;
				}
				return instanceOrClass;
			}
			console.error("调用了未配置的注入规则！。 请先在项目初始化里配置指定的注入规则，再调用对应单例。", interfaceOrClass, name);
		}
		
		/**
		 * 使用map里的规则 注入标记的public变量
		 * @param target 目标对象
		 * @param metadata 标记的元标签数据 默认Inject
		 * @param name 额外的key 用于区别多个相同类型的数据
		 */		
		public static function injectInto(target:Object, metadata:String="Inject"):void
		{
			var description:Object = describeTypeObject(target.constructor);
			//寻找有没有标记为Inject 如果有 那么就注入
			outer:for each (var variable:Object in description.traits.variables)
			{
				for each (var meta:Object in variable.metadata) 
				{
					if(meta.name != metadata)
						continue;
					for each (var v:Object in meta.value) 
					{
						if(v.key == "" || v.key == "name")
						{
							target[variable.name] = getInstance(variable.type, v.value);
							continue outer;
						}
					}
					target[variable.name] = getInstance(variable.type);
					continue outer;
				}
			}
		}
	}
}