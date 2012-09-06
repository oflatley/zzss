package sim
{
	import avmplus.getQualifiedClassName;
	
	import collision.CollisionDataProvider;
	import collision.CollisionResult;
	
	import events.CollisionEvent;
	import events.WorldObjectEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import interfaces.ICollisionDetectionHandler;
	import interfaces.IOnCollisionHandler;
	import interfaces.IQuerryHandler;
	import interfaces.IUpdateHandler;
	import interfaces.IWorldObject;
	
	
	public class WorldObjectFactory {

		// querry strings
		public static const Q_CONSUMABLE : String = "Consumable";
		public static const Q_MONSTER : String = "Monster";
		public static const Q_COLLIDEABLE_FROM_BELOW : String = "CollideFromBelow";
				
		private static var theWorldObjectFactory : WorldObjectFactory = null;		

		private var _onUpdateHandlers : Array = new Array();
		private var _onCollisionHandlers : Array = new Array();
		private var _collisionDetectionHandlers : Array = new Array();
		private static var _DEFAULTKEY : String = '_DEFAULT_';		
		
		private var _spec : Object;
		
		public static function get instance() : WorldObjectFactory {
			if( null == theWorldObjectFactory ) {
				theWorldObjectFactory = new WorldObjectFactory(new SingletonEnforcer());
			}
			return theWorldObjectFactory;
		}
		
		public function init( spec : Object ) : void {			
			_spec = spec;
			_spec.classes.push({name:_DEFAULTKEY,behavior:_DEFAULTKEY});
			_spec.behaviors.push({name:_DEFAULTKEY});
		}	
		
		public function WorldObjectFactory( makeThisConstructorUnusable : SingletonEnforcer ) {
		
			_onCollisionHandlers[_DEFAULTKEY] = OnCollisionDefault;
			_onCollisionHandlers['modVel'] = OnCollisionModifyVelocity;
			_onCollisionHandlers['modVelTimed'] = OnCollisionModifyVelocityTimed;
			_onCollisionHandlers['tc'] = OnCollisionTreasure;
			_onCollisionHandlers['modSize'] = OnCollisionModifySize;
			
			_onUpdateHandlers[_DEFAULTKEY] = UpdateDefault;
			_onUpdateHandlers['animPlat'] = UpdateAnimatedPlatform;
			_onUpdateHandlers['ai'] = UpdateAI;
			
			_collisionDetectionHandlers[_DEFAULTKEY] = CollisionDetectionDefault;	
			_collisionDetectionHandlers['never'] = CollisionDetectionNever;	
		}
		
		
		public function createWorldObject( type : String, bounds : Rectangle ) : IWorldObject {
			var wob : WorldObjectBehavior = getBehavior( type );
			return new WorldObjectSim( type, bounds, wob ) ;
		}

		private function getBehavior( type : String ) : WorldObjectBehavior  {
			var c : Object = getClassSpec( type ) ;
			
			if( !c ) {
				trace('could not find class spec for ' + type + '. Using default' );
				c = getClassSpec( _DEFAULTKEY );
			}
			
			var b : Object = getBehaviorSpec( c.behavior ); 
			
			if (!b) {
				throw new Error( 'Could not find behavior spec for ' + type + ' | ' + c.behavior );
			}
			
			return _buildBehavior( c, b );
		}
		
		private function _buildBehavior( classSpec : Object, behaviorSpec : Object ) : WorldObjectBehavior {
			
			var IUp : IUpdateHandler = __build( classSpec, _onUpdateHandlers, behaviorSpec.update ) as IUpdateHandler;
			var IOnC : IOnCollisionHandler = __build( classSpec, _onCollisionHandlers, behaviorSpec.onCollision ) as IOnCollisionHandler;
			var ICD : ICollisionDetectionHandler =  __build( classSpec, _collisionDetectionHandlers, behaviorSpec.collisionDetection ) as ICollisionDetectionHandler;
			var IQ : IQuerryHandler = new QuerryHandler( behaviorSpec.properties ) ;
			
			return new WorldObjectBehavior( IUp, IOnC, ICD , IQ );
		}

		private function __build( classSpec : Object , table : Array,  ifaceCatagory : Object )  : Object{
			
			// ifaceCatagory is the key to the correct set of handlers  e.g. onCollision[], update[], collisionDetection[], etc
			// _type is a particular handler within the specified set.. we use 'default' if behavior did not specify override behavior for the catagory
			// -- e.g. behaviorX did not specify anything special for update logic 
		
			var _type : String = ifaceCatagory ? ifaceCatagory.type : _DEFAULTKEY;	// e.g. scale,size,treasure (for onCollision), 				
			var k : Class = table[_type];				// find Class$ for this type of this catagory
			if( k ) {
				var handler : * = new k();					// create instance of handler for onCollision, update, collisionDetection etc
				var args : Object = classSpec.args ? classSpec.args[_type] : null; 		// args reqireed to init  e.g. how much to scale, etc
				handler.init(classSpec.name,args);
				return handler;			
			}			
			return null;						
		}
		
		
		private function getBehaviorSpec( s :String ) : Object {			
			return getSpecByName( s, _spec.behaviors );
		}
		
		private function getClassSpec( s : String ) : Object {			
			return getSpecByName( s, _spec.classes );	
		}
		
		private function getSpecByName( s : String, aSpec : Array ) :Object {

			for each ( var spec : Object in aSpec ) {
				if( s == spec.name ) {
					return spec;
				}				
			}			
			return null;			
		}
	}
	
}	
class SingletonEnforcer {}


