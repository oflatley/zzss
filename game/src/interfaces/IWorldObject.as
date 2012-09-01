package interfaces {
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;	
	import sim.PlayerSim;	
	import collision.CollisionResult;
	
	public interface IWorldObject {		
		function get id() : String;		
		function get eventDispatcher() : EventDispatcher;
		function get bounds() : Rectangle;
		function set bounds( r:Rectangle ) : void ;
		function get position() : Point;
		function set position( p:Point ) : void ;
		
		function offset( p : Point ) : void ;		
		function setProps( props:Object ) : void ;
		function getYat( x:Number ) : Number;
		function testCollision( iface : ICollider ) : CollisionResult;
		function update() : void;
		function onCollision( player : PlayerSim ) : void;		
		function querry( s : String ) : Boolean; 
	}
}