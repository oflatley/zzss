package level {	
	import events.LevelEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import interfaces.ILevelData;
	
	import level.Level;
	import level.LevelFactory;
	
	import util.ObjectPool;
	
	public class LevelInstanceBase extends EventDispatcher {
		
		private var _sections : Array;
		private static const urlBaseFolder : String = 'data/level/';
		private static const _startEndFilename : String = 'StartFinish';
		private var _loadedSectionsJson : Array = new Array();
		private var _sName : String;
		private var _startEndLevelFile : LevelFile = null;
		
		public function LevelInstanceBase(sName:String)  {
			_sName = sName;
		}
		
		// TODO protected ??? wtf
		public function set sections(value:Array) : void { 
//			_sections = value; 
//			_sections.push( "Start" );
//			_sections.push( "Finish" );			
		}  
		
		private function generateShuffledSections( sectionKeys : Array ) : Array {
			
			var order : Array = new Array();
			for( var i : int = 0; i < sectionKeys.length; ++i ) {
					order.push(i);		
			}
			
			var shuffledKeys : Array = new Array();

			while( order.length ) {
				var n : Number = Math.random();
				var r : int = n * (order.length - 1) + .5;
				var dx : int = order.splice( r, 1 )[0];
				shuffledKeys.push( sectionKeys[dx] );				
			}
			
			return shuffledKeys;
		}
		
		public function generate( ) : void { 			
			if( null == _startEndLevelFile ) {				
				loadfile( _startEndFilename, onStartEndLoadComplete );
			} else {	
				loadfile( _sName, onLoadComplete );
			}
		} 
		
		private function loadfile( sFilename : String, cb : Function ) : void  {
			var urlLoader : URLLoader = new URLLoader();
			urlLoader.addEventListener( Event.COMPLETE, cb );
			var url : String = urlBaseFolder + sFilename + '.js';
			var req : URLRequest = new URLRequest(url);
			urlLoader.load( req );			
		}
		
		protected function onStartEndLoadComplete(event:Event):void
		{
			event.target.removeEventListener( Event.COMPLETE, arguments.callee );
			_startEndLevelFile = new LevelFile( event.target.data );
			generate();  // call generate again, but this time _startEndLevelFile will be non-null. thus, we only load startend data once 
		}
		
		protected function onLoadComplete(event:Event) : void {
			event.target.removeEventListener( Event.COMPLETE, arguments.callee );
			var levelFile : LevelFile = new LevelFile(  event.target.data );
			
			var shuffledKeys : Array = generateShuffledSections(levelFile.sectionKeys);

			var sections : Array = new Array();
			
			sections.push( _startEndLevelFile.getSection("Start" ) );
			for( var i : int = 0; i < shuffledKeys.length; ++i ) {
				sections.push( levelFile.getSection( shuffledKeys[i] ) );
			}	
			sections.push( _startEndLevelFile.getSection("Finish" ) );
			
			var aGenLevelData : Array =  generateWorldObjData( sections ) ;
			
			var ev : LevelEvent = new LevelEvent( LevelEvent.GENERATED, aGenLevelData );				
			dispatchEvent( ev );		
		}
		
		private function generateWorldObjData( levelSections : Array ) : Array {
			
			var a : Array = new Array();
			var fixupX : Number = 0;
			for each ( var ls : LevelSection in levelSections ) {
				
				var aWO : Array = ls.worldObjects; 
				for each ( var wo : Object in aWO ) {
					
					wo.x += fixupX;
					a.push( wo ); 									
				}				
				fixupX += ls.range_x;
			}
			return a;
		}
	}
}	


class LevelFile {
	
	private var _version : String;
	private var _fileName : String;
	private var _sectionKeys : Array;
	private var _sections : Array = new Array();
	
	public function LevelFile( json : String ) {

		var data :Object = JSON.parse( json );
		
		_version = data.version;
		_fileName = data.name;
		_sectionKeys = data.sectionKeys;
		
		for each( var s : Object in data.sections ) {
			_sections[s.name] = new LevelSection(s.content);						
		}
	}
	
	public function get sectionKeys() : Array { return _sectionKeys; }
	
	public function getSection( key : String ) : LevelSection {
		return _sections[key];
	}
	
}


class LevelSection {
	
	private var _range : Object;
	private var _pool : Array;
	private var _aWO : Array;
	
	public function LevelSection( content : Object ) {
		_range = content.range;
		_pool = content.pool;
		_aWO = content.worldObjects;
		
		for each ( var wo : Object in _aWO ) {
			trace( wo.type + ' ' + wo.x + ' ' + wo.y );
		}
	}
	
	public function get range_x() : Number {
		return _range.x;
	}
	public function get range_y() : Number {
		return _range.y;
	}
	
	public function get worldObjects() : Array {
		return _aWO;
	}
	
}