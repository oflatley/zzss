package
{
	
	import avmplus.getQualifiedClassName;
	import avmplus.getQualifiedSuperclassName;
	
	import collision.CollisionDataProvider;
	import collision.CollisionManager;
	
	import events.CollisionDataProviderEvent;
	import events.CollisionEvent;
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
	import flash.utils.getTimer;
	
	import interfaces.ICollisionData;
	
	import io.Controller;
	
	import level.Level;
	import level.LevelFactory;
	
	import sim.PlayerSim;
	import sim.WorldObjectFactory;
	
	import util.Allocator;
	import util.ObjectPool;
	import util.ScreenContainer;
	import util.UnitTester;
	import util.Vector2;
	
	import views.PlayerView;

	[SWF(width='960', height='640')]
	public class SideScroller extends Sprite
	{
		private var collisionManager : CollisionManager;
		private var playerMC : MovieClip;
		private static const velocityX:Number = 2.5;
		private static const gravity :Number = 1.75;	
		private static const DESIGN_SIZE:Rectangle = new Rectangle(0,0,960,640);
//		private var worldStaticObjects : Array = new Array();
		private var playerSim:PlayerSim;
		private var currentLevel:Level;
		private var collisionDataProvider : CollisionDataProvider;		
		private var _waitingToCompleteCount : int;

		private static const allocationResouceSpec : Array = [
			{k:Vector2,n:150},
		//	{k:CollisionEvent,n:5},
			{k:Rectangle,n:10},
			{k:URLRequest,n:10},
			
		];

		
		private static const objPoolAllocs : Array = [
			{type:"StartSign",			count:1 },
			{type:"FinishSign",			count:1 },
			{type:"Platform_Arc_0" , 	count:15 },			
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

		private static const  worldObjectSpec : Object = {
			
			behaviors:[
				{name:"ModifyVelocity",					onCollision:{ type:"modVel" } },
				{name:"ModifySpeedTimed",				onCollision:{ type:"modVelTimed" }, properties:["Consumable"]  },
				{name:"ModifySize",						onCollision:{ type:"modSize" }, properties:['Consumable']  },
				{name:"Treasure",						onCollision:{ type:"tc" }, properties:['Consumable'] },
				{name:"AnimatedPlatform",				update:{type:"animPlat"} },
				{name:"Enemy", 							update:{type:"ai"}, properties:['Monster'] },
				{name:"Scenary",						collisionDetection:{type:"never"} },
				{name:"ED",								onCollision:{ type:"eventDispatcher"}, properties:['NoCollisionReaction']  }, //'Invisible',
			],
			
			classes: [
				{name:"Launcher", 					behavior:"ModifyVelocity", args:{ modVel:{x:0,y:-40} } },
				{name:"Trampoline", 				behavior:"ModifyVelocity", args:{ modVel:{x:0,y:-20} } },
				{name:"Catapult", 					behavior:"ModifyVelocity", args:{ modVel:{x:36,y:-34} } },
				{name:"SpringBoard", 				behavior:"ModifyVelocity", args:{ modVel:{x:10,y:-40} } },
				{name:"SpeedBoostCoin",				behavior:"ModifySpeedTimed", args:{ modVelTimed:{x:2,y:1,ms:3000 } } },
				{name:"Token_MakePlayerBigger",		behavior:"ModifySize", args:{ modSize:{s:1.5, ms:4000 } } },
				{name:"Token_MakePlayerSmaller",	behavior:"ModifySize", args:{ modSize:{s:0.5, ms:4000 } } },
				{name:"Brain",						behavior:"Treasure", args:{ tc:{value:1} } },	
				{name:"PlatformShort_elev", 		behavior:"AnimatedPlatform", args:{ animPlat:{pattern:"cycle", transition:"sin",speed:150} } },
				{name:"Enemy_0",					behavior:"Enemy", args:{ ai:{pattern:"left", speed:1} } },
				{name:"StartSign",					behavior:"ED", args:{ eventDispatcher:{klass:"LevelEvent", subType:'lvlStart' } } },
				{name:"FinishSign",					behavior:"ED", args:{ eventDispatcher:{klass:"LevelEvent", subType:'lvlFinish' } } },				
			]
		};		
		
		
		private function getProb( n : int ) : Number {
			if( n > 125 ) return .8;
			if( n < 25 ) return .2;
			return .5;
		}
		
		public function SideScroller()
		{
			super();
			
//			new UnitTester();
			WorldObjectFactory.instance.init( worldObjectSpec );		
			
			collisionManager = new CollisionManager();
			addChild( ScreenContainer.instance.container );						

			_waitingToCompleteCount = 3;
			ObjectPool.instance.buildMovieClipClasses( 'data/assets/assets.swf'); 
			ObjectPool.instance.loadObjectInfo( 'data/objectInfo.js');
			ObjectPool.instance.addEventListener( ObjectPoolEvent.INITIALIZED, onInitialized );
			CollisionDataProvider.instance.buildCollisionData("data/collisionObj/collisionData.js");
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
			playerView.AddToScene( ScreenContainer.instance.container );
			playerSim = new PlayerSim(new Controller(stage), velocityX, gravity, playerView.getBounds(), collisionManager );
			playerView.initEventListeners( playerSim );
  			playerSim.SetPosition( new Point( 0,275 ) );
	
			ObjectPool.instance.initialize( objPoolAllocs, ScreenContainer.instance );
			currentLevel = null;
			LevelFactory.instance.initialize( collisionManager, playerSim );
			LevelFactory.instance.addEventListener( LevelEvent.GENERATED, onLevelGenerated ); 
			LevelFactory.instance.generateLevel( "Level") ; 

			onResize( null );
		}
		
		protected function onLevelGenerated(event:LevelEvent):void
		{
			LevelFactory.instance.removeEventListener( LevelEvent.GENERATED, onLevelGenerated );
			currentLevel = event.payload;
			addEventListener(Event.RESIZE, onResize );
 			addEventListener(Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function onEnterFrame( e:Event ) : void {
	 		playerSim.Update();
			currentLevel.update(playerSim.worldPosition);
			collisionManager.update(playerSim,currentLevel.activeObjects);		// dispatches CollisionEvents
			ScreenContainer.instance.update( playerSim.worldPosition );		
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


