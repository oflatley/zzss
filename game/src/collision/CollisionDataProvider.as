package collision
{

	import events.CollisionDataProviderEvent;
	
	import flash.events.EventDispatcher;
	
	import interfaces.ICollisionData;

	public class CollisionDataProvider extends EventDispatcher { 
	
		private static var _theInstance : CollisionDataProvider = null;
		private var _map:Array;		// associate [type name] <--> CollisionData  e.g.  ['platform_arc'] = new CollisionData(w,h,bitData);
		
		public function getCollisionData( s : String ) : ICollisionData 
		{ 
			return _map[s];
		}

		public function CollisionDataProvider( se:SingletonEnforcer ) {
			_map = new Array();
		}
		
		public function buildCollisionData( url : String) : void {			
			var dfp : DatFileParser = new DatFileParser();
			dfp.parse( url, _map );
			dfp.addEventListener( CollisionDataProviderEvent.INITIALIZED, onLoaded );
		}
		
		public static function get instance() : CollisionDataProvider {
			if( null == _theInstance ) {
				_theInstance = new CollisionDataProvider( new SingletonEnforcer() );
			}
			return _theInstance;
		}
		
		protected function onLoaded(event:CollisionDataProviderEvent):void {
			dispatchEvent(event);
		}
		
	}
}

class SingletonEnforcer {}

import collision.CollisionData;

import events.CollisionDataProviderEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;


class DatFileParser extends EventDispatcher{

	private var _map : Array;
	
	public function parse( sURL : String, map : Array ) : void {

		_map = map;
		var urlLoader : URLLoader = new URLLoader() ;
		var urlReq : URLRequest = new URLRequest( sURL );
		urlLoader.load(urlReq);
		urlLoader.addEventListener( Event.COMPLETE, onDataLoaded );		
	}
	
	protected function onDataLoaded(event:Event):void
	{	
		var xml : String = event.target.data as String;
		var json : Object = JSON.parse( xml );
		
		var aWO : Array = json.worldObjects;
		for each( var wo : * in aWO ) {
			var w : int = wo.dims.w;
			var h : int = wo.dims.h;
			var s : String = wo.name;
			var bv : Array = wo.collisionBits;
			
			_map[s] = new CollisionData( w, h, bv );
		}
		dispatchEvent( new CollisionDataProviderEvent(CollisionDataProviderEvent.INITIALIZED) );		

	}	
}