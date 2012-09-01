package events
{
	import flash.events.Event;
	
	public class WorldObjectEvent extends Event
	{
		public static const WORLDOBJECT_MOVE : String = "worldObjectMove";
		
		public function WorldObjectEvent(type:String )
		{
			super(type);
		}
	}
}