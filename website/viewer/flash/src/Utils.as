package
{
	public class Utils
	{
		public function Utils()
		{
		}
		
		public static function logError( message:String ):void
		{
			// TODO: logging dependent on environment
			
			trace( "[ERROR]:", message );
		}
	}
}