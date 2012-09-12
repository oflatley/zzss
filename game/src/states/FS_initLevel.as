package states
{
	import interfaces.IFiniteState;

	public class FS_initLevel implements IFiniteState
	{
		private var _g : Glob;
		
		public function FS_initLevel(glob:Glob)
		{
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
			// TODO Auto Generated method stub
			return 'play';
		}
				
	}
}