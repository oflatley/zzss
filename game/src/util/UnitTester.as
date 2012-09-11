package util
{
	public class UnitTester {
		
		private var _tests : Vector.<IUnitTest> = new Vector.<IUnitTest>();
		
		public function UnitTester() {
			_tests.push( new UT_allocator() );
			_tests.push( new UT_FSM() );
			
			
			var bOK : Boolean = true;
			for each( var I : IUnitTest in _tests ) {
				bOK &&= I.test();
			}
			
			if( !bOK ) {
				throw new Error('Unit test failure!');
			}
		}
		
	}
}
//////////////////////////////////////////
import flash.display.Sprite;
import flash.utils.getTimer;

import fsm.FiniteStateMachine;

import interfaces.IFiniteState;


interface IUnitTest {
	function test() : Boolean;
}




class UT_FSM implements IUnitTest {
	
	private var _lastTimeStamp : int;

	public function UT_FSM() {}
	
	public function test() : Boolean {
		
		var the :FiniteStateMachine = new FiniteStateMachine();
	
		the.addState( "A", new UT_FSM_a() );
		the.addState( "B", new UT_FSM_b() );
		the.addState( "C", new UT_FSM_c() );
//		the.addState( "C", new UT_FSM_c() );
		the.removeState( "A" );
		the.addState( "A", new UT_FSM_a() );
		the.initialState = "A";
		
		_lastTimeStamp = getTimer();
		
		for( var i : int = 0; i < 250; ++i ) {
			trace('FSM Unit Test. Loop = ' + i );
			
			var now : int = getTimer();
			var delta_ms : int = now - _lastTimeStamp;			
			the.update( delta_ms );
			_lastTimeStamp = now;		
			
			
			for( var j : int = 0 ; j < 000000; ++j ) {
				Math.sin( Math.sqrt( Math.random() ) );
			}
		}
		
		return true;
	}
}





class UT_FSM_a implements IFiniteState {
	
	private var _count : int = 0;
	
	public function UT_FSM_a() {}
	
	public function enter() : void {
		trace('a enter');
		_count = 0;
	}
	
	public function update( delta_ms : Number) : String 
	{ 
		trace('a update: ' + delta_ms);
	
		return ++_count == 2 ? "B" : null; 
	}
	
	public function exit() : void {
		trace('a exit')
	}
}

class UT_FSM_b implements IFiniteState {
	
	public function UT_FSM_b() {}
	
	public function enter() : void {
		trace('b enter');
	}
	
	public function update( delta_ms : Number) : String 
	{ 
		trace('b update: ' + delta_ms);
		return "C"; 
	}
	
	public function exit() : void {
		trace('b exit')
	}
}

class UT_FSM_c implements IFiniteState {
	
	public function UT_FSM_c() {}
	
	public function enter() : void {
		trace('c enter');
	}
	
	public function update( delta_ms : Number) : String 
	{ 
		trace('c update: ' + delta_ms );
		if( Math.random() < 0.5 ) {
			if( Math.random() < .5 ) 
				return "B";
			return "A";
		}
		return null; 
	}
	
	public function exit() : void {
		trace('c exit')
	}
}

class UT_allocator implements IUnitTest {
	
	public function UT_allocator() {
		/*			
		// this should be the first line of call after super();
		Allocator.instance.initialize( allocationResouceSpec );
		
		
		var t0 : int = getTimer();	
		var bag : Array = new Array();
		for( var i : int = 0; i < 75; ++i ) {
		bag.push( Allocator.instance.alloc(Vector2) );
		}
		
		for( i = 0; i < 5000; ++i ) {
		if( Math.random() > getProb(bag.length) ) {
		//alloc
		bag.push( Allocator.instance.alloc(Vector2) );
		
		} else {
		//free
		var r : Number = Math.random(); 
		var dx : int = int( (bag.length-1) * r +0.5);
		
		var v : Vector2 = bag.splice( dx, 1)[0];
		Allocator.instance.free(v);				
		}
		}	
		
		var t1: int = getTimer();
		var elapsed : Number = (t1-t0)/1000;
		
		//44, 44.7  vs 61.9, 62.5
		// 47.8
		*/			
		
	}
	
	
	public function test() : Boolean {
		return true;
	}
	
}

