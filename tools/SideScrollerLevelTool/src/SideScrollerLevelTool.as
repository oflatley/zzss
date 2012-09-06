package
{
	import avmplus.getQualifiedClassName;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
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
		private var fileRootName:String;

		private var sOutput:String;
		private var sFileDir:String;
		
		private var _xml : String;
		
		private var sCollisionData : String = 'package CollisionData {';
		
		public function SideScrollerLevelTool() {
			
			var levelFile : File = new File();
			var filter : FileFilter = new FileFilter("swf","*.swf");
			
			levelFile.browseForOpen("Open the Level File" , [filter] );
			levelFile.addEventListener( Event.SELECT, onLevelFileSelected );
		
		}
		
		protected function onLevelFileSelected(event:Event):void
		{
			var s : String = event.target.name as String;
			fileRootName = s.split( /\./ )[0];
			var firstChar : String = fileRootName.substr(0,1);
			var restOfStr : String = fileRootName.substr(1,fileRootName.length);
			fileRootName = firstChar.toUpperCase() + restOfStr;
			
			
			sFileDir = event.target.parent.nativePath;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
			var url:URLRequest = new URLRequest( event.target.url );
			loader.load(url);
		}
		
		
		protected function onCompleteHandler(event:Event):void
		{
			addChild( event.target.content as MovieClip );
			var container:DisplayObjectContainer = event.target.content;
			
			for( var j : int = 0 ; j < container.numChildren; ++j ) {
				var o : Object = container.getChildAt(j);
				trace( o.name + ' ' + getQualifiedClassName(o) );
			
//				if( o as Bitmap ) { 
//					buildCollisionData( o as Bitmap );
					
	//			}
	//			else 
				if ( o as MovieClip ) {
					var parentMC : MovieClip = container.getChildAt(j) as MovieClip;
				}
			}
//			writeCollisionData();
			
			
			var maxX : Number = -Infinity;
			var maxY : Number = -Infinity; 
			for( var i : int = 0 ; i < parentMC.numChildren; ++i ) {
				var mc:DisplayObject = parentMC.getChildAt(i);
				var name:String = getQualifiedClassName(mc);
				
				trace(name + ' ' + mc.x + ' ' + mc.y);

				if( mc.y <= 640 && name != "flash.display::Shape" ) {
					_worldObjects.push( new WorldObject( name, mc.x, mc.y ) ); 
					maxX = Math.max( maxX, mc.x + mc.width );
					maxY = Math.max( maxY, mc.y + mc.height);
				}
			}
			
	
			sOutput = new String();
			sOutput = "package data.level {\n\timport interfaces.ILevelData;\n\tpublic class " + fileRootName + ' implements ILevelData {\n\t\tpublic function get data() : Array { return _data; }\n\t\tprivate static const _data : Array = [';
			
			
			for each( var wo : WorldObject in _worldObjects ) {
				trace( wo.name + ' ' + wo.x + ' ' + wo.y );
				sOutput += '\n\t\t\t{ type: "' + wo.name + '",\t\t\t\t\tx: ' + Math.floor(wo.x) + ',\t\t\t\ty: ' + Math.floor(wo.y) + '},' 
			}
			sOutput += '\n\t\t];\n\t}\n}';
		
			var oFile : File = File.userDirectory.resolvePath( sFileDir + '../data/levels/' + fileRootName + '.as' );
				
			oFile.browseForSave("Save the level data");
			oFile.addEventListener( Event.SELECT, onSaveSelected );
			
			
			// sort by increasing x
			_worldObjects.sort( orderWorldObjects );
			var poolMap : Array = new Array();
			
			for each( wo in _worldObjects ) {
				if( poolMap[wo.name] ) {
					poolMap[wo.name]++
				} else {
					poolMap[wo.name] = 1;
				}
			}
			
			var json : Object = new Object();
			json.version = 0.1;
			json.name = fileRootName;
			json.spans = new Object();
			json.spans.x = maxX;
			json.spans.y = maxY;
			json.pool = new Array();
			
			for ( var s : String in  poolMap ) {
				var poolElem : Object = new Object();
				poolElem.type = s;
				poolElem.count = poolMap[s];
				json.pool.push( poolElem );
			}
			
			json.worldObjects = new Array();
			
			for each ( wo in _worldObjects ) {
				var woObj : Object = new Object();
				woObj.type = wo.name;
				woObj.x = wo.x;
				woObj.y = wo.y;
				json.worldObjects.push( woObj );
			}
				
			_xml = JSON.stringify( json );
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
		//	fs.writeUTFBytes( sOutput );
			fs.writeUTFBytes( '\n\n\n' );
			fs.writeUTFBytes( _xml );
			
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

/*
private static const s0 : String = "\n\tpublic class ";
private static const s1 : String = " implements ICollisionData {";
private static const s2 : String = "\n\t\tprivate var _data:Vector.<uint> = new uint"; 		
private static const s3 : String = "\n\t\tprivate var _width:int="
private static const s4 : String = "\n\t\tprivate var _height:int="

private function buildCollisionData( bm : Bitmap ) : void {

var bmdata : BitmapData = bm.bitmapData;
var w : Number = bmdata.width;
var h : Number = bmdata.height;
var name : String = getQualifiedClassName( bmdata );

var sOut : String  = s0 + name + s1 + s3 + w + ';' + s4 + h + ';' + s2 + '[';

for( var yy : int = 0 ; yy < h; ++yy ) {
for( var xx : int = 0; xx < w; ++xx ) {

var argb : uint = bmdata.getPixel32(xx,yy) >>> 24;
sOut += argb + ',';					
}
}

sOut += '];\n\t}';
sCollisionData += sOut;

}

private function writeCollisionData() : void {
sCollisionData += '\n}';

var f:File = File.documentsDirectory.resolvePath("collisionData.as");
var fs : FileStream = new FileStream();
fs.open( f, FileMode.WRITE );
fs.writeUTFBytes( sCollisionData );
fs.close();

}
*/