///////////////////////////////////////////////////////////
import collision.CollisionDataProvider;
import collision.CollisionManager;
import collision.CollisionResult;

import flash.geom.Point;
import flash.geom.Rectangle;

import interfaces.ICollider;
import interfaces.ICollisionData;
import interfaces.ICollisionDetectionHandler;
import interfaces.IOnCollisionHandler;
import interfaces.IQuerryHandler;
import interfaces.IUpdateHandler;
import interfaces.IWorldObjectBehaviorOwner;

import sim.PlayerSim;

import util.Vector2;


interface IHandler {
	function init( type : String, args : Object ) : void ;
}

class QuerryHandler implements IQuerryHandler {
	
	private var _props : Array;
	
	public function QuerryHandler( properties : Array ) {
		_props = properties;  // ok for properties to be null
	}
	
	public function exec( toFind : String ) : Boolean {
		if( _props ) {
			return -1 != _props.indexOf( toFind );	
		}
		return false;
	}
}


class UpdateDefault implements IHandler, IUpdateHandler {
	public function init( type:String, args:Object ) : void {}
	public function exec(I:IWorldObjectBehaviorOwner) : void {}
}

class UpdateAI implements IHandler, IUpdateHandler  {
	
	private var _pattern : String;
	private var _speed : Number;
	private var _disp : Point = new Point();
	
	public function init(type:String, args:Object):void
	{
		_pattern = args.pattern;
		_speed = args.speed;		
	}
	
	public function exec(I:IWorldObjectBehaviorOwner):void
	{
		_disp.x = onScreen ? displacementX() : 0;
		I.offset( _disp );
	}
	
	// always walks left. TODO -- add more ai
	private function displacementX() : Number {
		return -_speed;
	}
	
	private function get onScreen() : Boolean {
		return true;
	}
	
}

/*
override public function update():void
{
pImpulse.x = computeImpulseX();
offset( pImpulse );
}

override public function setProps(props:Object):void
{
range = props.range;
homeX = props.homeX;
}

private function computeImpulseX() : Number {

if( ! isOnscreen() ) {
return 0;
}

var newX : Number =_bounds.left + dir * VELOCITY_X;

if( newX <= homeX - range ) {
dir = 1;
newX = homeX - range;
} 
else if ( newX >= homeX ) {
dir = -1;
newX = homeX;
}
return newX - _bounds.left;			

}
*/

