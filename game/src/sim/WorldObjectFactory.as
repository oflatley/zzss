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
		public static const Q_NO_COLLISION_REACTION : String = 'NoCollisionReaction';
		public static const Q_INVISIBLE : String ='Invisible';
				
		private static var theWorldObjectFactory : WorldObjectFactory = null;		

		private var _onUpdateHandlers : Array = new Array();
		private var _onCollisionHandlers : Array = new Array();
		private var _collisionDetectionHandlers : Array = new Array();
		private static var _DEFAULTKEY : String = '_DEFAULT_';		
		
		private var _spec : Object;
		
		public static function get instance() : WorldObjectFactory {
			if( null == theWorldObjectFactory ) {
				theWorldObjectFactory = new WorldObjectFactory() ; //new SingletonEnforcer());
			}
			return theWorldObjectFactory;
		}
		
		public function init( spec : Object ) : void {			
			_spec = spec;
			_spec.classes.push({name:_DEFAULTKEY,behavior:_DEFAULTKEY});
			_spec.behaviors.push({name:_DEFAULTKEY});
		}	
		
		public function WorldObjectFactory( ) {//makeThisConstructorUnusable : SingletonEnforcer ) {
		
			_onCollisionHandlers[_DEFAULTKEY] = OnCollisionDefault;
			_onCollisionHandlers['modVel'] = OnCollisionModifyVelocity;
			_onCollisionHandlers['modVelTimed'] = OnCollisionModifyVelocityTimed;
			_onCollisionHandlers['tc'] = OnCollisionTreasure;
			_onCollisionHandlers['modSize'] = OnCollisionModifySize;
			_onCollisionHandlers['eventDispatcher'] = OnCollisionEventDispatcher;
			
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
				//trace('could not find class spec for ' + type + '. Using default' );
				c = getClassSpec( _DEFAULTKEY );
			}
			
			var b : Object = getBehaviorSpec( c.behavior ); 
			
			if (!b) {
				throw new Error( 'Could not find behavior spec for ' + type + ' | ' + c.behavior );
			}
			
			return _buildBehavior( type, c, b );
		}
		
		private function _buildBehavior( type:String, classSpec : Object, behaviorSpec : Object ) : WorldObjectBehavior {
			
			
			var IUp : IUpdateHandler = __build( type, classSpec, _onUpdateHandlers, behaviorSpec.update ) as IUpdateHandler;
			var IOnC : IOnCollisionHandler = __build( type, classSpec, _onCollisionHandlers, behaviorSpec.onCollision ) as IOnCollisionHandler;
			var ICD : ICollisionDetectionHandler =  __build( type, classSpec, _collisionDetectionHandlers, behaviorSpec.collisionDetection ) as ICollisionDetectionHandler;
			var IQ : IQuerryHandler = new QuerryHandler( behaviorSpec.properties ) ;
			
			return new WorldObjectBehavior( IUp, IOnC, ICD , IQ );
		}

		private function __build( type: String, classSpec : Object , table : Array,  ifaceCatagory : Object )  : Object{
			
			// ifaceCatagory is the key to the correct set of handlers  e.g. onCollision[], update[], collisionDetection[], etc
			// _type is a particular handler within the specified set.. we use 'default' if behavior did not specify override behavior for the catagory
			// -- e.g. behaviorX did not specify anything special for update logic 
		
			var _type : String = ifaceCatagory ? ifaceCatagory.type : _DEFAULTKEY;	// e.g. scale,size,treasure (for onCollision), 				
			var k : Class = table[_type];				// find Class$ for this type of this catagory
			if( k ) {
				var handler : * = new k();					// create instance of handler for onCollision, update, collisionDetection etc
				var args : Object = classSpec.args ? classSpec.args[_type] : null; 		// args reqireed to init  e.g. how much to scale, etc
				handler.init(args,type,classSpec.name);
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

import events.RemoveFromWorldEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.getClassByAlias;
import flash.utils.getDefinitionByName;

import interfaces.ICollider;
import interfaces.ICollisionData;
import interfaces.ICollisionDetectionHandler;
import interfaces.IOnCollisionHandler;
import interfaces.IQuerryHandler;
import interfaces.IUpdateHandler;
import interfaces.IWorldObjectBehaviorOwner;

import sim.PlayerSim;

import util.Vector2;



class BehaviorHandlerBase {
	public function BehaviorHandlerBase() { };		// delete this and you will crash. as3 feature
	public function init( args: Object, type : String, classSpecName : String ) : void {}
//	public function registerEvent( classFilter : Class, type : String, listener : Function ) : void {}
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


class UpdateDefault extends BehaviorHandlerBase implements IUpdateHandler {
	public function UpdateDefault() { }
//	public function init( args: Object, type : String, classSpecName : String ) : void {}
	public function exec(I:IWorldObjectBehaviorOwner) : void {}
}

class UpdateAI  extends BehaviorHandlerBase implements IUpdateHandler  {
	
	private var _pattern : String;
	private var _speed : Number;
	private var _disp : Point = new Point();
	
	public function UpdateAI() {}

	override public function init( args: Object, type : String, classSpecName : String ) : void 
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


class UpdateAnimatedPlatform  extends BehaviorHandlerBase implements IUpdateHandler {
	
	private var _theta : Number = 0;
	private var _lastY : Number = 0;	
	private var _disp : Point = new Point();
	
	//public function init( args: Object, type : String, classSpecName : String ) : void {}
	
	public function UpdateAnimatedPlatform() {}
	
	public function exec(I:IWorldObjectBehaviorOwner):void
	{
		_theta += Math.PI / 80;
		var thisY : Number = 150 * Math.sin(_theta);
		_disp.y = thisY - _lastY;
		_lastY = thisY;
		I.offset( _disp );
	}
}

class CollisionDetectionDefault  extends BehaviorHandlerBase implements ICollisionDetectionHandler {
	
	private var _ICollisionData : ICollisionData = null;	
	private var _collisionResult : Vector2 = new Vector2();
	
	public function CollisionDetectionDefault() {}
	
	override public function init( args: Object, type : String, classSpecName : String ) : void {
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

class CollisionDetectionNever  extends BehaviorHandlerBase implements ICollisionDetectionHandler {
	
	//public function init( args: Object, type : String, classSpecName : String ) : void {}
	public function CollisionDetectionNever() {}
	public function exec( I : ICollider, _bounds : Rectangle ) : Vector2 {
		return null;
	}
}


class OnCollisionDefault extends BehaviorHandlerBase implements IOnCollisionHandler  {
	//public function init( args: Object, type : String, classSpecName : String ) : void {}
	public function OnCollisionDefault() {}
	public function exec(  p : PlayerSim ) : void {}
	public function registerEvent( classFilter : Class, type : String, listener : Function ) : void {}
	public function get eventDispatcher() : EventDispatcher { return null; }

}

class OnCollisionModifyVelocity extends BehaviorHandlerBase implements IOnCollisionHandler {
	
	private var _v : Point;
	
	public function OnCollisionModifyVelocity( ){}
	
	override public function init( args: Object, type : String, classSpecName : String ) : void {
		_v = new Point( args.x, args.y );
	}
	
	public function exec( p : PlayerSim ):void
	{
		p.applyImpulse( _v );
	}
	
	public function registerEvent( classFilter : Class, type : String, listener : Function ) : void {}	
	public function get eventDispatcher() : EventDispatcher { return null; }

}

class OnCollisionModifyVelocityTimed extends BehaviorHandlerBase implements IOnCollisionHandler {
	
	private var _duration_ms : int;
	private var _scale : Number;
	
	public function OnCollisionModifyVelocityTimed(){}
	
	override public function init( args: Object, type : String, classSpecName : String ) : void {
		
		_duration_ms = args.ms; 
		_scale = args.s;
	}
	
	public function exec( p : PlayerSim ) : void {
		p.addSpeedBoost( _duration_ms, _scale );		
	}	
	public function registerEvent( classFilter : Class, type : String, listener : Function ) : void {}
	public function get eventDispatcher() : EventDispatcher { return null; }

}


class OnCollisionTreasure extends BehaviorHandlerBase implements IOnCollisionHandler {
	
	private var _value : int;
	
	public function OnCollisionTreasure(){}
	
	override public function init( args: Object, type : String, classSpecName : String ) : void {
		_value = args.value;
	}
	
	public function exec(p:PlayerSim):void
	{
		p.addCoins( _value );
	}
	public function registerEvent( classFilter : Class, type : String, listener : Function ) : void {}
	public function get eventDispatcher() : EventDispatcher { return null; }

}

class OnCollisionModifySize extends BehaviorHandlerBase implements IOnCollisionHandler {
	private var _scale : Number;
	private var _duration_ms : Number;
	
	public function OnCollisionModifySize() {}
	override public function init( args: Object, type : String, classSpecName : String ) : void {
		_scale = args.s;
		_duration_ms = args.ms;
	}
	
	public function exec( p:PlayerSim ) : void {
		p.scale( _scale, _duration_ms );
	}
	public function registerEvent( classFilter : Class, type : String, listener : Function ) : void {}
	public function get eventDispatcher() : EventDispatcher { return null; }

}

class OnCollisionEventDispatcher extends EventDispatcher implements IOnCollisionHandler {

	private var _klass : Class;
	private var _type : String;
	
	public function OnCollisionEventDispatcher() {}
	
	public function init(args:Object, type:String, classSpecName:String) : void {
		var s : String = args.klass;
		_klass  = getDefinitionByName( 'events::' + s ) as Class;
		_type = args.subType;
	}
	
	public function exec(p:PlayerSim):void
	{
		if( this.hasEventListener( _type ) ) {
			var instance : Event = new _klass( _type ) as Event;
			dispatchEvent( instance );
		}
	}
	
	public function registerEvent( classFilter : Class, type : String, listener : Function ) : void {
		
		if( _type == type ) {
			if( classFilter == _klass ) {
				
				eventDispatcher.addEventListener( type, listener );
			}
		}
		
	}
	public function get eventDispatcher() : EventDispatcher { return this; }

}


