package {

import flash.display.Sprite;
import flash.text.TextField;

import starling.core.Starling;

public class Main extends Sprite {
    var starling:Starling;
    public function Main() {
        starling = new Starling(FirstWindow, stage);
        starling.start();
    }
}
}
