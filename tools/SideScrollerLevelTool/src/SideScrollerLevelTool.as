package
{
	import avmplus.getQualifiedClassName;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	public class SideScrollerLevelTool extends Sprite
	{
		private var fileData:String;
		private var _worldObjects : Array = new Array();
		private var loader:Loader;
		private var _fileRootName:String;
		private var sFileDir:String;
		private var _json : String;
		
		public function SideScrollerLevelTool() {
			
			var levelFile : File = new File();
			var filter : FileFilter = new FileFilter("swf","*.swf");
			
			levelFile.browseForOpen("Open the Level File" , [filter] );
			levelFile.addEventListener( Event.SELECT, onLevelFileSelected );		
		}
		
		protected function onLevelFileSelected(event:Event):void
		{
			var s : String = event.target.name as String;
			_fileRootName = s.split( /\./ )[0];
			var firstChar : String = _fileRootName.substr(0,1);
			var restOfStr : String = _fileRootName.substr(1,_fileRootName.length);
			_fileRootName = firstChar.toUpperCase() + restOfStr;
			sFileDir = event.target.parent.nativePath;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
			var url:URLRequest = new URLRequest( event.target.url );
			loader.load(url);
		}
		
		
		
		private function generateThisSection( container:MovieClip ) : Object {
			
			var worldObjects : Array  = new Array();

			trace( '****: ' + container.currentFrameLabel );
			var maxX : Number = -Infinity;
			var maxY : Number = -Infinity; 
			
			var count : int = container.numChildren;
			
			for( var i : int = 0 ; i < count; ++i ) {
				var mc:DisplayObject = container.getChildAt(i);
				var name:String = getQualifiedClassName(mc);
				
				
				var dx : int = name.indexOf("flash.display::" );
				
				if( mc.y <= 640 && -1 == dx ) {

					trace(name + ' ' + mc.x + ' ' + mc.y);
					worldObjects.push( new WorldObject( name, mc.x, mc.y ) ); 
					maxX = Math.max( maxX, mc.x + mc.width );
					maxY = Math.max( maxY, mc.y + mc.height);
				}
			}
			
			
			// sort by increasing x
			worldObjects.sort( orderWorldObjects );
			var poolMap : Array = new Array();
			
			for each( var wo : WorldObject in worldObjects ) {
				if( poolMap[wo.name] ) {
					poolMap[wo.name]++
				} else {
					poolMap[wo.name] = 1;
				}
			}
			
			var data : Object = new Object();

			data.range = new Object();
			data.range.x = maxX;
			data.range.y = maxY;
			data.pool = new Array();
			
			for ( var s : String in  poolMap ) {
				var poolElem : Object = new Object();
				poolElem.type = s;
				poolElem.count = poolMap[s];
				data.pool.push( poolElem );
			}
			
			data.worldObjects = new Array();
			
			for each ( wo in worldObjects ) {
				var woObj : Object = new Object();
				woObj.type = wo.name;
				woObj.x = wo.x;
				woObj.y = wo.y;
				data.worldObjects.push( woObj );
			}

			return data;
		}
		
		private function generateSections( container:MovieClip ) : Array  {

			var map : Array = new Array();
			var aLabels : Array = container.currentScene.labels;
			var count : int = aLabels.length;
			
			for ( var i : int = 0; i < count; ++i ) {
				var fl : FrameLabel = aLabels[i]	
				
				if( 'Master' != fl.name ) {
					container.gotoAndStop( fl.name );
					var obj : Object = new Object();
					obj.name = fl.name;
					obj.content = generateThisSection( container ) ;
					map.push( obj );
				}				
			}
			return map;
		}
		
		
		protected function onCompleteHandler(event:Event):void
		{
			var data : Object = new Object();
			data.version = '0.1';
			data.name = _fileRootName;
			data.sections = generateSections( event.target.content );
			
			var keys : Array = new Array();
			for each( var s : Object in data.sections ) {
				keys.push( s.name );
			}
			
			data.sectionKeys = keys;
			_json = JSON.stringify( data );

			var oFile : File = File.userDirectory.resolvePath( sFileDir + '../data/levels/' + _fileRootName + '.js' );				
			oFile.browseForSave("Save the level data");
			oFile.addEventListener( Event.SELECT, onSaveSelected );
		}
		
		private function orderWorldObjects( a : WorldObject, b : WorldObject) : int {
			if( a.x < b.x ) return -1;
			if( a.x > b.x ) return 1;
			return 0;
		}
		
		protected function onSaveSelected(event:Event):void
		{
			var f:File = event.currentTarget as File;
			var fs : FileStream = new FileStream();
			fs.open( f, FileMode.WRITE );
			fs.writeUTFBytes( _json );
			fs.close();
		}
	}
}



import flash.geom.Point;
class WorldObject {

	private var _name : String;
	private var _pos : Point ;
	
	public function WorldObject ( name : String, x : Number, y : Number ) : void {		
		_name = name;
		_pos = new Point(x,y);
	}

	public function get x() : Number 			{ return _pos.x; }
	public function get y() : Number 			{ return _pos.y; }
	public function get name() : String 		{ return _name; } 
}