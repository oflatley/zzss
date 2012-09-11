package level
{
	import collision.CollisionManager;
	import collision.CollisionResult;
	
	import events.CollisionEvent;
	import events.LevelEvent;
	import events.RemoveFromWorldEvent;
	import events.ScreenContainerEvent;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	import interfaces.IOnCollisionHandler;
	import interfaces.IWorldObject;
	
	import level.LevelFactory;
	
	import sim.PlayerSim;
	import sim.WorldObjectFactory;
	
	import util.ObjectPool;
	import util.ScreenContainer;
	
	public class Level
	{
		private static const nBucketsOffscreenOnRight : int = 1;
		private static const bucketSlices : int = 8;
		private static const bucketWidth : int = 960 / bucketSlices ;
		private var buckets_startX:Array;
		private var buckets_endX:Array;
		private var nLeftmostBucketX : int;
		private var _activeObjects:Array;
		private var collisionsToProcess : Array; 
		private var _scrollSignaled : Boolean;
		private var _ndxCurrentScreenSlice : int;
		private var _objectsToRemove : Array;
		
		public function Level( data : Array, _collisionMgr : CollisionManager, playerSim : PlayerSim )	
		{			
			_scrollSignaled = false;
			
			
			_collisionMgr.addEventListener( CollisionEvent.PLAYERxWORLD, onPlayerxWorldCollision );
			ScreenContainer.instance.addEventListener( ScreenContainerEvent.SLICE_SCROLL, onSliceScroll );
			playerSim.addEventListener( RemoveFromWorldEvent.REMOVE_FROM_WORLD, onRemoveFromWorld );
						
			ScreenContainer.instance.SetSliceCount(bucketSlices);	
			collisionsToProcess = new Array();	
			var typeWidths : Array = new Array();
			
			_activeObjects = new Array();
			buckets_startX = new Array();
			buckets_endX = new Array();
			_objectsToRemove = new Array();
			
			// find max x
			var maxX : int = 0;
			var maxX0 : int = 0;

			for each( var elem:Object in data ) {
				
				if( null == typeWidths[elem.type] ) {
					typeWidths[elem.type] = ObjectPool.instance.getProp( elem.type, "w" ) as Number;
				}
								
				var width : Number = typeWidths[elem.type];
				var thisMaxX : int = elem.x; 
				maxX = Math.max( maxX, thisMaxX );
				
	 			var thisMaxX0 : int = thisMaxX + width + 0.5; 
				maxX0 = Math.max( maxX0, thisMaxX0 );

				//trace(thisMaxX + ' ' + maxX + ' ---- ' + thisMaxX0 + ' ' + maxX0 );			
			}
			
			var nBuckets : int = maxX / bucketWidth;
			
			for( var n : int = 0; n <= nBuckets; ++n ) {
				buckets_startX.push( new Array() );
			}
			
			var nBucketsEnd : int = maxX0 / bucketWidth;
			
			for( n = 0; n <= nBucketsEnd; ++n ) {
				buckets_endX.push( new Array() );
			}
			
			for each ( var elem2:Object in data ) {			
				var info : ObjBucketInfo = new ObjBucketInfo( elem2.type, elem2.x, elem2.y, elem2.x + typeWidths[elem2.type], elem2.props );			
				var nWhichBucket : int = elem2.x / bucketWidth;
				buckets_startX[nWhichBucket].push( info );				
			}	
						
			nLeftmostBucketX = 0;			

			for( var n1 : int = 0; n1 < bucketSlices + nBucketsOffscreenOnRight; ++n1  ) {
				addToActiveObjects( buckets_startX[n1] ) ;
			}
			
			ObjectPool.instance.registerEventHandler( LevelEvent, LevelEvent.START,  onLevelStart );
			ObjectPool.instance.registerEventHandler( LevelEvent, LevelEvent.FINISH, onLevelFinish );

			
		}
		
		protected function onRemoveFromWorld(event:RemoveFromWorldEvent):void
		{
			_objectsToRemove.push( event.objToRemove );
		}
		
		protected function onLevelStart( event:LevelEvent ) : void {
			event.target.removeEventListener( LevelEvent.START, arguments.callee );
			trace('LEVEL STARTING');
		}

		protected function onLevelFinish( event:LevelEvent ) : void {
			event.target.removeEventListener( LevelEvent.FINISH, arguments.callee );
			trace('LEVEL FINISHED!!');
		}
		
		
		private function onSliceScroll( event : ScreenContainerEvent ) : void {

			_scrollSignaled = true;
			_ndxCurrentScreenSlice = event.ndxSlice;
		}
		
		private function onPlayerxWorldCollision( event : CollisionEvent ) : void {
 			collisionsToProcess.push( event.collisionResult );
		}
		
		private function addToActiveObjects( a : Array ) : void {

			for each ( var info : ObjBucketInfo in a ) {
				
				// get world object from object pool and initialize
				var wo : IWorldObject = ObjectPool.instance.GetObj( info.type );
				wo.position = new Point( info.x0, info.y );
				
			//	if( info.props ) {
			//		wo.setProps( info.props );
			//	}
				
				// add to the active object list --> e.g. now there will be updates and collision detection for wo
				activeObjects.push( wo );
				
				// store when they should be removed from level
				var x0 : int = Math.floor(wo.bounds.right); 
				var a : Array = buckets_endX[Math.floor(x0/bucketWidth)];
				a.push(wo);
			}
		}
		
		private function removeFromActiveObjects( wo : IWorldObject ) : Boolean  {
			for( var i : int = 0; i < activeObjects.length; ++i ) {
				if( wo == activeObjects[i] ) {
					break;
				}
			}
			
			if( i < activeObjects.length ) {
				activeObjects.splice(i, 1);
				return true;
			}
			trace("unexpected: object not removed from Level");
			return false;
		}
		
		private function removeObject( woToRemove:IWorldObject ) : void {

			removeFromActiveObjects( woToRemove );	
			ObjectPool.instance
				.RecycleObj( woToRemove );
			
			// do not bother removing from buckets_endX --> do that between levels			
 		}
		
		
		public function update( playerPosition : Point ) : void {

			var ar : Array;
			
			for each (var woToRemove :IWorldObject  in _objectsToRemove) 
			{
				removeObject( woToRemove );	
			}
			_objectsToRemove.length = 0;
			
			for each( var cr : CollisionResult in collisionsToProcess ) {
				if( cr.collidedObj.querry( WorldObjectFactory.Q_CONSUMABLE ) ) {
					removeObject( cr.collidedObj );
					var ndx : int = cr.collidedObj.bounds.right / bucketWidth;
					ar = buckets_endX[ndx];
					for( var i : int = 0 ; i < ar.length; ++i ) {
						if( cr.collidedObj == ar[i] ) {
							break;
						}	
					}
					if( i < ar.length ) {
						ar.splice( i , 1 );
					}
					else {
						trace("could not remove consumble object from buckets_endX");
					}							
				}
			}			
			collisionsToProcess.length = 0;
					
			if( _scrollSignaled ) {
				_scrollSignaled = false;
				//trace( "signaled: " + playerPosition.x + ' ' + _ndxCurrentScreenSlice  );
				
				// remove objects that have now gone offscreen to the left
				ar = buckets_endX[_ndxCurrentScreenSlice-1];
				for each( var wo : IWorldObject in ar ) {	
					
					//trace( ' -- Removing:' + wo.GetBounds().left + ' ' + wo.GetBounds().right ); 
					
					removeObject(wo);					
					if( wo.bounds.left > playerPosition.x ) {
						trace("asdgasdgasd");
					}
				}		
				
				// add new objects just offscreen to the right
				addToActiveObjects( buckets_startX[_ndxCurrentScreenSlice + bucketSlices] );
				nLeftmostBucketX += bucketWidth;				
				
				//ObjectPool.Instance().debug();  									
			}
			
			// update all active objects
			for each ( var wObj : IWorldObject in activeObjects ) {
				wObj.update();
			}				
		}

		public function get activeObjects():Array
		{
			return _activeObjects;
		}
	}
}

class ObjBucketInfo {
	public var type : String;
	public var x0 : Number;
	public var x1 : Number;
	public var y : Number;
	public var props : Object;
	
	public function ObjBucketInfo( _type : String, _x0 : Number, _y : Number, _x1 : Number, _props : Object ) {
		type = _type;
		x0 = _x0;
		x1 = _x1;
		y = _y;
		props = _props;
	}
}