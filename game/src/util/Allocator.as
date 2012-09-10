package util
{
	import avmplus.getQualifiedClassName;	
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	public class Allocator
	{
		private static var _theThe : Allocator = null;			
		private var _map: Array;
			
		public static function get instance() : Allocator {
			if( !_theThe ) {
				_theThe = new Allocator( new SingletonEnforcer() );
			}
			return _theThe;
		}
		
		public function Allocator( _ :SingletonEnforcer ) {		
		}
		
		public function initialize( spec : Array ) : void {
			_map = new Array();
			
			for each ( var elem : Object in spec ) {
				var s : String = getQualifiedClassName( elem.k ); 
				_map[s] = new ResourcePool( elem.k, elem.n );
			}			
		}
		
		public function alloc( type : Class ) : * {
			var s : String = getQualifiedClassName(type);
			return _map[s].lock();
		}
		
		public function free( rc : * ) : void {
			var s : String = getQualifiedClassName( rc );
			_map[s].release(rc);			
		}		
	}
}

class SingletonEnforcer{}

