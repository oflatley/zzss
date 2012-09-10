package collision
{
	import events.CollisionEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	
	import interfaces.IWorldObject;
	
	import sim.PlayerSim;
	
	public class CollisionManager  extends EventDispatcher
	{
		public function CollisionManager() {
		}

		public function update( player:PlayerSim, activeWorldObjects:Array ) : void  {

			// TODO broad culling of objects based on radial check
			
			
			var playerBounds : Rectangle = player.bounds;
			var results:Array = new Array();	
			
			for each( var wo : IWorldObject in activeWorldObjects ) {
				
				var cr : CollisionResult = wo.testCollision( player ); 
				if( cr ) {
					results.push(cr);
				}
			}

			for each( cr in results ) {
				//var e : CollisionEvent = new CollisionEvent();
				//e.type = CollisionEvent.PLAYERxWORLD;
				//
				this.dispatchEvent( new CollisionEvent( CollisionEvent.PLAYERxWORLD, cr ) );
				cr.collidedObj.onCollision( player );			

			}
		}
	}
}


