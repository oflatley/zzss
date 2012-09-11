package states
{
	import collision.CollisionDataProvider;
	import collision.CollisionManager;
	
	import events.CollisionDataProviderEvent;
	import events.LevelEvent;
	import events.ObjectPoolEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import interfaces.IFiniteState;
	
	import io.Controller;
	
	import level.Level;
	import level.LevelFactory;
	
	import sim.PlayerSim;
	import sim.WorldObjectFactory;
	
	import util.ObjectPool;
	import util.ScreenContainer;
	
	import views.PlayerView;
	
	public class FS_gameInit implements IFiniteState
	{

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
		
		
		private static const velocityX:Number = 2.5;
		private static const gravity :Number = 1.75;	
		private static const DESIGN_SIZE:Rectangle = new Rectangle(0,0,960,640);
		private var _waitingToCompleteCount : int;
		private var _blInitComplete;
		
		
		private var _g : Glob;
		
		public function FS_gameInit( glob : Glob )
		{
			_g = glob;
		}
		
		public function enter():void
		{
			_blInitComplete = false;
			init();
			
		}
		
		public function update(delta_ms:Number):String
		{
			if( _blInitComplete ) {
				return 'FS_gamePlay';
			}
		}
		
		public function exit():void
		{
		}
		
		
		
		private function init() : void {
			WorldObjectFactory.instance.init( worldObjectSpec );		
			
			_g.collisionManager = new CollisionManager();
			_g.applicationContainer.addChild( ScreenContainer.instance.container );						
			
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
			
			_g.stage.color = 0x444444;
			_g.stage.frameRate = 60;
			
			var playerView : PlayerView = new PlayerView(  );
			playerView.AddToScene( ScreenContainer.instance.container );
			_g.playerSim = new PlayerSim(new Controller(_g.stage), velocityX, gravity, playerView.getBounds(), _g.collisionManager );
			playerView.initEventListeners( _g.playerSim );
			_g.playerSim.SetPosition( new Point( 0,275 ) );
			
			ObjectPool.instance.initialize( objPoolAllocs, ScreenContainer.instance );
			_g.currentLevel = null;
			LevelFactory.instance.initialize( _g.collisionManager, _g.playerSim );
			LevelFactory.instance.addEventListener( LevelEvent.GENERATED, onLevelGenerated ); 
			LevelFactory.instance.generateLevel( "Level") ; 
			
		}
		
		protected function onLevelGenerated(event:LevelEvent):void
		{
			LevelFactory.instance.removeEventListener( LevelEvent.GENERATED, onLevelGenerated );
			_g.currentLevel = event.payload;
			_g.applicationContainer.addEventListener(Event.RESIZE, onResize );
			//addEventListener(Event.ENTER_FRAME, onEnterFrame );
			_blInitComplete = true;
		}
		
		private function onResize( e:Event ) : void {
			
			var stage : Stage = _g.stage;
			var c : Sprite = _g.applicationContainer;
			
			trace( stage.stageWidth );
			trace( stage.stageHeight );
			var scale:Number = Math.min( stage.stageWidth/DESIGN_SIZE.width, stage.stageHeight/DESIGN_SIZE.height );
			c.scaleX = c.scaleY = scale;
			c.x = (stage.stageWidth - scale*DESIGN_SIZE.width)/2;
			c.y = (stage.stageHeight - scale*DESIGN_SIZE.height)/2;			
		}
	}
}





