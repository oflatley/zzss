package interfaces
{
	import flash.events.EventDispatcher;

	public interface IQuerryHandler {
		function exec( keyToFind : String ) : Boolean; 
	}
}