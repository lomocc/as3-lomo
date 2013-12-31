﻿package cc.lomo.utils
{
	import flash.utils.*;
	import flash.system.*;
	import flash.errors.*;

		/**
		* Class for working with object classes/definitions.
		* 	Allows you to create instances of classes by name or Class object.
		* @example
<listing version="3.0">
package {
	import aw.utils.ClassUtils;
	
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	public class Test extends Sprite{
		public function Test():void{
			super();
			var filter1:DropShadowFilter = ClassUtils.apply(DropShadowFilter, [4, 45, 0, 1, 4, 4, 1]);
			var filter2:DropShadowFilter = ClassUtils.applyByName("flash.filters.DropShadowFilter", [4, 45, 0, 1, 4, 4, 1]);
			var filter3:DropShadowFilter = ClassUtils.call(DropShadowFilter, 4, 45, 0, 1, 4, 4, 1);
			var filter4:DropShadowFilter = ClassUtils.callByName("flash.filters.DropShadowFilter", 4, 45, 0, 1, 4, 4, 1);
		}
	}
}
</listing>
		* Provides a method for obtaining an class instance from Class object.
		* @example
<listing version="3.0">
package {
	import aw.utils.ClassUtils;
	
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	public class Test extends Sprite{
		public function Test():void{
			super();
			trace(ClassUtils.getClassDefinition(this));
			var filter:DropShadowFilter = new DropShadowFilter();
			trace(ClassUtils.getClassDefinition(filter));
		}
	}
}
/&#042; trace output
[class Test]
[class DropShadowFilter]
&#042;/
</listing>
		* @author Galaburda a_[w] Oleg	  http://www.actualwave.com 
		* @playerversion Flash 9.0.28.0
		* @langversion 3.0
		*/
	public class ClassUtils extends Object{
		
		
		/**
		* @private
		*/
		static public const WRONG_NAME_ERROR:String = 'ClassUtils Error: can\'t found [$cls] class definition by name';

		/**
		* @private (protected)
		*/
		static protected const classCallers:Array = [call0Class, call1Class, call2Class, call3Class, call4Class, call5Class, call6Class, call7Class, call8Class, call9Class, call10Class, call11Class, call12Class, call13Class, call14Class, call15Class];

		/**
		* Returns an Class object by its instance
		* 
		* @param any Class instance  
		* @return Class
		* @playerversion Flash 9.0.28.0
		* @langversion 3.0
		*/
		static public function getClassDefinition(any:*):Class{
			var cls:Object = null;
			if(any is Proxy) cls = getDefinitionByName(getQualifiedClassName(any));
			else cls = Object(any).constructor;
			return cls as Class;
		}

		/**
		* Returns the name of the class.
		* 
		* @param cls Class object, a instance of it or name (if set name of a non-existent class, it returns the class name "String")
		* @return String
		* @playerversion Flash 9.0.28.0
		* @langversion 3.0
		*/
		static public function getClassName(cls:*):String{
			if(cls is String && ApplicationDomain.currentDomain.hasDefinition(cls)) return cls;
			else return getQualifiedClassName(cls);
		}

		/**
		* Emulates the same method of the Function class.
		* 
		* @param cls Class object, a copy of which will be retrieved
		* @param arr List of parameters for constructor
		* @return *
		* @playerversion Flash 9.0.28.0
		* @langversion 3.0
		*/
		static public function apply(cls:Object, arr:Array=null):*{
			if(!arr) arr = [];
			var f:Function = classCallers[arr.length];
			if(f!=null) return f(cls, arr);
			else throw new Error(cantCreateErrorString(getQualifiedClassName(cls)));
		}

		/**
		* Creates a copy of the class by its name, passing in the constructor parameters from the array
		* 
		* @param name Class name, which instance to get
		* @param arr List of parameters for constructor
		* @return *
		* @playerversion Flash 9.0.28.0
		* @langversion 3.0
		*/
		static public function applyByName(name:String, arr:Array=null):*{
			var ad:ApplicationDomain = ApplicationDomain.currentDomain;
			var cls:Class;
			if(ad.hasDefinition(name)){
				cls = ad.getDefinition(name) as Class;
			}
			if(!cls) throw new IllegalOperationError(WRONG_NAME_ERROR.split('$cls').join(name));
			if(!arr) arr = [];
			var f:Function = classCallers[arr.length];
			if(f!=null) return f(cls, arr);
			else throw new Error(cantCreateErrorString(name));
		}
	}
}