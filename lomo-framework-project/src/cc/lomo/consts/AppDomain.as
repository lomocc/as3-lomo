/**
 * Created with IntelliJ IDEA.
 * User: vincent
 * Time: 2014/4/24 22:22
 * To change this template use File | Settings | File Templates.
 */
package cc.lomo.consts
{
	import flash.system.ApplicationDomain;

	public class AppDomain
	{
		public function AppDomain()
		{
		}

		/**
		 * 当前域 一些ui资源
		 */
		public static const currentDomain:ApplicationDomain = ApplicationDomain.currentDomain;
		/**
		 * 每次生成一个新域 用来存放命名冲突的资源 （按文件名或者路径单独存放的资源）
		 * @return
		 */
		public static function get singleDomain():ApplicationDomain { return new ApplicationDomain(currentDomain);}
		/**
		 * 通过反射名不同 获取的资源域 （打包导出的资源）
		 */
		public static const resourceDomain:ApplicationDomain = singleDomain;
	}
}
