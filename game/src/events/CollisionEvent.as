package events
{
	import flash.events.Event;
	
	import collision.CollisionResult;
	
	
	public class CollisionEvent extends Event
	{
		public static const PLAYERxWORLD : String = "playerxWorld";
		
		public var collisionResult : CollisionResult;
		
		public function CollisionEvent(type:String, cr:CollisionResult = null)
		{
			super(type);
			collisionResult = cr;
		}		
	}
}