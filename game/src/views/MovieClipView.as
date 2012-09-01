package views
{
	import collision.CollisionDataProvider;
	
	import events.WorldObjectEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import interfaces.ICollisionData;
	import interfaces.IWorldObject;
	
	import util.ObjectPool;
	import util.ScreenContainer;
	import util.Vector2;

	public class MovieClipView  {
		
		private var _mc : MovieClip;
		private var a : Array = new Array();
		private static const DEBUG_COLLISION_PRECISION: int = 3; // 1 is most accurate
		
		public function MovieClipView ( displayContainer: ScreenContainer, iWorldObj : IWorldObject, mc : MovieClip ) {
			_mc = mc;
			displayContainer.container.addChild( mc );
			iWorldObj.eventDispatcher.addEventListener( WorldObjectEvent.WORLDOBJECT_MOVE, onWorldObjMove );

/* DEBUG COLLISION DATA				
			var xx : int = Math.floor(_mc.width);
			var yy : int = Math.floor(_mc.height);			
			
			for( var y : int = 0 ; y < yy; y+=DEBUG_COLLISION_PRECISION )  { 
				for( var x : int = 0; x < xx; x+=DEBUG_COLLISION_PRECISION ) {
					var mc : MovieClip = ObjectPool.instance.getDebugBoundingBox();
					mc.width = DEBUG_COLLISION_PRECISION;
					mc.height = DEBUG_COLLISION_PRECISION;
					a[y*xx+x]=(mc);
					displayContainer.container.addChild(mc);
				}
			}
//*/			
		}

		public function set active( b : Boolean ) : void {
			_mc.visible = b;
		}
		
		private function onWorldObjMove( event : WorldObjectEvent ) : void {
			var iwo : IWorldObject = event.target as IWorldObject;
			var r : Rectangle = iwo.bounds;	
			_mc.x = r.x;
			_mc.y = r.y;

/* DEBUG COLLISION DATA			
			var icd : ICollisionData = CollisionDataProvider.instance.getCollisionData( "Platform_Arc_0" );
			var xx : int = Math.floor(_mc.width);
			var yy : int = Math.floor(_mc.height);
			
			for( var y : int = 0 ; y <  yy; y+=DEBUG_COLLISION_PRECISION )  { 
				for( var x : int = 0; x < xx; x+=DEBUG_COLLISION_PRECISION ) {
					
					var mc : MovieClip = a[y*xx+x];
					mc.x = _mc.x + x;
					mc.y = _mc.y + y;
					var v : Vector2 = icd.testxy( x,y );
					if( v.isNotZero ) {
						mc.visible = true; 
					}
					else {
						mc.visible = false;
					}
				}
			}
//*/		
		}	
		
		
	}

}