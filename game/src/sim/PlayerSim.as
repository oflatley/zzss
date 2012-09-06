package sim
{
	import events.CollisionEvent;
	import events.ControllerEvent;
	import events.PlayerEvent;
	import events.RemoveFromWorldEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.setInterval;
	
	import interfaces.ICollider;
	import interfaces.IWorldObject;
	
	import io.Controller;
	
	import collision.CollisionManager;
	import collision.CollisionResult;
	import io.Controller;
	import util.Vector2;
	
	import views.PlayerView;
	
	
	public class PlayerSim extends EventDispatcher implements ICollider
	{
		private static const TERMINAL_VELOCITY:Number = 6;		// TODO percentage

		private var _playerController : Controller;
		private var _velocityX:Number = 0;
		private var _velocity:Vector2 = new Vector2();
		private var _gravity:Number;
		private var _nCoins : int;
		private var _speedMultiplier : Number = 1.0;
		private var _isCollideable : Boolean = true;
		private var _dragX:Number = 2;
		private var _objectUnderfootThisFrame:IWorldObject = null;
		private var _objectUnderfootPreviousFrame:IWorldObject = null;
		private var _bounds : Rectangle = new Rectangle();	
		private var _originalSpan : Point = new Point(); // support for scaling
		private var _scaleOffsetY : Number = 0;  // support for scaling
		private var _collisionList : Array = new Array();
		private var _localCollisionTestPoints : Vector.<Point> = new Vector.<Point>(4);
		private var _collisionTestPointsWalking : Vector.<Point> = new Vector.<Point>(1);
		private var _collisionTestPointsJumping : Vector.<Point> = new Vector.<Point>(4);
		private var _collisionTestPointsJumpingUp : Vector.<Point> = new Vector.<Point>(5);
		private var _registrationPointOffset:Point;
		
		public function PlayerSim( controller:Controller, velX:Number, gravity:Number, bounds:Rectangle, _collisionMgr : CollisionManager )
		{
	
			trace('PlayerSim ctr ... velocity: ' + _velocity.x + ' ' +_velocity.y );	
			super(null);
			reset();
				
			_velocityX = velX;
			_gravity = gravity ;			
			_playerController = controller;			
			_playerController.addEventListener(ControllerEvent.JUMP, onJump );		
			_collisionMgr.addEventListener(CollisionEvent.PLAYERxWORLD, onCollision_playerVsWorld );		
			_bounds = bounds; 
			_originalSpan.offset( _bounds.width, _bounds.height );

			initLocalCollisionTestPoints(1);	
			initCollisionTestPoints( _collisionTestPointsWalking );
			initCollisionTestPoints( _collisionTestPointsJumping );
			initCollisionTestPoints( _collisionTestPointsJumpingUp );			
		}
		
		private function initLocalCollisionTestPoints( scale : Number ) : void {
			
			var right : Number = scale * _originalSpan.x;
			var bottom : Number = scale * _originalSpan.y;
			var halfW : Number = _originalSpan.x / 2;
			var halfH : Number = _originalSpan.y / 2;
			
			_localCollisionTestPoints[0] = new Point( halfW, 		bottom );		// bottom mid
			_localCollisionTestPoints[1] = new Point( right,  		.75 * bottom ); 	// right, bottom .25
			_localCollisionTestPoints[2] = new Point( right, 		.5 * bottom  ); 	// right, mid
			_localCollisionTestPoints[3] = new Point( right, 		.25	 * _bounds.height); 	// right, top.75
			_localCollisionTestPoints[4] = new Point( right, 			0  ); 							// right, mid
			_localCollisionTestPoints[5] = new Point( right - halfW,	0); 								// right, top.75			
		}
		
		private function initCollisionTestPoints( v : Vector.<Point> ) : void {
			for( var i : int = 0; i < v.length; ++i ) {
				v[i] = new Point();
			}
		}
		
		private function get canJump() : Boolean {
			return _objectUnderfootThisFrame && _isCollideable;
		}

		private function reset(): void {
			_nCoins = 0;
		}
		
		public function addCoins( n : int ) : void {
			_nCoins += n;
		}

		private function dispatchMoveAndScale( scale : Number, pos : Point ) : void {
			var e :PlayerEvent = new PlayerEvent( PlayerEvent.PLAYER_MOVE );
			e.newPostition = pos;
			dispatchEvent( e );			
			e  = new PlayerEvent( PlayerEvent.PLAYER_SCALE );
			e.scale = scale;
			dispatchEvent( e );			
		}
		
		
		public function scale( n : Number, duration : Number ) : void {
		
			var h : Number = _originalSpan.y * n;
			_scaleOffsetY = _bounds.height - h;			
			_bounds.y = _bounds.bottom - h;			
 			_bounds.width = _originalSpan.x * n;
			_bounds.height = h;
			initLocalCollisionTestPoints(n);
			dispatchMoveAndScale( n, _bounds.topLeft );			
			setInterval( restoreNormalScale, duration );
		} 
		
		private function restoreNormalScale() : void  {
			_bounds.width = _originalSpan.x;
			_bounds.height = _originalSpan.y;
			_bounds.y -= _scaleOffsetY;
		
			initLocalCollisionTestPoints(1);
			dispatchMoveAndScale( 1, _bounds.topLeft );
		}
		
		public function addSpeedBoost( duration_ms : int, speedMultiplier : Number ) : void {
			_speedMultiplier = speedMultiplier;
			setInterval( endSpeedBoost, duration_ms );
		}
			
		public function applyImpulse( p : Point ) : void {
			_velocity.x += p.x;
			_velocity.y += p.y;
		}
		
		private function endSpeedBoost() : void {
			_speedMultiplier = 1;
		}
		
		public function Update() : void {
			//trace( (_objectUnderfootPreviousFrame != null) + ' ' + (_objectUnderfootThisFrame != null) ); 
			
			//trace( _velocity.x + ' ' + _velocity.y );
			
			move(_velocity);
			applyPendingCollisions();
			
  			//var pos:Vector2 = new Vector2();
			//pos.x += _velocity.x * _speedMultiplier;

			_velocity.x -= _dragX;
			if( _velocity.x < _velocityX ) {
				_velocity.x = _velocityX;
			}
			
			if(_objectUnderfootThisFrame ) {
				_velocity.y = _gravity;
			} else {
				_velocity.y += _gravity;

				if( _velocity.y > TERMINAL_VELOCITY ) {
					_velocity.y = TERMINAL_VELOCITY;
				}
			}
						
//			pos.y += _velocity.y;			
//			move( pos ); 		
			
			_objectUnderfootPreviousFrame = _objectUnderfootThisFrame;
			_objectUnderfootThisFrame = null; 			
		}

		
		private function move( v:Vector2 ) : void {			
			move_xy( v.x, v.y );
		}
		
		private function move_xy( x : Number, y : Number ) : void {
			worldPosition = new Point( x + worldPosition.x, y + worldPosition.y);
			buildCollisionTestPoints();			
		}
		
		private function onJump( e:Event ) : void {
			if( canJump ) {
				_velocity.y -= 20;
				_objectUnderfootThisFrame = null;
			}
			else {
 				trace('jump denied');
			}
		}

		private function applyCollision( cr : CollisionResult ) : Vector2 {
 			
			var wo : IWorldObject = cr.collidedObj;
			var v : Vector2 = cr.msv;
			
			if( v.y < 0 ) {
				_objectUnderfootThisFrame = wo;
			}
			
			
			
			if( wo.querry( WorldObjectFactory.Q_MONSTER ) ) {  
				
				if( v.y < 0 && -v.y > Math.abs(v.x) ) {
					// player hit monster from above --> Kill the monster
					dispatchEvent( new RemoveFromWorldEvent( RemoveFromWorldEvent.REMOVE_FROM_WORLD, wo ) );
					_velocity.y -= 20;
				}
				else {
					// player hit monster from the side or from below --> penalize player
					//trace('from side or below');
					_isCollideable = false;
					setInterval( restoreCollisionEnabled, 1000 );
				}
				v.setxy(0,0);
			}
			else if( wo.querry( WorldObjectFactory.Q_CONSUMABLE ) ) {
				v.setxy(0,0);	
			}				
			else
			{
				var bCollisionFromBelow : Boolean = v.y > 0;
				
				if( bCollisionFromBelow && !wo.querry( WorldObjectFactory.Q_COLLIDEABLE_FROM_BELOW )){
					v.setxy(0,0)
				}
				else { 					
					if( _objectUnderfootThisFrame ) {
						
						if( _objectUnderfootThisFrame == wo ) {
							// walking, dont apply x, only want to match surface height
							v.x = 0;
						}
						else {
							v.y = 0;
						}
					}
					else {
						// in jumping/falling, apply collisions as follows:
						v.y = 0;
					}
					
					//move( v );
  					velocity.x += v.x;
					velocity.y += v.y;
				}
			}
			return v;
		}
		
		private function applyPendingCollisions() : void {
			
			var len : int = _collisionList.length;
			
			if( len ) {
				var minX : Number = Infinity;
				var minY : Number = Infinity;
				
				for each( var cr : CollisionResult in _collisionList ) {
					var v : Vector2 = applyCollision( cr );
					minX = Math.min( v.x, minX );
					minY = Math.min( v.y, minY );
					move(v);
				}
				
				// TODO, this assumes collision going down and to the right -- fix it
				move_xy( minX, minY ); 
				_collisionList.splice( 0 , _collisionList.length );		
			}
		}
		
		private function onCollision_playerVsWorld( collisionEvent : CollisionEvent ) : void {		
			//_collisionList.push( collisionEvent.collisionResult );
			applyCollision( collisionEvent.collisionResult );		
		}
		
		private function restoreCollisionEnabled():void
		{
			_isCollideable = true; 
		}
		
		public function get worldPosition():Point
		{
			return _bounds.topLeft; 
		}

		public function set worldPosition(value:Point):void
		{
			_bounds.x = value.x;
			_bounds.y = value.y;
			
			var event : PlayerEvent = new PlayerEvent( PlayerEvent.PLAYER_MOVE );
			event.newPostition = value;
			dispatchEvent( event );
			
//			view.SetPosition( value );
			buildCollisionTestPoints();
		}
		
		public function SetPosition( value:Point) : void {
 			worldPosition = value;
			buildCollisionTestPoints();
		}
		
		public function get bounds():Rectangle
		{
			return _bounds; 
		}
		
		public function get collisionTestPoints():Vector.<Point>
		{
			if( _objectUnderfootThisFrame ) {
				return _collisionTestPointsWalking;
			}
			
			if( _velocity.y < 0 ) { // we are ascending and jumping 
				return _collisionTestPointsJumpingUp;
			}
			return _collisionTestPointsJumping;
		}
		
		private function buildCollisionTestPoints() : void {
			
			_collisionTestPointsWalking[0].x = _localCollisionTestPoints[0].x + _bounds.x;
			_collisionTestPointsWalking[0].y = _localCollisionTestPoints[0].y + _bounds.y;

			for( var i : int = 0; i < _collisionTestPointsJumping.length; ++i ) {
				_collisionTestPointsJumping[i].x = _localCollisionTestPoints[i].x + _bounds.x;
				_collisionTestPointsJumping[i].y = _localCollisionTestPoints[i].y + _bounds.y;				
			}
			
			_collisionTestPointsJumpingUp[0].x = _localCollisionTestPoints[5].x + _bounds.x;
			_collisionTestPointsJumpingUp[0].y = _localCollisionTestPoints[5].y + _bounds.y;
			_collisionTestPointsJumpingUp[1].x = _localCollisionTestPoints[4].x + _bounds.x;
			_collisionTestPointsJumpingUp[1].y = _localCollisionTestPoints[4].y + _bounds.y;
			_collisionTestPointsJumpingUp[2].x = _localCollisionTestPoints[3].x + _bounds.x;
			_collisionTestPointsJumpingUp[2].y = _localCollisionTestPoints[3].y + _bounds.y;
			_collisionTestPointsJumpingUp[3].x = _localCollisionTestPoints[2].x + _bounds.x;
			_collisionTestPointsJumpingUp[3].y = _localCollisionTestPoints[2].y + _bounds.y;
			_collisionTestPointsJumpingUp[4].x = _localCollisionTestPoints[1].x + _bounds.x;
			_collisionTestPointsJumpingUp[4].y = _localCollisionTestPoints[1].y + _bounds.y;
			
			
			var event : PlayerEvent = new PlayerEvent( PlayerEvent.PLAYER_DEBUG_INVALIDATE_COLLISION_NODES );
			event.collisionNodes_debug = collisionTestPoints;
			dispatchEvent( event );
		}
		
		public function get velocity():Vector2
		{
			return _velocity;
		}		
	}
}