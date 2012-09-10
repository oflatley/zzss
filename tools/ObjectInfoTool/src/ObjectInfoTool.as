package
{
	import avmplus.getQualifiedClassName;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class ObjectInfoTool extends Sprite
	{
		private var _fileRootname : String;
		private var _sFileDir : String;
		private var _sInfoMap : Dictionary = new Dictionary();
		
		public function ObjectInfoTool()
		{
			var objectsFile : File = new File();
			var filter : FileFilter = new FileFilter("swf","*.swf");
			
			objectsFile.browseForOpen("Open the Master Asset File" , [filter] );
			objectsFile.addEventListener( Event.SELECT, onObjectsFileSelected );
		}
		
		protected function onObjectsFileSelected(event:Event):void
		{
			var s : String = event.target.name as String;
			_fileRootname = s.split( /\./ )[0];
			var firstChar : String = _fileRootname.substr(0,1);
			var restOfStr : String = _fileRootname.substr(1,_fileRootname.length);
			_fileRootname = firstChar.toUpperCase() + restOfStr;
			_sFileDir = event.target.parent.nativePath;
			
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
			var url:URLRequest = new URLRequest( event.target.url );
			loader.load(url);			
		}
		
		protected function onCompleteHandler(event:Event):void
		{			
			var container:DisplayObjectContainer = event.target.content;
			
			for( var j : int = 0 ; j < container.numChildren; ++j ) {
				
				var mc : MovieClip = container.getChildAt(j) as MovieClip;

				
				if( mc ) {
					var s : String = getQualifiedClassName( mc );
					trace( s );
					if ( s != 'flash.display::MovieClip' ) {
						var o : Object = new Object;
						o.w = mc.width;
						o.h = mc.height;
						_sInfoMap[s] = o;
					}
				}
			}
			
			var oFile : File = File.userDirectory.resolvePath( _sFileDir + '../data/objectInfo.js' );
			oFile.browseForSave("Save the Object Info ...");
			oFile.addEventListener( Event.SELECT, onOutfileSelect );
		}
		
		protected function onOutfileSelect(event:Event):void
		{
			var f:File = event.currentTarget as File;
			var fs : FileStream = new FileStream();
			fs.open( f, FileMode.WRITE );
			
			var json : Object = new Object();
			json.version = '0.1';
			json.objectInfo = new Array();

			for ( var s : String in _sInfoMap ) {
				var o : Object = new Object();
				o.type = s;
				o.info = _sInfoMap[s];
				json.objectInfo.push(o);
			}
			
			var xml :String = JSON.stringify( json );
			fs.writeUTFBytes( xml );
			fs.close();
		}
	}
}
