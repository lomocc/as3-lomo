/*
Copyright aswing.org, see the LICENCE.txt.
*/

package cc.lomo.utils
{
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;
	
	public class Reflection
	{
		/**
		 * 根据类名 创建对象
		 * @param fullClassName
		 * @param applicationDomain
		 * @return 
		 * 
		 */		
		public static function createInstance(fullClassName:String, applicationDomain:ApplicationDomain=null):*
		{
			var assetClass:Class = getClass(fullClassName, applicationDomain);
			if(assetClass)
				return new assetClass();
			return null;		
		}
		
		public static function createInstance(fullClassName:String, params:Array=null, applicationDomain:ApplicationDomain=null):*
		{
			if(!params)
				return createInstance(fullClassName, applicationDomain);
			var assetClass:Class = getClass(fullClassName, applicationDomain);
			return assetClass?apply(assetClass, params):null;
		}
		public static function getClass(fullClassName:String, applicationDomain:ApplicationDomain=null):Class
		{
			if(!applicationDomain)
				applicationDomain = ApplicationDomain.currentDomain;
			return applicationDomain.getDefinition(fullClassName) as Class;		
		}
		
		public static function getFullClassName(o:*):String{
			return getQualifiedClassName(o);
		}
		
		public static function getClassName(o:*):String{
			var name:String = getFullClassName(o);
			var lastI:int = name.lastIndexOf(".");
			if(lastI >= 0){
				name = name.substr(lastI+1);
			}
			return name;
		}
		
		public static function getPackageName(o:*):String{
			var name:String = getFullClassName(o);
			var lastI:int = name.lastIndexOf(".");
			if(lastI >= 0){
				return name.substring(0, lastI);
			}else{
				return "";
			}
		}
		
		/**
		 * 用参数数组来构造类
		 *  
		 * @param generator
		 * @param args
		 * @return 
		 */
		public static function apply(generator:Class,params:Array=null):*
		{
			if (params) 
				return (applyFuns[params.length] as Function)(generator,params);
			else
				return new generator();
		}
		
		private static const applyFuns:Array = [apply0,apply1,apply2,apply3,apply4,apply5,apply6,apply7,apply8,apply9,apply10,apply11,apply12];
		private static function apply0(generator:Class,args:Array):*{return new generator()};
		private static function apply1(generator:Class,args:Array):*{return new generator(args[0])};
		private static function apply2(generator:Class,args:Array):*{return new generator(args[0],args[1])};
		private static function apply3(generator:Class,args:Array):*{return new generator(args[0],args[1],args[2])};
		private static function apply4(generator:Class,args:Array):*{return new generator(args[0],args[1],args[2],args[3])};
		private static function apply5(generator:Class,args:Array):*{return new generator(args[0],args[1],args[2],args[3],args[4])};
		private static function apply6(generator:Class,args:Array):*{return new generator(args[0],args[1],args[2],args[3],args[4],args[5])};
		private static function apply7(generator:Class,args:Array):*{return new generator(args[0],args[1],args[2],args[3],args[4],args[5],args[6])};
		private static function apply8(generator:Class,args:Array):*{return new generator(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7])};
		private static function apply9(generator:Class,args:Array):*{return new generator(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8])};
		private static function apply10(generator:Class,args:Array):*{return new generator(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9])};
		private static function apply11(generator:Class,args:Array):*{return new generator(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10])};
		private static function apply12(generator:Class,args:Array):*{return new generator(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10],args[11])};
	}
	
}