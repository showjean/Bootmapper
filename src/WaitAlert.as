package
{
    import spark.components.Alert;

    public class WaitAlert
    {
        
        private static var _instance:WaitAlert = new WaitAlert()
        
        public function WaitAlert(){
            if (_instance){
                throw new Error("Singleton can only be accessed through Singleton.getInstance()");
            }
        }
        
        public static function getInstance():WaitAlert{
            return _instance;
        }
        
        protected var alertWaiting:Alert;
        public function showWaiting(xMsg:String, xTitle:String = ""):void{
            
            if(alertWaiting == null){
                alertWaiting = Alert.show(xMsg, xTitle, 0, null);
            }else{
                alertWaiting.title = xTitle;
                alertWaiting.message = xMsg;
            }
            
        }
        public function removeWaiting():void{
            if(alertWaiting) {
                alertWaiting.parent.removeChild(alertWaiting);
                alertWaiting = null;
            }
        }
    }
}