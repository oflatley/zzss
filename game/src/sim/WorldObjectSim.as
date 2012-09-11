package sim {
	import collision.CollisionResult;
	
	import events.WorldObjectEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import interfaces.ICollider;
	import interfaces.ICollisionDetectionHandler;
	import interfaces.IOnCollisionHandler;
	import interfaces.IQuerryHandler;
	import interfaces.IUpdateHandler;
	import interfaces.IWorldObject;
	import interfaces.IWorldObjectBehaviorOwner;
	
	import sim.PlayerSim;
	import sim.WorldObjectBehavior;
	
	import util.Vector2;
	
	public class WorldObjectSim extends EventDispatcher implements IWorldObject, IWorldObjectBehaviorOwner {
		
		private var _bounds : Rectangle;
		private var _id : String;

		private var _IUpdate : IUpdateHandler;
		private var _IOnCollision : IOnCollisionHandler;
		private var _ICollisionDetection : ICollisionDetectionHandler;
		private var _IQuerry : IQuerryHandler;
		private var _behavior : WorldObjectBehavior;
		
		private var _center : Point;
		private var _radius : Number;
//		private var _dispatchesEvent : Boolean;
		
		public function WorldObjectSim( id : String, bounds : Rectangle, behavior : WorldObjectBehavior ) {
			super();
			_id = id;
			_bounds = bounds;
			_ICollisionDetection = behavior.ICollisionDetection;
			_IOnCollision = behavior.IOnCollision;
			_IUpdate = behavior.IUpdate;
			_IQuerry = behavior.IQuerry;
			_behavior = behavior;
//			_dispatchesEvent = behavior.isEventDispatcher;
			
			// collision, broad
			var halfWidth : Number = bounds.width/2;
			var halfHeight : Number = bounds.height /2 ;
			_center = new Point( bounds.left + halfWidth, bounds.top + halfHeight );		
			_radius = Math.sqrt( halfWidth*halfWidth + halfHeight*halfHeight );
			
		}
		
		public function get behavior () : WorldObjectBehavior {
			return _behavior;
		}
		
		private function registerEvent( classFilter : Class, type: String, listener : Function ) : void {
			behavior.registerEvent( classFilter, type, listener );
		//	if( _ICollisionDetection is classFilter ) 
		//		_ICollisionDetection.eventDispatcher.addEventListener( type, listener ); 
		}
		
		public function get eventRegistrationAgent() : Function {
			return registerEvent;
		}
		
		public function get center() : Point {
			return _center;
		}
		
		public function get radius() : Number {
			return _radius;
		}
		
		public function get id() : String {
			return _id;
		}
		
		public function get bounds() : Rectangle {
			return _bounds;
		}
		
		public function set bounds( r : Rectangle ) : void {
			_bounds = r;
		}		
		
		public function get position():Point
		{
			return _bounds.topLeft;
		}
		
		public function set position(p:Point):void
		{
			_bounds.x = p.x;
			_bounds.y = p.y;

			var halfWidth : Number = bounds.width/2;
			var halfHeight : Number = bounds.height /2 ;
			_center.setTo( bounds.left + halfWidth, bounds.top + halfHeight );		
			
			dispatchEvent( new WorldObjectEvent( WorldObjectEvent.WORLDOBJECT_MOVE ) );
		}

		public function offset(p:Point):void
		{
			_bounds.offsetPoint(p);
			_center.offset(p.x,p.y);
			dispatchEvent( new WorldObjectEvent( WorldObjectEvent.WORLDOBJECT_MOVE) );
		}

		
		public function get eventDispatcher():EventDispatcher
		{
			return this;
		}				

		public function onCollision(player:PlayerSim):void
		{
			_IOnCollision.exec(player);
		}
		
		public function querry( s : String ) : Boolean {	
			return _IQuerry.exec(s);
		}

		public function update():void
		{
			_IUpdate.exec(this);
		}
						
		public function testCollision( iCol: ICollider ) : collision.CollisionResult {			
			var msv : Vector2 =  _ICollisionDetection.exec( iCol, _bounds );
			return msv ? new CollisionResult( msv, this ) : null;
		}
	}
}
	