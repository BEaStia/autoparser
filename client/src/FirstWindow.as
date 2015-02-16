/**
 * Created by Igor on 10.02.2015.
 */
package {
import feathers.controls.Button;
import feathers.controls.Callout;
import feathers.controls.Label;
import feathers.themes.MetalWorksMobileTheme;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;

public class FirstWindow extends Sprite {
    public function FirstWindow() {
        this.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
    }

    protected var button:Button;


    protected function addedToStageHandler( event:Event ):void
    {
        new MetalWorksMobileTheme();
        this.button = new Button();
        this.button.label = "Click Me";
        this.addChild( button );
        this.button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
        this.button.validate();
        this.button.x = (this.stage.stageWidth - this.button.width) / 2;
        this.button.y = (this.stage.stageHeight - this.button.height) / 2;
        addEventListener(Event.RESIZE, screen_resizedHandler);
        stage.addEventListener(Event.RESIZE, screen_resizedHandler);
    }

    protected function button_triggeredHandler( event:Event ):void
    {
        var dm:DownloadManager = new DownloadManager();
        dm.DownloadJSON("http://localhost:4567/makers",function(result:Object):void
        {
            trace(result as Array);
            show_button();
        });
    }

    private function show_button():void {
        const label:Label = new Label();
        label.text = "Hi, I'm Feathers!\nHave a nice day.";
        Callout.show( label, this.button);
    }

    protected function screen_resizedHandler(event:ResizeEvent):void {
        this.button.x = (event.width - this.button.width) / 2;
        this.button.y = (event.height - this.button.height) / 2;
    }
}
}
