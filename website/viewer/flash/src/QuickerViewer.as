package
{
	import com.adobe.serialization.json.JSON;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class QuickerViewer extends Sprite
	{
		
		/**
		 * 
		 */
		
		private var reportLoader:URLLoader;
		private var report:Report;
		
		
		/**
		 * Constructor
		 */
		
		public function QuickerViewer()
		{
			var reportLocation:String = "http://localhost/out.js";
			
			// Initial setup
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// load JSON
			this.reportLoader = new URLLoader();
			this.reportLoader.addEventListener(Event.COMPLETE, onLoadComplete );
			this.reportLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError );
			this.reportLoader.dataFormat = URLLoaderDataFormat.TEXT;
			this.reportLoader.load(new URLRequest( reportLocation ));
		}
		
		
		/**
		 * Init
		 */
		
		private function onAddedToStage(event:Event):void
		{
			this.stage.quality = StageQuality.HIGH;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.frameRate = 60;
		}
		
		
		/**
		 * Load Handlers
		 */
		
		private function onLoadError( e:Event ):void {}
		
		private function onLoadComplete( e:Event ):void
		{
			report = new Report(JSON.decode(reportLoader.data));
			
			// Render chart
			drawBackground();
			
			// Assets
			for each (var asset:Object in report.assets)
			{
				drawAssetBar( asset );
			}
			
			var numEvents:int = report.pageEvents.length;
			
			// Events
			for each (var pageEvent:Object in report.pageEvents)
			{
				drawPageEvent( pageEvent );
			}
			
			// Summary
			writeSummary();
		}
		
		
		/**
		 * Charting
		 */
		
		private const BAR_HEIGHT:int = 7;
		private const BAR_MARGIN_BOTTOM:int = 5;
		
		private const MARGIN_TOP:int = 45;
		private const MARGIN_LEFT:int = 5;
		private const MARGIN_RIGHT:int = 5;
		private const MARGIN_BOTTOM:int = 15;
		
		private const COLORS:Array = [0x7B99FF];
//		private const COLORS:Array = [0x2E4AB6, 0x376CFF, 0x4E78F7, 0x588AFF, 0x7B99FF];
//		private const COLORS:Array = [0x2E4AB6, 0x8EACFF, 0x376CFF, 0x8EACFF, 0x4E78F7, 0x8EACFF, 0x588AFF, 0x8EACFF, 0x7B99FF, 0x8EACFF ];
		
		// Derivitive
		private const MARGIN_HORIZONTAL:int = MARGIN_LEFT + MARGIN_RIGHT;
		private const MARGIN_VERTICAL:int = MARGIN_TOP + MARGIN_BOTTOM;
		
		// State
		private var yOffset:int = MARGIN_TOP;
		private var rowCount:int = 0;
		private var colorIndex:int = 0;
		
		// Workers
		private function drawBackground():void
		{
			this.graphics.beginFill( 0x0, 0.0 );
			this.graphics.drawRect( 0, 0, this.stage.stageWidth, this.stage.stageHeight );
			this.graphics.endFill();
		}
		
		private function writeSummary():void
		{
			// Some basic descriptive text
			
			var textField:TextField = new TextField();
			
			textField.width = this.stage.stageWidth - MARGIN_HORIZONTAL;
			textField.x = MARGIN_LEFT;
			textField.y = this.stage.stageHeight - 12;
			
			textField.text = "total time: " + (report.totalTime/1000).toString() + "s          Num events: " +
								report.pageEvents.length.toString() + "          Num assets: " + report.assets.length.toString();
			textField.selectable = false;
			
			textField.setTextFormat(new TextFormat( "_sans", 10, 0x0, false ));
			
			this.addChild( textField );
		}
		
		private function drawAssetBar( asset:Object ):void
		{
			var reportStartTime:Number = report.startTime;
			
			// Relative offsets
			var startPos:Number = asset.startTime - report.startTime;
			var endPos:Number = asset.endTime - report.startTime;
			
			var totalTime:Number = report.endTime - report.startTime;
			
			// Total time represents the width of the stage
			var assetWidth:int = ((endPos - startPos)/totalTime) * (this.stage.stageWidth - 1);
			var assetOffset:int = (startPos/totalTime) * (this.stage.stageWidth - 1);
			
			this.graphics.beginFill( COLORS[colorIndex], 1 );
			this.graphics.drawRect( assetOffset, yOffset, assetWidth, BAR_HEIGHT );
			this.graphics.endFill();
			
			// Add Label
			var textField:TextField = new TextField();
			
			textField.x = Math.min( this.stage.stageWidth - 150, assetOffset + 3 );
			textField.y = yOffset + 5;
			textField.width = this.stage.stageWidth;
			textField.text = (asset.index+1).toString() + ". " + asset.href;
			textField.selectable = false;
			textField.setTextFormat(new TextFormat( "_sans", 10, 0x0, false ));
			
			this.addChild( textField );
			
			// Increment state
			rowCount++;
			yOffset += BAR_HEIGHT + BAR_MARGIN_BOTTOM;
			colorIndex = (rowCount) % COLORS.length; // loop over colors
		}
		
		private var eventLabelOffset:int = MARGIN_TOP;	// tmp!
		private function drawPageEvent( pageEvent:Object ):void
		{
			var relativeTime:Number = pageEvent.data.time - report.startTime;
			var eventOffset:int = (relativeTime/report.totalTime) * (this.stage.stageWidth - 1);	// Do not exceed stageWidth
			
			this.graphics.lineStyle( 0, 0xFF0000, .2, false );
			this.graphics.moveTo( eventOffset, MARGIN_TOP );
			this.graphics.lineTo( eventOffset, this.stage.stageHeight - MARGIN_BOTTOM );
			
			// Add label above event
			var textField:TextField = new TextField();
			
			textField.x = eventOffset - 10;
			textField.y = eventLabelOffset;
			textField.selectable = false;
			
			switch ( pageEvent.type )
			{
				case "MozAfterPaint":
					textField.text = "P";
					break;
				case "DomContentLoaded":
					textField.text = "D";
					break;
				case "Load":
					textField.text = "L";
					break;
				default:
					textField.text = "U";
					break;
			}
			
			eventLabelOffset = Math.min( this.stage.stageHeight - MARGIN_BOTTOM - 13, eventLabelOffset + 10 );
			
			textField.setTextFormat(new TextFormat( "_sans", 10, 0x0, false ));
			
			this.addChild( textField );
		}
		
		
	}
}