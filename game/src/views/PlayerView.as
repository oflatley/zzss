package views
{
	import events.PlayerEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import level.Level;
	
	import util.ObjectPool;


	public class PlayerView
	{
		private var mc:MovieClip;;
		private var _debugTP : Array = new Array(10);

		public function PlayerView()
		{
			mc = ObjectPool.instance.playerMC; // for swc: new Player();
			
			
			for( var i : int = 0; i < _debugTP.length; ++i ) {
				_debugTP[i] = ObjectPool.instance.getDebugBoundingBox();
				_debugTP[i].width = 3;
				_debugTP[i].height = 3;
			}
		}
		
		public function initEventListeners( ed : EventDispatcher ) : void {
			ed.addEventListener( PlayerEvent.PLAYER_MOVE, onPlayerMove );
			ed.addEventListener( PlayerEvent.PLAYER_SCALE, onPlayerScale );
			ed.addEventListener( PlayerEvent.PLAYER_DEBUG_INVALIDATE_COLLISION_NODES, onPlayerInvColNodes_debug );
		}
		
		protected function onPlayerInvColNodes_debug(event:PlayerEvent):void
		{
			drawTestPoints( event.collisionNodes_debug );
		}
		
		protected function onPlayerScale(event:PlayerEvent):void
		{
 			var n : Number = event.scale;
			mc.scaleX = n;
			mc.scaleY = n; 			
		}
		
		protected function onPlayerMove(event:PlayerEvent):void
		{
			var p : Point = event.newPostition;
			mc.x = p.x;
			mc.y = p.y;			
		}
		
		private function drawTestPoints( v : Vector.<Point> ) : void {
			for( var i : int = 0; i < _debugTP.length; ++i ) {
					
				var mc : MovieClip = _debugTP[i];
					
				if( i < v.length ) {					
					mc.x = v[i].x - 1;
					mc.y = v[i].y - 1;
					mc.visible = true;
				} else {
					mc.visible = false;
				}
			}
		}
		
		
		public function AddToScene( scene:Sprite ) : void {
			scene.addChild(mc);
			
			for( var i : int = 0; i < _debugTP.length; ++i ) {
				scene.addChild( _debugTP[i] );
			}
	
		}
		
		public function getBounds() : Rectangle {
			return new Rectangle( mc.x, mc.y, mc.width, mc.height );
		}
/*		
		private function SetPosition( p:Point ) : void {
			mc.x = p.x;
			mc.y = p.y;
		}
		private function scale( n : Number ) : void {
			mc.scaleX = n;
			mc.scaleY = n; 
		}
*/		
	}
}