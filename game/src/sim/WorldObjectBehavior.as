package sim {
	import flash.events.EventDispatcher;
	
	import interfaces.ICollisionDetectionHandler;
	import interfaces.IOnCollisionHandler;
	import interfaces.IQuerryHandler;
	import interfaces.IUpdateHandler;

	public class WorldObjectBehavior  {
		
		private var _IUpdate : IUpdateHandler; 
		private var _IOnCollision : IOnCollisionHandler;
		private var _ICollisionDetection : ICollisionDetectionHandler;
		private var _IQuerry : IQuerryHandler;
		
		
		public function WorldObjectBehavior( IUp : IUpdateHandler, IOnC : IOnCollisionHandler, ICol : ICollisionDetectionHandler, IQ :IQuerryHandler ) {
			_IUpdate = IUp;
			_IOnCollision = IOnC;
			_ICollisionDetection = ICol;
			_IQuerry = IQ;
			
		}
		
		public function registerEvent( classFilter : Class, type : String, listener : Function ) : void {

			if( ! classFilter is EventDispatcher ) {
				throw new Error( 'classFilter is expected to be EventDispatcher, recieved ' + classFilter );
			}
			
//			_IUpdate.registerEvent( classFilter, type, listener );
			_IOnCollision.registerEvent( classFilter, type, listener );
//			_ICollisionDetection.registerEvent( classFilter, type, listener );
//			_IQuerry.registerEvent( classFilter, type, listener ); 
		}
		
	
		public function get ICollisionDetection():ICollisionDetectionHandler { return _ICollisionDetection; }
		public function get IOnCollision():IOnCollisionHandler { return _IOnCollision; }
		public function get IUpdate() : IUpdateHandler { return _IUpdate; }
		public function get IQuerry() : IQuerryHandler { return _IQuerry; }
	}
}