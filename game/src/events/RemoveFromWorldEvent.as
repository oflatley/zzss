package events
{
	import flash.events.Event;	
	import interfaces.IWorldObject;

	public class RemoveFromWorldEvent extends Event
	{

		public static const REMOVE_FROM_WORLD:String = "removeFromWorld";
		
		private var _wo : IWorldObject;
		
		public function RemoveFromWorldEvent(type:String, wo : IWorldObject )
		{
			super( type );
			_wo = wo;
		}
		
		public function get objToRemove():IWorldObject 
		{			
			return _wo;
		}
	}
}