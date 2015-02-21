/**
 * Created by Igor on 10.02.2015.
 */
package {
import feathers.controls.Button;
import feathers.controls.Callout;
import feathers.controls.Label;
import feathers.controls.List;
import feathers.controls.ScrollContainer;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
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
            button.removeEventListener(Event.TRIGGERED,button_triggeredHandler);
            removeChild(button);
            var container:ScrollContainer = new ScrollContainer();
            var layout:HorizontalLayout = new HorizontalLayout();
            layout.gap = 20;
            layout.padding = 20;
            container.layout = layout;
            addChild(container);

            var list:List = new List();
            list.width = 300;
            list.height = 500;
            list.
            list.dataProvider = new ListCollection(result as Array);
            list.itemRendererFactory = function():IListItemRenderer
            {
                var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
                renderer.labelField = "maker";
                return renderer;
            };
            list.addEventListener( Event.CHANGE, list_changeHandler );
            container.addChild( list );
        });
    }

    private function list_changeHandler(event:Event):void {
        trace(event);
    }

    private function show_button():void {
//        const label:Label = new Label();
//        label.text = "Hi, I'm Feathers!\nHave a nice day.";
//        Callout.show( label, this.button);
    }

    protected function screen_resizedHandler(event:ResizeEvent):void {
        this.button.x = (event.width - this.button.width) / 2;
        this.button.y = (event.height - this.button.height) / 2;
    }
}
}
