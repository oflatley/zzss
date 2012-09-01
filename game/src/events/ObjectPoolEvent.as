package events
{
	import flash.events.Event;
	
	
	public final class ObjectPoolEvent extends Event
	{
		public static const INITIALIZED:String = "init";
		
		public function ObjectPoolEvent(type:String)
		{
			super(type);
		}
	}
}