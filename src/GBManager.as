package
{
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.system.Capabilities;
    
    import mx.controls.Alert;

    
    public class GBManager
    {
        private var process:NativeProcess;
        private var nativeProcessStartupInfo:NativeProcessStartupInfo;
//        private var nextProcessIndex:int;
        private var __listener:Function;
        
        private static var _instance:GBManager = new GBManager()
        
        public function GBManager(){
            if (_instance){
                throw new Error("Singleton can only be accessed through Singleton.getInstance()");
            }
            __init();
        }
        
        public static function getInstance():GBManager{
            return _instance;
        }
        
        protected function __init():void{
            
            nativeProcessStartupInfo = new NativeProcessStartupInfo();
            var file:File;
			if(Capabilities.os.toUpperCase().indexOf("MAC") > -1){
				file = File.applicationDirectory.resolvePath("./bin/gbmgr");
			}else{
				file = File.applicationDirectory.resolvePath("bin/gbmgr.exe");
			}
            nativeProcessStartupInfo.executable = file;
            
            process = new NativeProcess();
            process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
            process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
            process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
            process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onInputProgress);
            process.addEventListener(Event.STANDARD_INPUT_CLOSE, onInputClose);
            process.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onIOError);
            process.addEventListener(NativeProcessExitEvent.EXIT, onExit);
            process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
        }
        
        protected function onInputClose(event:Event):void
        {
            try{					
                trace("onInputClose"); 
            }catch(e:Error){
                Alert.show("input : " + e.message);
            }
        }
        
        
        protected function onInputProgress(event:ProgressEvent):void
        {
            trace("input progress: ", process.standardOutput.bytesAvailable); 
            
        }
        public function onOutputData(event:ProgressEvent):void
        {
            try{
                var gStr:String = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
                __print(gStr);
            }catch(e:Error){
                Alert.show("onOutputData : " + e.message);					
            }
        }
        
        public function onErrorData(event:ProgressEvent):void
        {
            try{
                var gStr:String = process.standardError.readUTFBytes(process.standardError.bytesAvailable);
                //                    trace("ERROR -", gStr); 
                __print(gStr);
            }catch(e:Error){
                Alert.show("onErrorData : " + e.message);
                
            }
        }
        
        public function onExit(event:NativeProcessExitEvent):void
        {
            trace("Process exited with ", event.exitCode);    
            
            __runNextProcess();
        }
        
        public function onIOError(event:IOErrorEvent):void
        {
            trace(event.toString());
            //                __print(event.toString());
        }   
        /*
        *    
        */            
        public function writeFlash(xHexStr:String, xListener:Function = null, xReboot:Boolean = false):void 
        {
            
            var processArgs:Vector.<String> = new Vector.<String>();
            processArgs.push("-bootloader");
            processArgs.push("ignore");
                        
            var processArgs2:Vector.<String> = new Vector.<String>();
            processArgs2.push("-firm");
            if(xReboot) processArgs2.push("-r");
			if(Capabilities.os.toUpperCase().indexOf("MAC") > -1){
//				trace(File.documentsDirectory.nativePath);
            	processArgs2.push(File.documentsDirectory.nativePath + "/");
			}
            processArgs2.push(xHexStr);
//            trace(xHexStr);
            
            runRelayProecss(new <Vector.<String>>[processArgs, processArgs2], xListener);
                        
        }
        public function downloadKeymap(xInfo:HexInfoKeymap, xListener:Function = null):void 
        {
            
            var processArgs:Vector.<String> = new Vector.<String>();
            processArgs.push("-ready");
            
            var processArgs2:Vector.<String> = new Vector.<String>();
            processArgs2.push("-keymap");
//            processArgs2.push(String(xInfo.layers));
//            processArgs2.push(String(xInfo.columns));
//            processArgs2.push(String(xInfo.rows));
            
            var processArgs3:Vector.<String> = new Vector.<String>();
            processArgs3.push("-action");            
            
            
            runRelayProecss(new <Vector.<String>>[processArgs, processArgs2, processArgs3], xListener);
            
        }
        public function downloadMacro(xInfo:HexInfoMacro, xListener:Function = null):void 
        {
            
            var processArgs:Vector.<String> = new Vector.<String>();
            processArgs.push("-ready");
            
            var processArgs2:Vector.<String> = new Vector.<String>();
            processArgs2.push("-macro");
//            processArgs2.push(String(xInfo.macroNum));
//            processArgs2.push(String(xInfo.macroLength));
            
            var processArgs3:Vector.<String> = new Vector.<String>();
            processArgs3.push("-action");            
            
            
            runRelayProecss(new <Vector.<String>>[processArgs, processArgs2, processArgs3], xListener);
            
        }
        protected var runVec:Vector.<Vector.<String>>;
        public function runRelayProecss(xVec:Vector.<Vector.<String>>, xListener:Function = null):void{
            runVec = xVec;
            __listener = xListener;
            
            __runNextProcess();
            
        }
        protected function hasNextProcess():Boolean{
            return runVec && runVec.length > 0;
        }
        protected function __clearNextProcess():void{
            runVec = null;
        }
        protected function __runNextProcess():void{
            if(!hasNextProcess()){
                return;
            }
            
            runProcess(runVec.shift(), __listener);
        }
        
        public function runProcess(xVec:Vector.<String>, xListener:Function = null):void{
            
            __listener = xListener;
            
            nativeProcessStartupInfo.arguments = xVec;
            
//            trace(this, xVec);
            
            if(!process.running) 
            { 					
                process.start(nativeProcessStartupInfo);                    
            }
        }
        
        
        //            private var dataString:String = "";
        protected function __print (xStr:String):void {
                      
            var gArr:Array;
            //                if(dataString.length > 0){
            //                    str = dataString + str;
            //                    dataString = "";
            //                }
            //                
            //                gArr = str.split("\n");
            //                var gLastLine:String = gArr.pop();
            //                trace(this.name, "last line : ", gLastLine);
            //                
            //                if(gLastLine.search(/}(?:[^\}])/gm) == -1){
            //                    dataString = gLastLine;		
            //                    str = gArr.join("\n");
            //                    trace(this.name, "line saved...");
            //                    //				Alert.show(gLastLine);
            //                }
            
            var gReg:RegExp = new RegExp("\{.+?\}", "gm");
            gArr = xStr.match(gReg);
            var gLen:int = gArr.length;
//            trace(this, "gLengh : ", gLen);
            var i:int;
            var gStr:String;
            for(i = 0;i< gLen;++i){
//                trace(this, i, gArr[i]);
                gStr = gArr[i];
                
                var gObj:Object = JSON.parse(gStr);
                var gSuc:int = gObj.success;
                
                if(__listener != null) __listener(gSuc, gStr);
                
                if(gSuc > 0){  // complete                    
                }else if(gSuc == 0){
                    __clearNextProcess();
                }
            }
            
        }
        
    }
}