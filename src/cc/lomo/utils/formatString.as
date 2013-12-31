package cc.lomo.utils
{
	// TODO: add number formatting options
	
	/** Formats a String in .Net-style, with curly braces ("{0}"). Does not support any 
	 *  number formatting options yet. */
	public function formatString(format:String, ...args):String
	{
		for(var i:int=0,l:int=args.length;i<l;++i)
			format = format.replace(new RegExp("\\{"+i+"\\}","g"),args[i]);
		return format;
	}
}