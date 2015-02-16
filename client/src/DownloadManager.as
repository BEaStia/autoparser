/**
 * Created by Igor on 15.02.2015.
 */
package {
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;

public class DownloadManager {
    private var _cb:Function = null;
    public function DownloadManager() {

    }

    public function DownloadJSON(url:String, cb:Function = null):void {
        var urlRequest:URLRequest  = new URLRequest(url);
        _cb = cb;
        var urlLoader:URLLoader = new URLLoader();
        urlLoader.addEventListener(Event.COMPLETE, completeHandler);

        try{
            urlLoader.load(urlRequest);
        } catch (error:Error) {
            trace("Cannot load : " + error.message);
        }
    }

    private function completeHandler(event:flash.events.Event) : void {
        var loader:URLLoader = URLLoader(event.target);
        trace("completeHandler: " + loader.data);

        var data:Object = JSON.parse(loader.data);
        if (_cb)
            _cb(data);
    }
}
}
