package collision
{
	import events.CollisionEvent;	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import interfaces.IWorldObject;
	
	import sim.PlayerSim;
	
	public class CollisionManager  extends EventDispatcher
	{
		public function CollisionManager() {
		}

		private function distSq( pA : Point, pB : Point ) : Number {
			var xD : Number = pA.x - pB.x;
			var yD : Number = pA.y - pB.y;			
			return (xD * xD + yD * yD);
		}
		
		private function dist( pA : Point, pB : Point ) : Number {
			var xD : Number = pA.x - pB.x;
			var yD : Number = pA.y - pB.y;
			return Math.sqrt(xD * xD + yD * yD);
		}
		
		
		private function computeCircle( bounds : Rectangle ) : Object {

			var o : Object = new Object();
			
			var halfWidth : Number  = bounds.width / 2;
			var halfHeight : Number = bounds.height / 2;
			
			o.Ctr = new Point(bounds.left + halfWidth, bounds.top + halfHeight );		
			o.radius = Math.sqrt( halfWidth*halfWidth + halfHeight*halfHeight);
			o.radiusSq = ( halfWidth*halfWidth + halfHeight*halfHeight);
			
			return o;
		}
		
		private var _accumTimer :int = 0;
		public function update( player:PlayerSim, activeWorldObjects:Array ) : void  {

//			var t0 : int = getTimer();
//			{
			
			var playerBounds : Rectangle = player.bounds;
			var results:Array = new Array();	
			
			for each( var wo : IWorldObject in activeWorldObjects ) {
				
				// broad phase: radius check. 
				var pwoD : Number = dist( player.center, wo.center ) ;
				var thresh : Number = wo.radius + player.radius;
				
				if( pwoD < thresh ) {					
					var cr : CollisionResult = wo.testCollision( player ); 
					if( cr ) {
						results.push(cr);
					}					
				}
			}

			for each( cr in results ) {
				//var e : CollisionEvent = new CollisionEvent();
				//e.type = CollisionEvent.PLAYERxWORLD;
				//
				this.dispatchEvent( new CollisionEvent( CollisionEvent.PLAYERxWORLD, cr ) );
				cr.collidedObj.onCollision( player );			

			}
//			}
//			var t1 : int = getTimer();
//			_accumTimer += (t1 - t0 );
			
		}
	}
}


