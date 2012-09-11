package states
{
	import collision.CollisionDataProvider;
	import collision.CollisionManager;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	
	import level.Level;
	
	import sim.PlayerSim;

	public class Glob
	{
		public var stage : Stage;
		public var applicationContainer : Sprite;
		
		public var collisionManager : CollisionManager;
		public var playerMC : MovieClip;
		public var playerSim:PlayerSim;
		public var currentLevel:Level;
		public var collisionDataProvider : CollisionDataProvider;		
		
		
		public function Glob()
		{
		}
	}
}