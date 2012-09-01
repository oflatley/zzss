package collision
{
	
	import events.CollisionEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import interfaces.IWorldObject;
	
	import sim.PlayerSim;
	
	import util.Vector2;

	
	public class CollisionManager  extends EventDispatcher
	{
		public function CollisionManager() {
		}

		public function update( player:PlayerSim, activeWorldObjects:Array ) : void  {

			// TODO broad culling of objects based on screen/world slice
			
			
			var playerBounds : Rectangle = player.bounds;
			var results:Array = new Array();	
			
			for each( var wo : IWorldObject in activeWorldObjects ) {
				
				var cr : CollisionResult = wo.testCollision( player ); 
				if( cr ) {
					results.push(cr);
				}
			}

			for each( cr in results ) {
				this.dispatchEvent( new CollisionEvent( CollisionEvent.PLAYERxWORLD, cr ) );
				cr.collidedObj.onCollision( player );			

			}
		}

		private static function center( r:Rectangle ) : Point {
			
			var x : Number = r.left + r.right;
			var y : Number = r.top + r.bottom;
			
			x /= 2;
			y /= 2;
			
			return new Point( x, y ) ;
		}
		
		private static function centerOfVerts( a : Vector.<Vector2> ) : Point { 
			var xTotal : Number = 0;
			var yTotal : Number = 0;
			
			for ( var i : int = 0; i < 4; ++i ) {
				xTotal += a[i].x;
				yTotal += a[i].y;
			}
			
			return new Point( xTotal/4, yTotal/4 );
		}

			private static function buildVertArray( r : Rectangle ) : Vector.<Vector2> {
				var verts:Vector.<Vector2> = new Vector.<Vector2>();
				
				var c:Point = center(r);
				
				verts.push( new Vector2( r.left - c.x, r.top - c.y ) );
				verts.push( new Vector2( r.right - c.x, r.top - c.y ) ) ;
				verts.push( new Vector2( r. right -c.x, r.bottom - c.y) );
				verts.push( new Vector2( r.left - c.x, r.bottom -c.y ) );
				return verts;
			}
			
			public static function SAT_vertsXverts( center1 :Point, verts1:Vector.<Vector2>, center2:Point, verts2 :Vector.<Vector2> ) : Vector2 {
				var test1:Number;// numbers to use to test for overlap
				var test2:Number;
				var testNum:Number; // number to test if its the new max/min
				var min1:Number; //current smallest(shape 1)
				var max1:Number;//current largest(shape 1)
				var min2:Number;//current smallest(shape 2)
				var max2:Number;//current largest(shape 2)
				var axis:Vector2;//the normal axis for projection
				var offset:Number;
				var vectorOffset:Vector2;
				var vectors1:Vector.<Vector2>;//the points
				var vectors2:Vector.<Vector2>;//the points
				vectors1 = verts1; //buildVertArray( polygon1 ); //.vertices.concat();//these functions are in my polygon class, all they do is return a Vector.<Vector2D> of the vertices of the polygon
				vectors2 = verts2; // buildVertArray (polygon2) ; //.vertices.concat();
				
				var msv : Vector2;
				var msvMagnitudeSquared : Number = Infinity;
				
				// find vertical offset				
				//var center1 : Point = center(polygon1);
				//var center2 : Point = center(polygon2) ;
				vectorOffset= new Vector2(center1.x - center2.x, center1.y - center2.y);
				
				// loop to begin projection
				for (var i:int = 0; i < vectors1.length; i++) {
					// get the normal axis, and begin projection
					axis = findNormalAxis(vectors1, i);
					
					// project polygon1
					min1 = axis.dot(vectors1[0]);
					max1 = min1;//set max and min equal
					
					for (var j:int = 1; j < vectors1.length; j++) {
						testNum = axis.dot(vectors1[j]);//project each point
						if (testNum < min1) min1 = testNum;//test for new smallest
						if (testNum > max1) max1 = testNum;//test for new largest
					}
					
					// project polygon2
					min2 = axis.dot(vectors2[0]);
					max2 = min2;//set 2's max and min
					
					for (j = 1; j < vectors2.length; j++) {
						testNum = axis.dot(vectors2[j]);//project the point
						if (testNum < min2) min2 = testNum;//test for new min
						if (testNum > max2) max2 = testNum;//test for new max
					}
					
					// apply the offset to each max/min(no need for each point, max and min are all that matter)
					offset = axis.dot(vectorOffset);//calculate offset
					min1 += offset;//apply offset
					max1 += offset;//apply offset
					
					// and test if they are touching
					test1 = min1 - max2;//test min1 and max2
					test2 = min2 - max1;//test min2 and max1
					if(test1 > 0 || test2 > 0){//if they are greater than 0, there is a gap
						return null;//just quit
					}
					
					var vThisSV : Vector2 = new Vector2(axis.x*((max2-min1)*-1) , axis.y*((max2-min1)*-1) );
					var vThisSVMagnitudeSquared : Number = vThisSV.magnitudeSquared();
					
					if( vThisSVMagnitudeSquared < msvMagnitudeSquared ){
						msvMagnitudeSquared = vThisSVMagnitudeSquared;
						msv = vThisSV;
					}					
				}
				
				//if you're here, there is a collision
				msv.negate();
				return msv;				
			}
			
			public static function SAT_rectXverts( rA : Rectangle, centerB : Point, vertsB : Array ) : Vector2 {
				var vertsA:Vector.<Vector2> = buildVertArray( rA ); 
				var centerA : Point = center(rA);
				
				// TODO: fix, should not do this copy to vector from array. fix callers to pass in vectors
				var _vertsB : Vector.<Vector2> = new Vector.<Vector2>();
				for each (var p:Vector2 in vertsB) 
				{
					_vertsB.push(p);	
				}
				return SAT_vertsXverts( centerA, vertsA, centerB, _vertsB );
			}

			public static function SAT_vertsXrect( centerB : Point, vertsB : Array, rA : Rectangle ) : Vector2 {
				var vertsA:Vector.<Vector2> = buildVertArray( rA ); 
				var centerA : Point = center(rA);
				
				// TODO: fix, should not do this copy to vector from array. fix callers to pass in vectors
				var _vertsB : Vector.<Vector2> = new Vector.<Vector2>();
				for each (var p:Vector2 in vertsB) 
				{
					_vertsB.push(p);	
				}
				return SAT_vertsXverts( centerA, vertsA, centerB, _vertsB );
			}
			
			
			
			public static function SAT_rectXrect( polygon1 : Rectangle, polygon2 : Rectangle ) : Vector2 {
				
				var r : Rectangle = polygon1.intersection(polygon2);
				
				if( r.size.length ) {
					var y : Number = r.top -r.bottom;
					var x : Number = polygon2.left - r.right;  // same as: -(r.right-polygon2.left)			
					
					if( Math.abs(y) < Math.abs(x) ) {
						return new Vector2( 0,y );
					}
					return new Vector2( x,0);
					
					//return new Vector2( x, y );
				}
				return new Vector2(0,0);
/*			
				var verts1:Vector.<Vector2> = buildVertArray( polygon1 ); //.vertices.concat();//these functions are in my polygon class, all they do is return a Vector.<Vector2D> of the vertices of the polygon
				var verts2:Vector.<Vector2> = buildVertArray (polygon2) ; //.vertices.concat();
				
				var center1 : Point = center(polygon1);
				var center2 : Point = center(polygon2) ;

				return SAT_vertsXverts( center1, verts1, center2, verts2 ); 	
*/				
			}	
			
			
			private static function findNormalAxis(vertices:Vector.<Vector2>, index:int):Vector2 {
				var vector1:Vector2 = vertices[index];
				var vector2:Vector2 = (index >= vertices.length - 1) ? vertices[0] : vertices[index + 1]; //make sure you get a real vertex, not one that is outside the length of the vector.

				var normalAxis:Vector2 = new Vector2( -(vector1.y - vector2.y), (vector1.x - vector2.x));//take the two vertices, make a line out of them, and find the normal of the line				
				normalAxis.normalize();//normalize the line(set its length to 1)
				return normalAxis;
			}
			
			////////////////////
			// Calculate the projection of a polygon on an axis
			// and returns it as a [min, max] interval
			//public static function ProjectPolygon( axis : Vector2, polygon : Rectangle, min : Number, max : Number) : void {
			public static function ProjectPolygon( axis : Vector2, verts : Vector.<Vector2>, min : Number, max : Number ) : void {
			// To project a point on an axis use the dot product
/*				
				var vert: Array = new Array(4);

				for( var i :int = 0; i < 4; ++i ) {
					vert[i] = new Vector2();
				}
				
				vert[0].setValueFromPoint( polygon.topLeft ) ;
				vert[1].setValue( polygon.right, polygon.top );
				vert[2].setValueFromPoint( polygon.bottomRight );
				vert[3].setValue( polygon.left, polygon.bottom );
*/				
			//	var vert : Array  = verts; 
				
				
				var dotProduct : Number = axis.dot(verts[0]);
				min = dotProduct;
				max = dotProduct;
				for ( var i : int = 0; i < 4; i++) {
					dotProduct = verts[i].dot(axis);
					if (dotProduct < min) {
						min = dotProduct;
					} else {
						if (dotProduct> max) {
							max = dotProduct;
						}
					}
				}
			}

			// Calculate the distance between [minA, maxA] and [minB, maxB]
			// The distance will be negative if the intervals overlap
			public static function IntervalDistance( minA : Number, maxA : Number, minB : Number, maxB : Number) : Number{
				if (minA < minB) {
					return minB - maxA;
				} else {
					return minA - maxB;
				}
			}
			
			private static function buildEdges( verts : Vector.<Vector2> ) : Array {
				
				var e : Array = new Array();
				
				for( var i : int = 0; i < 4; ++i ) {
					var vA : Vector2 = verts[i];
					var vB : Vector2 = verts[(i+1)%4];
					e.push( Vector2.subtract(vA,vB) );				
				}
				return e;
			}
			
			// Check if polygon A is going to collide with polygon B.
			// The last parameter is the *relative* velocity
			// of the polygons (i.e. velocityA - velocityB)
			//public static function PolygonCollision( polygonA : Rectangle, polygonB : Rectangle , velocity : Vector2) : CollisionResult {
			public static function SAT_vxv( ctrA : Point, vertA : Vector.<Vector2>, ctrB : Point, vertB : Vector.<Vector2>, velocity : Vector2 ) : CollisionResult {	
				
				var result : CollisionResult = new CollisionResult();
				result.Intersect = true;
				result.WillIntersect = true;
				
				var edgeCountA : int = 4; //polygonA.Edges.Count;
				var edgeCountB : int = 4; //polygonB.Edges.Count;
				var minIntervalDistance : Number = Infinity;
				var translationAxis : Vector2 = new Vector2();
				var edge : Vector2;
				
				var edgesA : Array = buildEdges(vertA);
				var edgesB : Array = buildEdges(vertB);
									
				// Loop through all the edges of both polygons
				for (var edgeIndex:int = 0; edgeIndex < edgeCountA + edgeCountB; edgeIndex++) {
					if (edgeIndex < edgeCountA) {
						edge = edgesA[edgeIndex];
					} else {
						edge = edgesB[edgeIndex - edgeCountA];
					}
					
					// ===== 1. Find if the polygons are currently intersecting =====
					
					// Find the axis perpendicular to the current edge
					var axis : Vector2 = new Vector2(-edge.y, edge.x);
					axis.normalize();
					
					// Find the projection of the polygon on the current axis
					var minA : Number = 0; var minB : Number = 0; var maxA : Number = 0; var maxB : Number = 0;
					ProjectPolygon(axis, vertA, minA, maxA); // ProjectPolygon(axis, polygonA, minA, maxA);
					ProjectPolygon(axis, vertB, minB, maxB); //ProjectPolygon(axis, polygonB, minB, maxB);
					
					// Check if the polygon projections are currentlty intersecting
					if (IntervalDistance(minA, maxA, minB, maxB) > 0) {
						result.Intersect = false;
					}	
					
					// ===== 2. Now find if the polygons *will* intersect =====
					
					// Project the velocity on the current axis
					var velocityProjection : Number = axis.dot(velocity);
					
					// Get the projection of polygon A during the movement
					if (velocityProjection < 0) {
						minA += velocityProjection;
					} else {
						maxA += velocityProjection;
					}
					
					// Do the same test as above for the new projection
					var intervalDistance : Number = IntervalDistance(minA, maxA, minB, maxB);
					if (intervalDistance > 0) result.WillIntersect = false;
					
					// If the polygons are not intersecting and won't intersect, exit the loop
					if (!result.Intersect && !result.WillIntersect) break;
					
					// Check if the current interval distance is the minimum one. If so store
					// the interval distance and the current distance.
					// This will be used to calculate the minimum translation vector
					intervalDistance = Math.abs(intervalDistance);
					if (intervalDistance < minIntervalDistance) {
						minIntervalDistance = intervalDistance;
						translationAxis = axis;
						
						//ß\var diff : Point = center(polygonA).subtract(center(polygonB));
						var diff : Point = centerOfVerts(vertA).subtract(centerOfVerts(vertB));
						var d : Vector2 = new Vector2( diff.x, diff.y );
						if (d.dot(translationAxis) < 0)
							translationAxis.negate();
					}
				}
				
				// The minimum translation vector
				// can be used to push the polygons appart.
				if (result.WillIntersect) {
					translationAxis.scale( minIntervalDistance );
					result.msv = translationAxis;
				}
				return result;
			}		
			
			public static function SAT_rxv( rA : Rectangle , vertB : Vector.<Vector2>, velocity : Vector2 ) : CollisionResult {	
	
					var ctrA : Point = center(rA);
					var vA : Vector.<Vector2> = buildVertArray( rA );
					var ctrB : Point = centerOfVerts( vertB );
					return SAT_vxv( ctrA, vA, ctrB, vertB, velocity ); 			
			}
			
			public static function SAT_rxr( rA : Rectangle , rB: Rectangle, velocity : Vector2 ) : CollisionResult {	
				var ctrA : Point = center(rA);
				var vA : Vector.<Vector2> = buildVertArray( rA );
				
				var ctrB : Point = center(rB);
				var vB : Vector.<Vector2> = buildVertArray( rB );
				
				return SAT_vxv( ctrA, vA, ctrB, vB, velocity ); 						
			}
	}
}


