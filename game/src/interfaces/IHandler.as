package interfaces
{
	public interface IHandler {
		function init( args: Object, type : String, classSpecName : String ) : void ;
		function registerEvent( classFilter : Class, type : String, listener : Function ) : void;
	}
}


