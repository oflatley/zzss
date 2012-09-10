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
	
	public class CollisionDataGenerator extends Sprite
	{
		private var fileData:String;
		
		private var classNames : Array = new Array();
		private var loader:Loader;
		private var fileRootName:String;
		private var sFileDir:String;		
		private var sCollisionData : String ;
		private var sPackageSection : String; 
		private var classSection:Vector.<String> = new Vector.<String>();;
		private var worldObjectCollisionData : Vector.<WorldObjectCollisionData> = new Vector.<WorldObjectCollisionData>();
		
		public function CollisionDataGenerator() {
			
			var levelFile : File = new File();
			var filter : FileFilter = new FileFilter("swf","*.swf");
			
			levelFile.browseForOpen("Open the File of Collision Objects" , [filter] );
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
		
		private static const s0 : String = "\n\tpublic class ";
		private static const s1 : String = " extends CollisionData_Base {\n\t\tpublic function ";
		private static const s2 : String = "\n\t\t\t_data = "; 		
		private static const s3 : String = "\n\t\t\t_width = "
		private static const s4 : String = "\n\t\t\t_height = "
		private static const sTail : String = '];\n\t\t}\n\t}\n}';

		private static const sA : String = 'package data.collisionObj {\n\timport collision.CollisionData_Base'
		
		
		private static const sBaseClass : String = 
			"\n\nimport flash.geom.Point;\nimport interfaces.ICollisionData;"+
			"\n\nclass CollisionDataBase implements ICollisionData {" +  
			"\n\tprotected var _data:Array;" +
			"\n\tprotected var _width:int;" +
			"\n\tprotected var _height:int;" +  			
			"\n\tpublic function get data() : Array { return _data; }" +  
			"\n\tpublic function testPoint(p:Point) : Boolean { return testxy( p.x, p.y ); }" + 
			"\n\tpublic function testxy( x : int, y:int ) : Boolean { return _data[y*_width + x];}\n}";	
			
		
		
		private function convertToBits( argbValues : Array ) : Array {
			
			var nArrayLen : int = argbValues.length;
			var nCount : int = nArrayLen >> 5;
			var nRemainder : int = nArrayLen & 31;
			var extraWord : int = nRemainder ? 1 : 0;
			
			var a :Array = new Array();
			var adx : int = 0;
			var bits32 : uint = 0;
			
			for( var dx : int = 0 ; dx < nCount; ++dx ) {
				
				bits32 = 0;
				for( var dx2 : int = 0; dx2 < 32; ++dx2 ) {
					var val : int = argbValues[adx++];
					var bit : uint = val ? 0x80000000 : 0;
					bit = bit >>> dx2;
					bits32 = bits32 | bit;					
				}
				a.push(bits32);
			}

			if( nRemainder ){
				bits32 = 0;
				for( dx2 = 0; dx2 < nRemainder; ++dx2 ) {
	
					val = argbValues[adx++];
					bit = val ? 0x80000000 : 0;
					bit = bit >>> dx2;
					bits32 = bits32 | bit;					
				}
				a.push(bits32);
			}			
			
			
			return a;
		}
		
		private function buildBitArray( bmdata : BitmapData ) : Array {

			var alphaChannel : Array = new Array();
			
			var w : Number = bmdata.width;
			var h : Number = bmdata.height;
			
			
			for( var yy : int = 0 ; yy < h; ++yy ) {
				for( var xx : int = 0; xx < w; ++xx ) {		
					var argb : uint = bmdata.getPixel32(xx,yy);
					
					var alpha : uint = 0;
					if( 0xFFFFFFFF != argb ) {
						alpha = argb >>> 24;						
					}
					alphaChannel.push(alpha);
				}
			}			
			return convertToBits( alphaChannel );			
			
		}
			
		private function buildCollisionDataClass( name : String, bm : Bitmap ) : String {
			var bmdata : BitmapData = bm.bitmapData;
			var w : Number = bmdata.width;
			var h : Number = bmdata.height;
			
			classNames.push( name );
			
			var sOut : String = name + ':' + w + ',' + h + ',';
			var abits : Array = buildBitArray( bmdata );
			
			var debugCount : int = w * h;
			var debugExpected : int = (debugCount /32) + (((debugCount%32) != 0 ) ? 1 : 0 );
			
			if( debugExpected != abits.length ) { 
				trace('fishy');
			}
			
			for( var dx : int = 0; dx < abits.length; ++dx ) {
				sOut += abits[dx] + ',';
			}
			
			return sOut.substr(0,sOut.length-1);				
		}
		
		private function writeCollisionData() : void {
			sCollisionData += '\n}';
			
			var f:File = File.documentsDirectory.resolvePath("collisionData.as");
			var fs : FileStream = new FileStream();
			fs.open( f, FileMode.WRITE );
			fs.writeUTF( sCollisionData );
			fs.close();			
		}
		
		private function buildPackageSection() : String {

			var s0 : String = 'package collision\n{\n\timport data.collisionObj.*\n\timport interfaces.ICollisionData;\n\n\tpublic class CollisionDataProvider { \n\t\tprivate var map:Array = new Array();\n\t\tpublic function getCollisionData( s : String ) : ICollisionData { return map[s]; }';
			var s1 : String = '\n\n\t\tpublic function CollisionDataProvider() {';
			
			var mapElems : String = new String();
			for each( var s: String in classNames ) {
				mapElems += "\n\t\t\tmap['" + s + "'] = new " + s + '();';
			}
			
			var sOut : String = s0 + s1 + mapElems + '\n\t\t}\n\t}\n}';
			return sOut;			
			
		}
		
		
		private function createBitMap( mc : MovieClip ) : Bitmap {	
			var a:BitmapData = new BitmapData(mc.width,mc.height);
			var b:Bitmap = new Bitmap(a);
			a.draw(mc);
			return b;
		}
		
		protected function onCompleteHandler(event:Event):void
		{
		
			
			var container:DisplayObjectContainer = event.target.content;
			
			for( var j : int = 0 ; j < container.numChildren; ++j ) {
				
				var o : Object = container.getChildAt(j);
				
//				if( o as Bitmap ) { 
//					classSection.push( buildCollisionDataClass( o as Bitmap ) + '\n' );					
//				}
				
				if( o as MovieClip ) {
					var mc : MovieClip  = o as MovieClip;		
					var s : String = getQualifiedClassName( mc );
					trace( s );
					if ( s != 'flash.display::MovieClip' ) {
						var bm : Bitmap = createBitMap(mc);
						classSection.push( buildCollisionDataClass(s,bm) );	
						worldObjectCollisionData.push( new WorldObjectCollisionData(s,bm) );
					}
				}
			}
			
			var oFile : File = File.userDirectory.resolvePath( sFileDir + '../data/collisionObj/collisionData.js' );
			oFile.browseForSave("Save the Collision Data");
			oFile.addEventListener( Event.SELECT, onSaveCollisionData );
			
			
	/*			
			sPackageSection = buildPackageSection();
			
			var oFile : File = File.userDirectory.resolvePath( sFileDir + '../collision/CollisionDataProvider.as' );
			oFile.browseForSave("Save the Provider class");
			oFile.addEventListener( Event.SELECT, onSaveSelected );
*/	
		}
		
		protected function onSaveCollisionData(event:Event):void
		{
			var f:File = event.currentTarget as File;
			var fs : FileStream = new FileStream();
			fs.open( f, FileMode.WRITE );
	
//			for ( var i : int = 0; i < classSection.length; ++i ) {
//				fs.writeUTFBytes( classSection[i] + '\n' );
//			}
	
			var json : Object = new Object();
			json.worldObjects = new Array();
			for each( var wocd : WorldObjectCollisionData in worldObjectCollisionData ) {			
				json.worldObjects.push( wocd.asJSON() );
			}
			json.version = '0.1';
			
			var s :String = JSON.stringify( json );
			fs.writeUTFBytes( s );
			fs.close();
			
		}
		
		protected function onSaveSelected(event:Event):void
		{
//			var f:File = event.currentTarget as File;
//			var fs : FileStream = new FileStream();
//			fs.open( f, FileMode.WRITE );
//			fs.writeUTFBytes( sPackageSection );
//			fs.close();
			
			
			var oFile : File = File.userDirectory.resolvePath( sFileDir + '../data/collisionObj' );
			oFile.browseForDirectory( 'folder for object collision data' );
			oFile.addEventListener( Event.SELECT, onDirSelected );
		}
		
		private function onDirSelected( event:Event ) : void {
		
			var s:String = event.currentTarget.nativePath as String;
			s += File.separator;
			var fs : FileStream = new FileStream();
			
			
			for( var i : int = 0; i < classNames.length; ++i ) {
				
				var sFilename : String = s + classNames[i] + '.as';
				
				var oFile : File = new File( sFilename );
				fs.open( oFile, FileMode.WRITE );
				fs.writeUTFBytes( classSection[i] );
				fs.close();
			}

		}	
	}
}
import flash.display.Bitmap;
import flash.display.BitmapData;


