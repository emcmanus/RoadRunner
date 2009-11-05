package
{
	/*	
	 *	Report.as
	 *
	 *	@author Ed McManus
	 *	
	 *	@description Report data with some helper methods
	 *
	 */
	
	public class Report
	{
		private var report:Object;
		
		
		/**
		 * Constructor
		 */
		public function Report( report:Object )
		{
			this.report = report;
		}
		
		
		/**
		 * Report Objects
		 */
		
		public function get assets():Array
		{
			if ( isValid )
			{
				return report.assets;
			}
			else
			{
				return new Array;
			}
		}
		
		public function get pageEvents():Array
		{
			if ( isValid )
			{
				return report.pageEvents;
			}
			else
			{
				return new Array;
			}
		}
		
		
		/**
		 * Time API
		 */
		
		private var _startTime:Number = -1;	// Memoize
		public function get startTime():Number
		{
			if ( _startTime > -1 )
			{
				return _startTime;
			}
			
			// Iterate over both assets and events
			for each ( var asset:Object in report.assets )
			{
				if ( _startTime < 0 || (asset.startTime < _startTime && asset.startTime > 0) )
				{
					_startTime = asset.startTime;
				}
			}
			
			for each ( var pageEvent:Object in report.pageEvents )
			{
				if ( _startTime < 0 || pageEvent.data.time < _startTime && pageEvent.data.time > 0 )
				{
					_startTime = pageEvent.data.time;
				}
			}
			
			return _startTime;
		}
		
		// End time
		
		private var _endTime:Number = -1;	// Memoize
		public function get endTime():Number
		{
			if ( _endTime > -1 )
			{
				return _endTime;
			}
			
			// Iterate over both assets and events
			for each ( var asset:Object in report.assets )
			{
				if ( _endTime < 0 || asset.endTime > _endTime )
				{
					_endTime = asset.endTime;
				}
			}
			
			for each ( var pageEvent:Object in report.pageEvents )
			{
				if ( _endTime < 0 || pageEvent.data.time > _endTime )
				{
					_endTime = pageEvent.data.time;
				}
			}
			
			return _endTime;
		}
		
		public function get totalTime():Number
		{
			return endTime - startTime;
		}
		
		
		/**
		 * Validators
		 */
		
		private var _validityChecked:Boolean = false;
		private var _isValid:Boolean = false;
		
		private function get isValid():Boolean
		{
			if ( !_validityChecked )
			{
				_validityChecked = true;
				validateReport();
			}
			return _isValid;
		}
		
		private function set isValid( valid:Boolean ):void
		{
			_isValid = valid;
		}
		
		private function validateReport():void
		{
			var isValid:Boolean = true;
			
			if ( report.hasOwnProperty("assets") && report.hasOwnProperty("pageEvents") && report.hasOwnProperty("success") )
			{
				if ( report.success != true )
				{
					Utils.logError("There was an error during the logging process.");
					isValid = false;
				}
				else if ( report.pageEvents.length == 0 || report.assets.length == 0 )
				{
					Utils.logError("Assets or pageEvents length is 0.");
					isValid = false;
				}
				else if ( !validatePageEvent(report.pageEvents[0]) )
				{
					Utils.logError("Invalid page event.");
					isValid = false;
				}
				else if ( !validateAsset(report.assets[0]) )
				{
					Utils.logError("Invalid asset");
					isValid = false;
				}
			}
			else
			{
				Utils.logError("Malformed report object.");
				isValid = false;
			}
			
			this.isValid = isValid;
		}
		
		private function validatePageEvent( pageEvent:Object ):Boolean
		{
			return ( 
				pageEvent.hasOwnProperty("data") && 
				pageEvent.data.hasOwnProperty("time"));
		}
		
		private function validateAsset( asset:Object ):Boolean
		{
			return (
				asset.hasOwnProperty( "href" ) &&
				asset.hasOwnProperty( "index" ) &&
				asset.hasOwnProperty( "startTime" ) &&
				asset.hasOwnProperty( "endTime" ));
		}
	}
}