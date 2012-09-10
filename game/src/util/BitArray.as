package util
{
	public class BitArray
	{
		private var _data : Array; 
		private var _nValid : uint;
		
		private static const MultiplyDeBruijnBitPosition : Array  = [
			0, 1, 28, 2, 29, 14, 24, 3, 30, 22, 20, 15, 25, 17, 4, 8, 
			31, 27, 13, 23, 21, 19, 16, 7, 26, 12, 18, 6, 11, 5, 10, 9
		];
		
			
		public function BitArray( elemCount : uint, data : Array = null ) {
			
			_nValid = elemCount;
			
			if( data ) {
				_data = data;
				
			//	for( var i : int = 0; i < data.length; ++i ) {
			//		data[i] = ~0;
			//	}
				
				//data[0] &= 0x0FFFFFF0;
			}
			else {
				var wordsNeeded : uint = elemCount >> 5;
				if( elemCount & 0x1F ) {
					wordsNeeded++;
				}				
				_data = new Array(wordsNeeded);
			}
		}
				
		private function fail(dx:uint) : Boolean {
			throw new Error( 'BitArray fail. index out of bounds:(dx,valid):('+dx+','+_nValid+')' );
			return false;
		}
	
		
		public function test( dx : uint ) : Boolean {
			if( dx < _nValid )
				return 0 != ( uint(_data[dx>>>5]) & (0x80000000 >>> (dx&31)) );
			return fail(dx);
		}
		
		public function setBit( dx : uint ) : void {
			if( dx < _nValid )
				_data[dx>>>5] |= 0x80000000 >>> (dx & 0x1F);
			else
				fail(dx);
		}
		
		public function unsetBit( dx : uint ) : void {
			if( dx < _nValid ) 
				_data[dx>>>5] &= ~(0x80000000 >>> (dx & 0x1F));
			else
				fail(dx);
		}
		
		private function inRange(dx:int) : Boolean { return dx >=0 && dx < _nValid; }
		
		public function findFirstWithStride( zeroOrOne : int, stride : int, startingIndex : uint = 0 ) : int {			
			return zeroOrOne ? _findFirstWithStride_1( stride, startingIndex ) : _findFirstWithStride_0( stride, startingIndex );
		}
		
		private function _findFirstWithStride_1( stride : int, startingIndex : uint )  : int {
			
			for( var n : int = startingIndex; inRange(n); n += stride ) {				
				if( test(n) ) {
					return n;
				}				
			}
			return -1;
		}
		
		private function _findFirstWithStride_0( stride : int, startingIndex : uint ) : int {
			
			for( var n : int = startingIndex; inRange(n); n += stride ) {
				
				if( !test(n) ) {
					return n;
				}				
			}
			return -1;	
		}

		
		
		public function findFirst( zeroOrOne : int, startingIndex : uint = 0) : int {
			var dx : uint = startingIndex >>> 5;
			var offset : uint = startingIndex & 0x1F;
			return zeroOrOne ? _findFirstAt_1( dx, offset ) : _findFirstAt_0(dx,offset);
		}
		
		private function _findFirstAt_1( dx : uint, offset : uint ) : int {
			var aLen : uint = _data.length;
			var mask : uint = ~0 >>> offset;
			
			for ( var i : uint = dx ; i < aLen; ++i ) {				
				
				var val : uint = _data[i] & mask;
				
				if( val ) {				
					var dx : uint = (i<<5) + getOffsetLeadingOne( val );
					return (dx < _nValid) ? dx : -1;	
				}
				mask = ~0;
			}
			return -1;								
		}
		
		private function _findFirstAt_0( dx : uint, offset : uint ) : int {
			var aLen : uint = _data.length;
			var mask : uint = ~0 >>> offset;
			
			for ( var i : uint = dx ; i < aLen; ++i ) {				
				
				var val : uint = (~_data[i]) & mask;
				
				if( val ) {				
					var dx : uint = (i<<5) + getOffsetLeadingOne( val );
					return (dx < _nValid) ? dx : -1;	
				}
				mask = ~0;
			}
			return -1;			
		}
		
		public function findLast( zeroOrOne : int, startingIndex : uint = 0xFFFFFFFF ) : int{
			
			if( startingIndex > _nValid ) {
				startingIndex = _nValid;
			}
			
			var dx : uint = startingIndex >>> 5;
			var offset : uint = startingIndex & 0x1F;
			return zeroOrOne ? _findLast_1( dx, offset ) : _findLast_0(dx,offset);
		}
		
						
		private function _findLast_1( dx : uint, offset : uint ) : int {
			
			var mask : uint = ~0 >>> (32-offset);	// ~0 >>> (32-offset)
			
			for ( var i : int = dx ; i >= 0; --i ) {				
				
				var val : uint = _data[i] & mask;
				
				if( val ) {				
					var dx : uint = (i<<5) + getOffsetTrailingOne( val );
					return dx;	
				}
				mask = ~0;
			}
			return -1;								
		}

		
		// returns 32 if v is all zeros		
		// (returns 0 if v is all ones)
		// -- returns 0 if lsb set, in general
		// returns 1 if 10b is the pattern of 2 lsb's, etc		
		private function __findZerosOnRight_parallel( v : uint ) : uint {
//var dbug : uint = v;	
			var c : uint = 32;
			var iv : int = int(v);
			iv = -iv;
			v &= iv;
			if (v) c--;
			if (v & 0x0000FFFF) c -= 16;
			if (v & 0x00FF00FF) c -= 8;
			if (v & 0x0F0F0F0F) c -= 4;
			if (v & 0x33333333) c -= 2;
			if (v & 0x55555555) c -= 1;
			
			
//			trace( 'para :: ' + dbug.toString(16) + ' ' + c  );
			return c;
		}

		
		private function __findZerosOnRight_binary( v : uint ) : int {
			var c : uint;     // c will be the number of zero bits on the right,
//var dbug : uint = v;

			if (v & 0x1) 
			{
				// special case for odd v (assumed to happen half of the time)
				//return 0;
				c = 0;
			}			
			else
			{
				if( v ) {
					
					c = 1;
					if ((v & 0xffff) == 0) 
					{  
						v >>= 16;  
						c += 16;
					}
					if ((v & 0xff) == 0) 
					{  
						v >>= 8;  
						c += 8;
					}
					if ((v & 0xf) == 0) 
					{  
						v >>= 4;
						c += 4;
					}
					if ((v & 0x3) == 0) 
					{  
						v >>= 2;
						c += 2;
					}
					c -= v & 0x1;
				}
				else {
					c = 32;
				}
			}	
			
//			trace( 'bin :: ' + dbug.toString(16) + ' ' + c  );
			
			return c;
		}
		
		
		private function _findLast_0( dx : uint, offset : uint ) : int {

			__findZerosOnRight_parallel( ~0 );
			__findZerosOnRight_binary( ~0 );							

			
			__findZerosOnRight_parallel( 0 );
			__findZerosOnRight_binary( 0 );							
			
			
			for( var k : uint = 0 ; k < 32; ++k ) {
				var v : uint = 1 << k;
				__findZerosOnRight_parallel( v );
				__findZerosOnRight_binary( v );							
			}
			
			
			
			var shf : uint = 31 - offset;		// shift down by the places we need to ignore (first time logic)
			var bitsProcessed : uint = 0;
		
			for ( var i : int = dx ; i >= 0; --i ) {				
				
		//		var d : uint = _data[i];
		//		var dprime : uint = d >> shf;		
		//		var dd : uint = ~dprime;
		
				// using >> intentionally, not >>>,, this way we roll 1's into high bits, critical to this alg (coz we are looking for trailing 0's)
				var flipped : uint = ~( _data[i] >> shf )	
				
				var consecRighthandZeros : uint = __findZerosOnRight_binary( flipped );
				if( consecRighthandZeros < 32 ) {
					// there were trailing 0's
					return consecRighthandZeros + bitsProcessed;
				} 
				// we found only 1's, keep going
				bitsProcessed += (32-shf);
				shf = 0;		// redundant, yes, but handles first case logic 
			}
			
			throw new Error( 'this can not be right, can it?' ); // todo
			return -1;								
		}

		
		
		
/*		
		private function _findLast_0( dx : uint, offset : uint ) : int {
			
			var disp : uint = 0;
			var bitsProcessed : uint  = offset+1;
			
			var foomask : uint = 0xFFFFFFFF >>> (offset+1);

			// for whatever reason, i can't happily shift down 32 bits. I'd expect a 32 bit value >>> 32 to be 0. But not the case.
			if( 32 == offset + 1 ) {
				foomask  = 0;
			}
			
			for ( var i : int = dx ; i >= 0; --i ) {				
				
				var d : uint = _data[i];
				var dprime : uint = d | foomask;
				var dd : uint = ~dprime;
				
				var foo : uint = __findZerosOnRight_parallel( dd );
				if( 32 != foo ) {
					return 31 - foo + disp;
				} 
				disp += bitsProcessed;
				bitsProcessed = 32				
				foomask = 0;
			}
			return -1;								
		}
*/											

		
		private function getOffsetLeadingOne( v : uint, shf : uint = 16 ) : uint {
			
			if( 1 == shf ) {
				
				// typical terminal case: if high bit is 1 return 0, else return 1
				if( v )
					return (~(v & 0x80000000)) >>> 31;
				
				// atypical: if v is 0, it is because v was zero from client call. thus, return -1
				// by return ~0-30 here, when recursion unrolls, -1 will be returned to client
				return ~0-30;
			}
			else {
				var sshf : uint = 32 - shf;
				var mask : uint = (~0 >>> sshf) << sshf;
				if( v & mask ) {
					// recurse on upper half of bits in question
					return getOffsetLeadingOne( v , shf >>> 1 );				
				}
				else {
					// recurse on lower half of bits in question
					return getOffsetLeadingOne( v << shf, shf >>> 1 ) + shf;
				}
			}
		}	
		
		
		private function getOffsetTrailingOne( v : uint, shf : uint = 16 ) : uint {
			
			if( 1 == shf ) {

				// typical terminal case: if low bit is 1 return 0, else return 1
				if( v )
					return (v & 1) ^ 1;
				
				// atypical: if v is 0, it is because v was zero from client call. thus, return -1
				// by return ~0-30 here, when recursion unrolls, -1 will be returned to client
				return ~0-30;
			}
			else {
				
				var sshf : uint = 32 - shf;
				var mask : uint = ~0 >>> sshf;
				if( v & mask ) {
					return getOffsetTrailingOne( v, shf >>> 1 );
				} else {
					return getOffsetTrailingOne( v >>> shf, shf >>> 1 ) + shf 
				}
				
			}
		}
		
	}
}


