package util
{
	import events.CollisionEvent;
	import events.ObjectPoolEvent;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	
	import interfaces.IWorldObject;
	
	import sim.PlayerSim;
	import sim.WorldObjectFactory;
	
	import views.MovieClipView;

	public class ObjectPool extends EventDispatcher
	{
		private static var theObjectPool : ObjectPool = null;	
		private var poolMap : Array;
		private var activeList : Array;
		private var _mcMapping_swf : Array = new Array();			// for swf based assets
		private var _playerMC_hackForSwf : MovieClip;
		private var _boundBoxKlass:Object;
		private var _objectInfo : Array = new Array();
		
		public static function get instance() : ObjectPool {
			if( null == theObjectPool ) {
				theObjectPool = new ObjectPool(new SingletonEnforcer());
			}
			return theObjectPool;
		}
		
		public function ObjectPool(_:SingletonEnforcer) {
			super();
			poolMap = new Array();
			activeList = new Array();
		}
					
		public function get playerMC() : MovieClip {
			return _playerMC_hackForSwf;
		}
		
		public function initialize(spec:Array, screenContainer : ScreenContainer ) : void {		
			
			for each( var elem : Object in spec ) {
				
				var a : Array = new Array();
				poolMap[elem.type] = a;
				
				
				for( var i : int = 0; i < elem.count; ++i ) {
					
					var mc : MovieClip = createMC_swf( elem.type );
					var iWO : IWorldObject = WorldObjectFactory.instance.createWorldObject( elem.type, new Rectangle( 0,0,mc.width, mc.height ) );
					var mcv : MovieClipView = new MovieClipView( screenContainer, iWO, mc );
					mcv.active = false;
					a.push( new PoolObject(iWO, mcv ) );
				}
			}
			
		}
		
		public function Clean() : void {
			poolMap.slice( 0, poolMap.length );
		}
		
		public function GetObj( type:String ) : IWorldObject {

			var a : Array = poolMap[type];
			
  			if( a.length ) {
				var po : PoolObject = a.pop();
				
				activeList.push( po );
				po.movieClipView.active = true;
				return po.iWorldObj; 
			}

			throw new Error( "@@@@@ COULD NOT ALLOC TYPE:" + type + "FROM OBJECT POOL @@@@@" );
			return null;
		}
		
		public function RecycleObj( wo : IWorldObject ) : void {

			for( var i : int = 0; i < activeList.length; ++i ) {
				if( wo == activeList[i].iWorldObj ) {
					break;
				}
			}
			
			if( i < activeList.length ) {
				var po : PoolObject = activeList.splice( i, 1 )[0] as PoolObject;
				po.movieClipView.active = false;
				poolMap[wo.id].push( po );
			} else {
				trace('ERROR -- could not recycleObj in ObjectPool ');
			}
		}

		public function getProp( type:String, name:String ) : Object {
			var woInfo : Object = _objectInfo[type];
			return woInfo[name];
		}

		public function debug( ) : void {
			var s : String = new String();
			
			for( var it : String in poolMap ) {
				var a : Array = poolMap[it];
				s += it + ':' + a.length + ', ';	
			}
			trace(s);
		}

		// swf loading support
		public function buildMovieClipClasses( swfFile : String )  : void {
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onSwfLoadComplete );
			var req : URLRequest = new URLRequest(swfFile);
			loader.load( req );
		}
		
		//swf loading support
		private function onSwfLoadComplete(event:Event):void
		{
			var aNames : Array = ["Player","Platform_Arc_0","Catapult","Trampoline","Launcher","Token_MakePlayerBigger","Token_MakePlayerSmaller", "SpringBoard","Brain","SpeedBoostCoin","Enemy_0","Column","PlatformShort_0","PlatformMedium_0","PlatformLong_0","StartSign","FinishSign","PlatformMedium_15","PlatformMedium_345"];
					
			event.target.removeEventListener( Event.COMPLETE, arguments.callee );
			var ad:ApplicationDomain = event.target.applicationDomain;
			
			for each( var s : String in aNames ) {
				var Klass : Object = ad.getDefinition( s );
				_mcMapping_swf[s] = Klass;			
			}
			_mcMapping_swf["PlatformShort_elev"] = _mcMapping_swf['PlatformShort_0'];
			_playerMC_hackForSwf = createMC_swf("Player");
			
			_boundBoxKlass = ad.getDefinition( "BoundingBox" ) as Class;
			dispatchEvent( new ObjectPoolEvent( ObjectPoolEvent.INITIALIZED ) );				
		}

		public function	loadObjectInfo( sURL : String) : void {
			var urlLoader : URLLoader = new URLLoader() ;
			var urlReq : URLRequest = new URLRequest( sURL );
			urlLoader.load(urlReq);
			urlLoader.addEventListener( Event.COMPLETE, onObjInfoLoaded );		
			
		}
		
		protected function onObjInfoLoaded(event:Event):void
		{
			event.target.removeEventListener( Event.COMPLETE, arguments.callee );
			var json : Object = JSON.parse( event.target.data );
			var objInfo : Array = json.objectInfo;
			
			for each( var oi:Object in objInfo ) {				
				_objectInfo[oi.type] = oi.info;
			}

			dispatchEvent( new ObjectPoolEvent( ObjectPoolEvent.INITIALIZED ) );				
		}		
		
		
		
		private function createMC_swf( type:String ) : MovieClip {
			var klass : Class = _mcMapping_swf[type];
			return new klass();
		}
		
		
		public function getDebugBoundingBox() : MovieClip {

			return new _boundBoxKlass() as MovieClip;
		}
		

	}
}
import flash.display.MovieClip;

import interfaces.IWorldObject;

import views.*;

class SingletonEnforcer {}

class PoolObject {
	
	private var _iWO : IWorldObject;
	private var _mcv : MovieClipView;
	
	public function PoolObject( iWO : IWorldObject, mcv : MovieClipView ) {
		_iWO = iWO;
		_mcv = mcv;
	}
	
	public function get iWorldObj() : IWorldObject { return _iWO; }
	public function get movieClipView() : MovieClipView { return _mcv; }
		
		
}



