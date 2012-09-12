package states
{
	import interfaces.IFiniteState;
	
	import util.ScreenContainer;

	public class FS_playGame implements IFiniteState
	{
		private var _g : Glob;
		
		public function FS_playGame( glob : Glob ) {
			_g = glob;
		}
		
		public function enter():void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function exit():void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function update(delta_ms:Number):String
		{
  			_g.playerSim.Update();
			_g.currentLevel.update(_g.playerSim.worldPosition);
			_g.collisionManager.update(_g.playerSim,_g.currentLevel.activeObjects);		// dispatches CollisionEvents
			ScreenContainer.instance.update( _g.playerSim.worldPosition );		
			return null;
		}
		
	}
}