package
{
	
	import collision.CollisionDataProvider;
	
	import events.CollisionDataProviderEvent;
	import events.ControllerEvent;
	import events.LevelEvent;
	import events.ObjectPoolEvent;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.flash_proxy;
	
	import interfaces.ICollisionData;
	
	import level.LevelFactory;
	
	import level.Level;
	import sim.PlayerSim;
	
	import collision.CollisionManager;
	import io.Controller;
	import util.ObjectPool;
	import util.ScreenContainer;
	
	import views.PlayerView;

	[SWF(width='960', height='640')]
	public class SideScroller extends Sprite
	{
		private var collisionManager : CollisionManager;
		private var playerMC : MovieClip;
		private static const velocityX:Number = 2.5;
		private static const gravity :Number = 1.75;	
		private static const DESIGN_SIZE:Rectangle = new Rectangle(0,0,960,640);
		private var worldStaticObjects : Array = new Array();
		private var playerSim:PlayerSim;
		private var currentLevel:Level;
		private var screenContainer : ScreenContainer;
		private var collisionDataProvider : CollisionDataProvider;		
		private var _waitingToCompleteCount : int;

		
		private static const objPoolAllocs : Array = [
			{type:"Platform_Arc_0" , 	count:5 },			
			{type:"PlatformShort_0" , 	count:12 },			
			{type:"PlatformMedium_0", 	count:10 },
			{type:"PlatformMedium_15", 	count:10 },
			{type:"PlatformMedium_345", count:10 },
			{type:"PlatformLong_0", 	count:10 },
			{type:"Enemy_0",			count:10 },
			{type:"Column",				count:10 },
			{type:"PlatformShort_elev",	count:10 },
			{type:"Brain",				count:10 },
			{type:"SpeedBoostCoin",		count:10 },
			{type:"SpringBoard",		count:5 },
			{type:"Token_MakePlayerBigger",	count:3 },
			{type:"Token_MakePlayerSmaller",count:3 },
			{type:"Trampoline", count:3 },
			{type:"Launcher",count:5 },
			{type:"Catapult",count:3 },
			];

		
		public function SideScroller()
		{
			super();
			
			collisionManager = new CollisionManager();
			screenContainer = ScreenContainer.Instance();
			addChild( screenContainer.container );						

			_waitingToCompleteCount = 3;
			ObjectPool.instance.buildMovieClipClasses( 'data/assets/assets.swf'); 
			ObjectPool.instance.loadObjectInfo( 'data/objectInfo.xml');
			ObjectPool.instance.addEventListener( ObjectPoolEvent.INITIALIZED, onInitialized );
			CollisionDataProvider.instance.buildCollisionData("data/collisionObj/collisionData.xml");
			CollisionDataProvider.instance.addEventListener( CollisionDataProviderEvent.INITIALIZED, onInitialized );			
		}
		
		private function onInitialized(e:Event): void {
		
			_waitingToCompleteCount--;
		
			if( 0 == _waitingToCompleteCount ) {
				startGame();				
			}
		}
		
		private function startGame():void{

			stage.color = 0x444444;
			stage.frameRate = 60;
			
			var playerView : PlayerView = new PlayerView(  );
			playerView.AddToScene( screenContainer.container );
			playerSim = new PlayerSim(new Controller(stage), velocityX, gravity, playerView.getBounds(), collisionManager );
			playerView.initEventListeners( playerSim );
			playerSim.SetPosition( new Point( 10,405 ) );
	
			ObjectPool.instance.initialize( objPoolAllocs, screenContainer );
			currentLevel = null;
			LevelFactory.instance.initialize( collisionManager, playerSim );
			LevelFactory.instance.addEventListener( LevelEvent.GENERATED, onLevelGenerated ); 
			LevelFactory.instance.generateLevel( "Level0") ; 

			onResize( null );
			addEventListener(Event.RESIZE, onResize );
 			addEventListener(Event.ENTER_FRAME, onEnterFrame );
		}
		
		protected function onLevelGenerated(event:LevelEvent):void
		{
			LevelFactory.instance.removeEventListener( LevelEvent.GENERATED, onLevelGenerated );
			currentLevel = event.payload;
		}
		
		private function onEnterFrame( e:Event ) : void {
		
	 		playerSim.Update();
			currentLevel.update(playerSim.worldPosition);
			collisionManager.update(playerSim,currentLevel.activeObjects);		// dispatches CollisionEvents
			screenContainer.update( playerSim.worldPosition );		
		}
		
		private function onResize( e:Event ) : void {
			trace( stage.stageWidth );
			trace( stage.stageHeight );
			var scale:Number = Math.min( stage.stageWidth/DESIGN_SIZE.width, stage.stageHeight/DESIGN_SIZE.height );
			scaleX = scaleY = scale;
			this.x = (stage.stageWidth - scale*DESIGN_SIZE.width)/2;
			this.y = (stage.stageHeight - scale*DESIGN_SIZE.height)/2;			
		}
	}
}


