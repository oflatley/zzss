package sim {
/*
	import interfaces.ICollisionDetectionHandler;
	import interfaces.IOnCollisionHandler;
	import interfaces.IUpdateHandler;
	
	public class WorldObjectBuilder {
		
		private var _onUpdateHandlers : Array = new Array();
		private var _onCollisionHandlers : Array = new Array();
		private var _collisionDetectionHandlers : Array = new Array();

		private var _classes : Array;
		private var _behaviors : Array;
		
		private static var _theThe : WorldObjectBuilder = null;
		
		public static function get instance() : WorldObjectBuilder {
			if( null == _theThe ) {
				_theThe = new WorldObjectBuilder( new SingletonEnforcer() );
			}
			return _theThe;
		}
		
		
		public function WorldObjectBuilder(se:SingletonEnforcer) {
			
			_onCollisionHandlers['modVel'] = OnCollisionModifyVelocity;
			_onCollisionHandlers['modVelTimed'] = OnCollisionModifyVelocityTimed;
			_onCollisionHandlers['tc'] = OnCollisionTreasure;
			_onCollisionHandlers['modSize'] = OnCollisionModifySize;
			
			_onUpdateHandlers['animPlat'] = UpdateAI;
			_onUpdateHandlers['ai'] = UpdateAI;
			
			_collisionDetectionHandlers['never'] = CollisionDetectionNever;

		}
		
		private function getBehaviorSpec( s :String ) : Object {
			
			for each ( var b : Object in _behaviors ) {
				if( s == b.name ) {
					return b;
				}				
			}
			
			throw new Error( "cound not get Behavior for: " + s );
			return null;
		}
		
		private function getClassSpec( s : String ) : Object {

			for each( var c : Object in _classes ) {
				if( s == c.name ) {
					return c;
				}
			}
			throw new Error( "could not get Class for: " + s );
			return null;
		}
		
		public function getBehavior( type : String ) : WorldObjectBehavior  {
			var b : Object = getBehaviorSpec( type ); 
			var c : Object = getClassSpec( type ) ;
			return _buildBehavior( c, b );
		}
		
		private function __build( classSpec : Object , table : Array,  __t : String )  : Object{
			var args : Object = classSpec[__t];
			var k : Class = table[__t];
			var u : * = new k();
			u.init(args);
			return u;
			
		}
		
		private function _buildBehavior( classSpec : Object, behaviorSpec : Object ) : WorldObjectBehavior {
	
			var IUp : IUpdateHandler = __build( classSpec, _onUpdateHandlers, behaviorSpec.update.type ) as IUpdateHandler;
			var IOnC : IOnCollisionHandler = __build( classSpec, _onCollisionHandlers, behaviorSpec.onCollision.type ) as IOnCollisionHandler;
			var ICD : ICollisionDetectionHandler =  __build( classSpec, _collisionDetectionHandlers, behaviorSpec.collisionDetection.type ) as ICollisionDetectionHandler;

			return new WorldObjectBehavior( IUp, IOnC, ICD );
			
			
		}
		
		public function init( spec : Object ) : void {
	
			_classes = spec.classes;
			_behaviors = spec.behaviors;			
		}	
	}
*/	
}
class SingletonEnforcer{}

