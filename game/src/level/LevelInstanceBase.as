package level {	
	import events.LevelEvent;	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;	
	import interfaces.ILevelData;	
	import level.LevelFactory;	
	import level.Level;	
	import util.ObjectPool;
	
	public class LevelInstanceBase extends EventDispatcher {
		
		private var _sections : Array;
		private static const urlBaseFolder : String = 'data/level/';
		private var _loadedSectionsXml : Array = new Array();
		
		public function LevelInstanceBase()  {}
		
		// TODO protected ??? wtf
		public function set sections(value:Array) : void { 
			_sections = value; 
//			_sections.push( "Start" );
//			_sections.push( "Finish" );			
		}  
		
		private function generateShuffledSections() : Array {
			
			var order : Array = new Array();
			var shuffledSections : Array = new Array();
			for( var i : int = 0; i < _sections.length; ++i ) {
				var s : String = _sections[i];
				if( s != "Start" && s != "Finish" ) {			
					order.push(i);		
				}
			}
			
//			shuffledSections.push( "Start" );
			
			while( order.length ) {
				var n : Number = Math.random();
				var r : int = n * (order.length - 1) + .5;
				var dx : int = order.splice( r, 1 )[0];
				shuffledSections.push( _sections[dx] );
			}
			
//			shuffledSections.push( "Finish" );			
			return shuffledSections;
		}
		
		public function generate( ) : void { 			

			for each( var s : String in _sections ) {
				var urlLoader : URLLoader = new URLLoader() ;
				urlLoader.addEventListener( Event.COMPLETE, onLoadComplete );		
				var url : String = urlBaseFolder + s + '.xml';
				var req : URLRequest = new URLRequest( url );
				urlLoader.load( req );
			}			
		} 
		
		private function getLevelJSON( s : String, aJson : Array ) : Object {
			for( var i : int = 0; i < aJson.length; ++i ) {	
				if( s == aJson[i].name ) {
					return aJson[i];
				}
			}
			return null;
		}
		
		protected function onLoadComplete(event:Event):void
		{
			//event.target.removeEventListener( Event.COMPLETE, arguments.callee );
			_loadedSectionsXml.push( event.target.data );
			
			if( _loadedSectionsXml.length == _sections.length ) {
				
				var jsonSections : Array = new Array();
				
				for( var i : int = 0; i < _loadedSectionsXml.length; ++i ) {
					jsonSections.push( JSON.parse( _loadedSectionsXml[i] ) );
				}
								
				var shuffledSections : Array = generateShuffledSections();
				var aGenLevelData : Array = new Array();		
				var xFixup : Number = 0;
				
				for each( var s : String in shuffledSections ) {
									
					var js : Object = getLevelJSON(s,jsonSections);
					var worldObjects : Array = js.worldObjects;
					
					for each( var wo : Object in worldObjects ) {
						wo.x += xFixup;
						aGenLevelData.push( wo );
					}					
					xFixup += js.spans.x;
				}		
								
				var ev : LevelEvent = new LevelEvent( LevelEvent.GENERATED, aGenLevelData );				
				dispatchEvent( ev );
			}
		}
	}
}	