/*
private function findIndexFirstOne() : int {

var aLen : uint = _data.length;

for ( var i : uint = 0 ; i < aLen; ++i ) {				

var val : uint = _data[i];

if( val ) {				
var dx : uint = (i<<5) + getOffsetLeadingOne( val );
return (dx < _nValid) ? dx : -1;	
}
}
return -1;			
}

private function findIndexFirstZero() : int {

var aLen : uint = _data.length;

for ( var i : uint = 0 ; i < aLen; ++i ) {				

// note that we NOT the bits and then just look for the leading '1'
var val : uint = ~_data[i];

if( val ) {				
var dx : uint = (i<<5) + getOffsetLeadingOne( val );
return (dx < _nValid) ? dx : -1;	
}
}
return -1;			
}
*/
/*			
var db : uint = __findZerosOnRight_parallel(0);
db = __findZerosOnRight_parallel( ~0 );

db = __findZerosOnRight_parallel( 15 );
db = __findZerosOnRight_parallel( 14 );
db = __findZerosOnRight_parallel( 8 );
db = __findZerosOnRight_parallel( 0 );

for( var ss : int = 0 ; ss < 33; ++ss ) {
db = __findZerosOnRight_parallel( 1<<ss );				
}
*/	
/*
//			var shf : uint  = offset + 1;



//			if( shf == 32 ) {
//				trace('fasdfasdfas');
//			}

var mask : uint = ~0 << (31-offset);
var foomask : uint = (31 == offset) ? 0 : (~0xFFFFFFFF >>> (offset+1));

for ( var i : int = dx ; i >= 0; --i ) {				
	
	var d : uint = _data[i];
	var dprime : uint = d | foomask;
	
	var dd : uint = ~dprime;
	
	var foo : uint = __findZerosOnRight_parallel( dd );
	//foo = 31 - foo;
	if( 32 != foo ) {
		return 31 - foo;
	}
	
	
	
	var test : uint = ~_data[i];
	var val : uint = test & mask; //(~_data[i]) & mask;
	
	if( val ) {				
		var dx : uint = 31 - getOffsetTrailingOne( val );
		
		if( foo != dx ) {
			
			throw new Error('jack');
		}
		
		dx += (i<<5);
		return dx;
	}
	mask = ~0;
	//				shf = 0;
	foomask = 0;
}
return -1;								
}

*/