class WorldObjectCollisionData {
	private var _width : Number;
	private var _height : Number;
	private var _name : String; 
	private var _collisionBits : Array;
	
	public function WorldObjectCollisionData( name : String, bm : Bitmap ) : void {
		_name = name;
		_width = bm.width;
		_height = bm.height; 
		
		_collisionBits = buildCollisionBitVector( bm.bitmapData );
		
		
		var debugCount : int = _width * _height;
		var debugExpected : int = (debugCount /32) + (((debugCount%32) != 0 ) ? 1 : 0 );		
		if( debugExpected != _collisionBits.length ) { 
			trace('fishy');
		}
	}
	
	public function asJSON() : Object {
		var js : Object = new Object();
		js.collisionBits = _collisionBits;
		js.dims = new Object();
		js.dims.h = _height;
		js.dims.w = _width;
		js.name = _name;
		
		return js;
	}
	
	private function buildCollisionBitVector( bmd : BitmapData ) : Array {
		var alphaChannel : Array = new Array();
		
		var w : Number = _width;
		var h : Number = _height;
		
		
		for( var yy : int = 0 ; yy < h; ++yy ) {
			for( var xx : int = 0; xx < w; ++xx ) {		
				var argb : uint = bmd.getPixel32(xx,yy);
				
				var alpha : uint = 0;
				if( 0xFFFFFFFF != argb ) {
					alpha = argb >>> 24;						
				}
				alphaChannel.push(alpha);
			}
		}			
		return convertToBits( alphaChannel );	
	}

	private function convertToBits( argbValues : Array ) : Array {
		var nArrayLen : int = argbValues.length;
		var nCount : int = nArrayLen >> 5;
		var nRemainder : int = nArrayLen & 31;
		var extraWord : int = nRemainder ? 1 : 0;
		
		var a : Array = new Array();
		var adx : int = 0;
		var bits32 : uint = 0;
		
		for( var dx : int = 0 ; dx < nCount; ++dx ) {
			
			bits32 = 0;
			for( var dx2 : int = 0; dx2 < 32; ++dx2 ) {
				var val : int = argbValues[adx++];
				var bit : uint = val ? 0x80000000 : 0;
				bit = bit >>> dx2;
				bits32 = bits32 | bit;					
			}
			a.push(bits32);
		}
		
		if( nRemainder ){
			bits32 = 0;
			for( dx2 = 0; dx2 < nRemainder; ++dx2 ) {
				
				val = argbValues[adx++];
				bit = val ? 0x80000000 : 0;
				bit = bit >>> dx2;
				bits32 = bits32 | bit;					
			}
			a.push(bits32);
		}			
		
		
		return a;
	}

}