package collision
{
	import interfaces.IWorldObject;
	import util.Vector2;

	public class CollisionResult
	{
		private var _minSeperatingVector:Vector2;
		private var _collidedObj:IWorldObject;
		
		public function CollisionResult( msv:Vector2 = null, obj:IWorldObject = null )
		{
			_minSeperatingVector = msv;
			_collidedObj = obj;			
		}

		public function get msv():Vector2 {
			return _minSeperatingVector;
		}

		public function get collidedObj():IWorldObject {
			return _collidedObj;
		}
	}
}