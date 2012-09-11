package level
{	
	import collision.CollisionManager;
	
	import events.LevelEvent;
	
	import flash.events.EventDispatcher;
	
	import interfaces.ILevelData;
	
	import level.Level;
	
	import sim.PlayerSim;
	
	import util.ObjectPool;
	
	public class LevelFactory extends EventDispatcher
	{
		private static var _theThe : LevelFactory = null;
		private var _levels:Array = new Array();
		private var _cm : CollisionManager = null;
		private var _ps : PlayerSim = null;
				
		public static function get instance() : LevelFactory {
			if( !_theThe ) {
				_theThe = new LevelFactory( new SingletonEnforcer() );
			}
			return _theThe;
		}
		
		public function initialize( cm : CollisionManager, ps : PlayerSim ) : void {
			_cm = cm;
			_ps = ps;		
		}
		
		public function LevelFactory( se : SingletonEnforcer ) {
		}
			
		public function registerLevel( tag : String, levelInstanceClass : Class ) : void {
			_levels[tag] = levelInstanceClass;
		}
				
		public function generateLevel( s:String ) : void {
			//var li : LevelInstanceBase = new _levels[s]();
			var li : LevelInstanceBase = new LevelInstanceBase( s );
			
			li.addEventListener( LevelEvent.GENERATED, onGenerationComplete );
			li.generate(); 
		}
		
		private function onGenerationComplete( event : LevelEvent ):void
		{			
			var aGeneratedLevel : Array = event.payload;
			var le : LevelEvent = new LevelEvent( LevelEvent.GENERATED, new Level( aGeneratedLevel, _cm, _ps ) );
			dispatchEvent( le );
		}		
	}
}

class SingletonEnforcer {}

/*
import level.LevelFactory;
import level.LevelInstanceBase;


class LevelInstance_0 extends LevelInstanceBase {
	public function LevelInstance_0() {
		super.sections = ['Debug'];//['Level0'];//,Level1]; 	
	}	
}

class LevelInstance_1 extends LevelInstanceBase {
	public function LevelInstance_1( ) {		
		super.sections = ['Level0','Level1'];
	}
}	

*/



