package events
{
	import flash.events.Event;
	
	
	public final class LevelEvent extends Event
	{
		public static const GENERATED:String = "generated";
		public var payload : * ;
		
		public function LevelEvent(type:String, _payload:*)
		{
			super(type);
			payload = _payload;
		}
	}
}