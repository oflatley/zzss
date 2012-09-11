package interfaces {
	import flash.events.EventDispatcher;

	public interface IUpdateHandler {
		function exec(I:IWorldObjectBehaviorOwner) : void;
	}
}