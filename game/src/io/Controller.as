package io
{
	import events.ControllerEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public final class Controller extends EventDispatcher
	{
		public function Controller(parent:Object)
		{
			parent.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );  		
		}
		
		private function onKeyDown( e:KeyboardEvent ) : void {
			if( Keyboard.SPACE == e.keyCode ) {
 				dispatchEvent( new ControllerEvent(ControllerEvent.JUMP) );
			}
		}
	}
}