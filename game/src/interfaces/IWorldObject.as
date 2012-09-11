package interfaces {
	import collision.CollisionResult;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sim.PlayerSim;
	import sim.WorldObjectBehavior;
	
	public interface IWorldObject {		
		function get id() : String;		
		function get eventDispatcher() : EventDispatcher;
		function get bounds() : Rectangle;
		function set bounds( r:Rectangle ) : void ;
		function get position() : Point;
		function set position( p:Point ) : void ;
		function get center() : Point;
		function get radius() : Number;
		function get behavior() : WorldObjectBehavior;
		function get eventRegistrationAgent() : Function;
		
		function offset( p : Point ) : void ;		
		function querry( s : String ) : Boolean;		
		function testCollision( iface : ICollider ) : CollisionResult;
		function update() : void;
		function onCollision( player : PlayerSim ) : void;		
	}
}