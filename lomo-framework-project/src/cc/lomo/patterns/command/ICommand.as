package cc.lomo.patterns.command
{
	import cc.lomo.patterns.observer.Notification;

	public interface ICommand
	{
		function execute(notification:Notification):void
	}
}