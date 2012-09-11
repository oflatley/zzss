package interfaces {
	import flash.events.EventDispatcher;
	
	import sim.PlayerSim;

	public interface IOnCollisionHandler  {
		function exec( p : PlayerSim ) : void ;
		function registerEvent( classFilter : Class, type : String, listener : Function ) : void ;
		function get eventDispatcher() : EventDispatcher;
	}
}