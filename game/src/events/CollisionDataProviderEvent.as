package events
{
	import flash.events.Event;
	
	public class CollisionDataProviderEvent extends Event
	{
		public static const INITIALIZED : String = "init";
		
		public function CollisionDataProviderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type);
		}
	}
}