package cc.lomo.utils
{
	public class StringUtil
	{
		public static const r1:RegExp = /(?<=[(\[<]).*?(?=[)\]>])/g;//匹配两个括号里的字符
		public static const r2:RegExp = /(?<=\().*?(?=\))/g;//匹配两个括号里的字符
		public static const r3:RegExp = /(?<=[(\[<]).*?(?=[)\]>])/g;//匹配两个括号里的字符
	}
}