package cc.lomo.utils
{
	import flash.external.ExternalInterface;

	public function debug(...rest):void
	{
		trace.apply(null, rest);
		var fn:String = formatString('function(){alert("{0}")}', rest.join(", "));
		ExternalInterface.call(fn);
	}
}