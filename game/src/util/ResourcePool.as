package util {
	import avmplus.getQualifiedClassName;
	import util.BitArray;
	
	public class ResourcePool {
		
		private var _pool : Array;
		private var _locks : BitArray;
		
		public function ResourcePool( klass : Class, count : uint ) {
			
			_locks = new BitArray(count);
			_pool = new Array(count);
			
			for( var i : int = 0; i < count; ++i ) {
				_pool[i] = new klass();
			}		
		}
		
		public function lock() : * {
			
			// get index of first free resource in the pool. 0's in the bit array correspond to free resources in _pool
			var dx : int = _locks.findFirst(0);
			
			if( dx >= 0 ) {
				
				// DEBUG:
				if( _locks.test(dx) ) {
					throw new Error('already locked, findIndexFirstZero broken: ' + id );
				}
				
				// update the bit array to record that this pool resource is allocated 
				_locks.setBit(dx);
				
				if( ! _locks.test(dx) ) {
					throw new Error('foobar');
				}
				
				return _pool[dx];
			}
			
			throw new Error( 'Exhausted alloc pool for: ' + id ); 
		}
		
		public function release(rc:*) : void {
			
			var dx : int = find(rc);
			
			if( dx >= 0 ) {
				
				// DEBUG:
				if( false == _locks.test(dx) ) {
					throw new Error( 'already released' + getQualifiedClassName(rc) );
				}
				
				// update the bit array to record that this pool resource had been freed
				_locks.unsetBit(dx);
				
				if( _locks.test(dx) ) {  // DEBUG
					throw new Error( 'barfoo' );
				}	
			}
			else {			
				throw new Error( "could not release from Allocator: " + getQualifiedClassName(rc) );	
			}
			
			
		}
		
		private function find( rc:* ) : int {
			var len : uint = _pool.length;
			for( var i : int = 0; i < len; ++i ) {
				if( rc == _pool[i] ) {
					return i;
				}
			}
			return -1;
		}
		
		private function get id() : String {
			return getQualifiedClassName( _pool[0] );
		}
		
	}	
}