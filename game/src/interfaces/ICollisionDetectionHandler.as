package interfaces {
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	
	import util.Vector2;
		
	public interface ICollisionDetectionHandler {
		function exec( I : ICollider, bounds : Rectangle ) : Vector2;
	}
}