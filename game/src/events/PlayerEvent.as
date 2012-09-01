package events
{
	import flash.events.Event;
	import flash.geom.Point;
	
	public class PlayerEvent extends Event
	{
		public static const PLAYER_MOVE : String = "playerMove";
		public static const PLAYER_SCALE : String = "playerScale";
		public static const PLAYER_DEBUG_INVALIDATE_COLLISION_NODES : String = 'playerDebugInvColNodes';

		public var collisionNodes_debug : Vector.<Point>;
		public var scale : Number;
		public var newPostition : Point;
		
	
		
		public function PlayerEvent(type:String )
		{
			super(type);
		}
	}
}

/*
package events
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import util.Vector2;
	
	public class PlayerEvent extend Event
	{
		public static const PLAYER_MOVE : String = 'playerMove';
		public static const PLAYER_SCALE : String = 'playerScale';
		public static const PLAYER_DEBUG_INVALIDATE_COLLISION_NODES : String = 'playerDebugInvColNodes';
		
		public var collisionNodes_debug : Vector.<Point>;
		public var scale : Number;
		public var vMove : Vector2;
		
		public function PlayerEvent(type:String  )
		{
			super(type);	
		}
	
		public function set scale( n : Number ) {
			_scale = n;
		}
		
		public function get scale() : Number {
			return _scale;
		}
		
		public function set moveVector( v : Vector2 ) {
			_vMove = v;
		}
		
		public function get moveVector( ) {
			return _vMove;
		}
		
		public function set collisionNode_debug( v : Vector.<Point> ) {
			_collisionNodes_debug = v;
		}
		
		public function get collisionNode_debug( ) : Vector.<Point> {
			return _collisionNodes_debug;
		}
		
	}
}
*/
