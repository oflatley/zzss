package events
{
	import flash.events.Event;
	
	
	public final class LevelEvent extends Event
	{
		public static const GENERATED:String = "lvlGen";
		public static const START:String = 'lvlStart';
		public static const FINISH:String = 'lvlFinish';
		public var payload : * ;
		
		public function LevelEvent(type:String, _payload:* = null)
		{
			super(type);
			payload = _payload;
		}
	}
}