package fsm
{
	import interfaces.IFiniteState;

	public class FiniteStateMachine
	{
		private var _map : Array = new Array(); // TODO Dictionary
		private var _currentState : IFiniteState;
		private var _targetState : IFiniteState;	
		private var _initialState : IFiniteState = null
		
		public function FiniteStateMachine() {}
		
		public function addState( id : String, I : IFiniteState ) : Boolean {
			if( !findState(id) ) {
				_map[id] = I;
				return true;
			} else {
				//return false;
				throw new Error('FSM already has a state with that id ' + id );		
			}
		}
		
		public function set initialState( id : String ) : void {
			if( !_initialState ) {
				_initialState = findState( id ) ;
				_currentState = _initialState;
				_currentState.enter();
			}
			else
				throw new Error( "FSM: Initial state already set" );
			
			if( !_initialState )
				throw new Error( "FSM: could not find specified initial state: " + id );
				
		}
		
		public function removeState( id : String )  : void {
			delete _map[id];
		}
		
		public function update( deltaTime_ms : Number ) : void {
		
			if( _targetState ) {
				if( _currentState ) {
					_currentState.exit();					
				}
				_targetState.enter();
				_currentState = _targetState;
			}
			var sTargetStateID : String =  _currentState.update( deltaTime_ms );
			_targetState = findState( sTargetStateID ) ;
		
		}
		
		private function findState( id : String ) : IFiniteState {
		
			if( id ) {
				for ( var s : String in _map ) {
					if( s == id ) {
						return _map[s];
					}				
				}
			}
			return null;
		}
		
		////////////-------------------------------------------------------
		// commands for states, but not for external clients -- TODO: refactor
		
		public function goto( id : String ) : void {
			
		}
	}
}