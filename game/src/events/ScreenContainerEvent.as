package events
{
	import flash.events.Event;	

	public class ScreenContainerEvent extends Event
	{
		public static const SLICE_SCROLL : String = "sliceScroll";
		public var ndxSlice : int;
		
		public function ScreenContainerEvent(type:String, _ndxSlice:int )
		{
			super(type);		
			ndxSlice = _ndxSlice;
		}		
	}
}