package sim {
	import collision.CollisionDataProvider;
	import collision.CollisionManager;
	import collision.CollisionResult;
	
	import events.CollisionEvent;
	import events.WorldObjectEvent;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import interfaces.ICollider;
	import interfaces.ICollisionData;
	import interfaces.ICollisionDetectionHandler;
	import interfaces.IOnCollisionHandler;
	import interfaces.IQuerryHandler;
	import interfaces.IUpdateHandler;
	import interfaces.IWorldObject;
	import interfaces.IWorldObjectBehaviorOwner;
	
	import sim.PlayerSim;
	import sim.WorldObjectBehavior;
	
	import util.ScreenContainer;
	import util.Vector2;
	
	public class WorldObjectSim extends EventDispatcher implements IWorldObject, IWorldObjectBehaviorOwner {
		
		private var _bounds : Rectangle;
		private var _id : String;

		private var _IUpdate : IUpdateHandler;
		private var _IOnCollision : IOnCollisionHandler;
		private var _ICollisionDetection : ICollisionDetectionHandler;
		private var _IQuerry : IQuerryHandler;
		
		public function WorldObjectSim( id : String, bounds : Rectangle, behavior : WorldObjectBehavior ) {
			super();
			_id = id;
			_bounds = bounds;
			_ICollisionDetection = behavior.ICollisionDetection;
			_IOnCollision = behavior.IOnCollision;
			_IUpdate = behavior.IUpdate;
			_IQuerry = behavior.IQuerry;
		}
		
		public function get id() : String {
			return _id;
		}
		
		public function get bounds() : Rectangle {
			return _bounds;
		}
		
		public function set bounds( r : Rectangle ) : void {
			_bounds = r;
		}
		
		public function onCollision(player:PlayerSim):void
		{
			_IOnCollision.exec(player);
		}
		
		public function querry( s : String ) : Boolean {	
			return _IQuerry.exec(s);
		}

		public function update():void
		{
			_IUpdate.exec(this);
		}
		
		public function testCollision( iCol: ICollider ) : collision.CollisionResult {			
			var msv : Vector2 =  _ICollisionDetection.exec( iCol, _bounds );
			return msv ? new CollisionResult( msv, this ) : null;
		}
		
		public function offset(p:Point):void
		{
			_bounds.offsetPoint(p);
			dispatchEvent( new WorldObjectEvent( WorldObjectEvent.WORLDOBJECT_MOVE) );
		}
		
		public function get position():Point
		{
			return _bounds.topLeft;
		}
		
		public function set position(p:Point):void
		{
			_bounds.x = p.x;
			_bounds.y = p.y;
			dispatchEvent( new WorldObjectEvent( WorldObjectEvent.WORLDOBJECT_MOVE ) );
		}
		
		public function get eventDispatcher():EventDispatcher
		{
			return this;
		}				
	}
	
	/*
	class RegistrationAgent {
	public static function register( ids : Array, klass : Class ) : void {		
	for each ( var id : String in ids ) {
	WorldObjectFactory.instance.register( id, klass );
	}
	}
	}
	
	
	
	class LauncherSim extends WorldObjSimBase {
	
	RegistrationAgent.register( ['Launcher'], LauncherSim );
	
	private static const IMPULSE_Y : int = -40;
	
	public function LauncherSim( type : String, bounds : Rectangle ) 
	{
	super( type, bounds );
	}
	
	override public function onCollision( player:PlayerSim ) : void {
	
	player.applyImpulse( new Point( 0, IMPULSE_Y ) );
	}				
	}
	
	class TrampolineSim extends WorldObjSimBase {
	
	RegistrationAgent.register( ['Trampoline'], TrampolineSim );
	
	
	private static const VELOCITY_X : Number = 0;
	private static const VELOCITY_Y : Number = -20;
	
	public function TrampolineSim( type : String, bounds : Rectangle ) 
	{
	super( type, bounds );
	}
	
	override public function onCollision( player:PlayerSim ) : void {
	player.applyImpulse( new Point( VELOCITY_X, VELOCITY_Y ) );
	}	
	}
	
	class CatapultSim extends WorldObjSimBase {
	
	RegistrationAgent.register( ['Catapult'], CatapultSim );
	
	
	private static const VELOCITY_X : Number = 36;  
	private static const VELOCITY_Y : Number = -34;
	
	public function CatapultSim( type : String, bounds : Rectangle ) 
	{
	super( type,bounds );
	}
	
	override public function onCollision( player:PlayerSim ) : void {
	player.applyImpulse( new Point( VELOCITY_X, VELOCITY_Y ) );
	}	
	}
	
	class SpringBoardSim extends WorldObjSimBase {
	
	RegistrationAgent.register( ['SpringBoard'], SpringBoardSim );
	
	private static const IMPULSE_Y : int = -40;
	
	public function SpringBoardSim( type : String, bounds : Rectangle ) 
	{
	super( type,bounds );
	}
	
	override public function onCollision( player:PlayerSim ) : void {		
	player.applyImpulse( new Point( 0, IMPULSE_Y ) );
	}			
	}
	
	class SpeedBoostCoinSim extends WorldObjSimBase  {
	
	RegistrationAgent.register( ['SpeedBoostCoin'], SpeedBoostCoinSim );
	
	private static const DURATION_MS : int = 3000;
	private static const SPEED_MULTIPLIER : Number = 2;
	
	
	public function SpeedBoostCoinSim( type : String, bounds : Rectangle ) {
	super(type, bounds);
	registerQuerry( WorldObjectFactory.Q_CONSUMABLE );
	}
	
	override public function onCollision(player:PlayerSim):void
	{
	player.addSpeedBoost( DURATION_MS, SPEED_MULTIPLIER );		
	}
	}
	
	
	class Token_MakePlayerBiggerSim extends WorldObjSimBase {
	
	RegistrationAgent.register( ['Token_MakePlayerBigger'], Token_MakePlayerBiggerSim );
	
	private static const DURATION_MS : int = 4000;
	private static const SCALE_TO_APPLY : Number = 1.50;
	
	public function Token_MakePlayerBiggerSim( type : String, bounds : Rectangle ) {
	super(type,bounds);
	registerQuerry( WorldObjectFactory.Q_CONSUMABLE );
	}
	
	override public function onCollision(player:PlayerSim):void
	{
	player.scale( SCALE_TO_APPLY, DURATION_MS  );		
	}
	
	}
	class Token_MakePlayerSmallerSim extends WorldObjSimBase {
	
	RegistrationAgent.register( ['Token_MakePlayerSmaller'], Token_MakePlayerSmallerSim );
	
	private static const DURATION_MS : int = 4000;
	private static const SCALE_TO_APPLY : Number = 0.5;
	
	public function Token_MakePlayerSmallerSim( type : String, bounds : Rectangle ) {
	super(type,bounds);
	registerQuerry( WorldObjectFactory.Q_CONSUMABLE );
	}
	
	override public function onCollision(player:PlayerSim):void
	{
	player.scale( SCALE_TO_APPLY, DURATION_MS );	
	}
	
	}
	
	class BrainCoinSim extends WorldObjSimBase  {
	
	RegistrationAgent.register( ['Brain'], BrainCoinSim );
	
	private static const BRAIN_COIN_VALUE : int = 1;
	
	public function BrainCoinSim( type : String, bounds : Rectangle ) {
	super(type, bounds);
	registerQuerry( WorldObjectFactory.Q_CONSUMABLE );
	}
	
	override public function onCollision( player:PlayerSim ) : void {
	player.addCoins( BRAIN_COIN_VALUE );
	}
	
	}
	
	
	
	class ElevatorPlatformSim extends WorldObjSimBase  {
	
	RegistrationAgent.register( ['PlatformShort_elev'], ElevatorPlatformSim );
	
	private var theta : Number;
	private var lastY : Number;
	
	public function ElevatorPlatformSim( type : String, bounds : Rectangle ) {
	super(type, bounds);
	theta = 0;
	lastY = 0;
	}
	
	override public function update():void
	{
	theta += Math.PI / 80;
	var thisY : Number= 150 * Math.sin( theta ); 
	
	var delta : Number= thisY - lastY;
	lastY = thisY;
	offset( new Point( 0, delta ) );
	
	}
	
	
	}
	
	class EnemyBlobSim extends WorldObjSimBase  {
	
	RegistrationAgent.register( ['Enemy_0'] , EnemyBlobSim );
	
	private static const VELOCITY_X : Number = 1;
	
	private var pImpulse : Point;
	private var range : Number; 
	private var homeX:Number;
	private var dir:int;
	
	public function EnemyBlobSim( type : String,  bounds : Rectangle  ) {
	super(type,bounds);
	pImpulse = new Point();
	dir = -1;		// start walking left
	registerQuerry( WorldObjectFactory.Q_MONSTER );
	}
	
	override public function update():void
	{
	pImpulse.x = computeImpulseX();
	offset( pImpulse );
	}
	
	override public function setProps(props:Object):void
	{
	range = props.range;
	homeX = props.homeX;
	}
	
	private function computeImpulseX() : Number {
	
	if( ! isOnscreen() ) {
	return 0;
	}
	
	var newX : Number =_bounds.left + dir * VELOCITY_X;
	
	if( newX <= homeX - range ) {
	dir = 1;
	newX = homeX - range;
	} 
	else if ( newX >= homeX ) {
	dir = -1;
	newX = homeX;
	}
	return newX - _bounds.left;			
	
	}
	
	private function isOnscreen() : Boolean {
	return ScreenContainer.Instance().isOnscreen( _bounds.left );
	}
	
	
	
	}
	
	class LevelPlatformDataSim extends WorldObjSimBase  {
	
	RegistrationAgent.register( ["Column","Platform_Arc_0","PlatformShort_0","PlatformMedium_0","PlatformLong_0","PlatformMedium_15","PlatformMedium_345"], LevelPlatformDataSim );
	
	public function LevelPlatformDataSim( type : String, bounds : Rectangle ) {		
	super(type,bounds);
	}		
	}
	
	class ScenarySim extends WorldObjSimBase {
	
	RegistrationAgent.register( ["StartSign","FinishSign"], ScenarySim );
	
	public function ScenarySim( type : String, bounds : Rectangle ) {
	super( type, bounds );
	}
	
	override public function testCollision( iCol: ICollider ) : collision.CollisionResult {
	return null; 
	}
	
	
	}
	*/

}