class UpdateAnimatedPlatform implements IHandler, IUpdateHandler {
	
	private var _theta : Number = 0;
	private var _lastY : Number = 0;	
	private var _disp : Point = new Point();
	
	public function init(type:String, args:Object):void
	{
		// TODO Auto Generated method stub	
	}
	
	public function exec(I:IWorldObjectBehaviorOwner):void
	{
		_theta += Math.PI / 80;
		var thisY : Number = 150 * Math.sin(_theta);
		_disp.y = thisY - _lastY;
		_lastY = thisY;
		I.offset( _disp );
	}
}

class CollisionDetectionDefault implements IHandler, ICollisionDetectionHandler {
	
	private var _ICollisionData : ICollisionData = null;	
	private var _collisionResult : Vector2 = new Vector2();
	
	public function init( type : String, args : Object ) : void {
	
		_ICollisionData = CollisionDataProvider.instance.getCollisionData(type);

	}
	public function exec( iCol: ICollider, _bounds : Rectangle ) : Vector2 {
				
		var v : Vector2  = test_rXr( iCol.bounds, _bounds );	
		
		if( v ) {
			
			if( _ICollisionData ) {
				
				var vTestPoints : Vector.<Point> = iCol.collisionTestPoints;
				var count : int = vTestPoints.length
				
				for( var i : int = 0; i < count; ++i ) {
					var testPoint : Point = vTestPoints[i];
					var localPoint : Point = testPoint.subtract(_bounds.topLeft );
					return _ICollisionData.testPoint( localPoint );				
				}
			} 
		} 
		return v;
	}
	
	private function test_rXr( rA : Rectangle, rB : Rectangle) : Vector2 {
		
		var r : Rectangle = rA.intersection(rB);
		
		if( r.size.length ) {
			var y : Number = r.top -r.bottom;
			var x : Number = rB.left - r.right;  // same as: -(r.right-rB.left)			
			
			if( Math.abs(y) < Math.abs(x) ) {
				_collisionResult.setxy(0,y);
				return _collisionResult;
			}
			_collisionResult.setxy(x,0);
			return _collisionResult;
		}
		return null;		
	}	
}

class CollisionDetectionNever implements IHandler, ICollisionDetectionHandler {
	
	public function init( type: String, args: Object ) : void {
		
	}
	
	public function exec( I : ICollider, _bounds : Rectangle ) : Vector2 {
		return null;
	}
}


class OnCollisionDefault implements IHandler, IOnCollisionHandler {
	public function init( type: String, args : Object ) : void {}
	public function exec(  p : PlayerSim ) : void {}
}

class OnCollisionModifyVelocity implements IHandler, IOnCollisionHandler {
	
	private var _v : Point;
	
	public function init( type: String, args : Object ) : void {
		_v = new Point( args.x, args.y );
	}
	
	public function exec( p : PlayerSim ):void
	{
		p.applyImpulse( _v );
	}	
}

class OnCollisionModifyVelocityTimed implements IHandler, IOnCollisionHandler {
	
	private var _duration_ms : int;
	private var _scale : Number;
	
	public function init( type: String, args : Object ) : void {
		
		_duration_ms = args.ms; 
		_scale = args.s;
	}
	
	public function exec( p : PlayerSim ) : void {
		p.addSpeedBoost( _duration_ms, _scale );		
	}	
}


class OnCollisionTreasure implements IHandler, IOnCollisionHandler {
	
	private var _value : int;
	
	public function init( type: String,  args : Object ) : void  {
		_value = args.value;
	}
	
	public function exec(p:PlayerSim):void
	{
		p.addCoins( _value );
	}	
}

class OnCollisionModifySize implements IHandler, IOnCollisionHandler {
	private var _scale : Number;
	private var _duration_ms : Number;
	
	public function init( type:String,  args : Object ) : void { 
		_scale = args.s;
		_duration_ms = args.ms;
	}
	
	public function exec( p:PlayerSim ) : void {
		p.scale( _scale, _duration_ms );
	}
}