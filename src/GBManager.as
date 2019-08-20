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
        public static const SUCCESS_INDEX_ERROR:uint =  0;
        public static const SUCCESS_INDEX_COMPLETED:uint =  1;
        public static const SUCCESS_INDEX_WARNING:uint =  2;
        public static const SUCCESS_INDEX_LED2_INFO:uint =  3;
        public static const SUCCESS_INDEX_DEVICE_READY:uint =  4;
        public static const SUCCESS_INDEX_DEVICE_ACTION:uint =  5;
        public static const SUCCESS_INDEX_BOOTMAPPER_START:uint =  6;
        public static const SUCCESS_INDEX_BOOTMAPPER_STOP:uint =  7;
        public static const SUCCESS_INDEX_KEYMAP_DOWNLOAD:uint =  8;
        public static const SUCCESS_INDEX_MACRO_DOWNLOAD:uint =  9;
        public static const SUCCESS_INDEX_DUALACTION_DOWNLOAD:uint =  10;
        public static const SUCCESS_INDEX_QUICK_MACRO_DOWNLOAD:uint =  11;
        public static const SUCCESS_INDEX_QUICK_MACRO_DOWNLOAD_WITH_EXTRA:uint =  1011;
        public static const SUCCESS_INDEX_QUICK_MACRO_EXTRA_DOWNLOAD:uint =  12;

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
		
		public function close():void
		{
			if(process.running)
			{
				process.exit(true);
			}
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
            
            runRelayProecss([processArgs, processArgs2], xListener);
                        
        }
		
		public function uploadQuickMacro(xData:String, xListener:Function = null):void
		{
			var processArgs2:Vector.<String> = new Vector.<String>();
			processArgs2.push("-uqmacro");
			processArgs2.push(xData);
			
			runRelayProecss([new <String>["-ready"], processArgs2, new <String>["-action"]], xListener);
		}
		
        public function downloadKeymap(xInfo:HexInfoKeymap, xListener:Function = null):void 
        {
            var processArgs2:Vector.<String> = new Vector.<String>();
            processArgs2.push("-keymap");
			if(xInfo.rows == 17)
			{
            	processArgs2.push("row17");
			}else if(xInfo.rows == 18)
			{
				processArgs2.push("row18");
			}
//            processArgs2.push(String(xInfo.layers));
//            processArgs2.push(String(xInfo.columns));
//            processArgs2.push(String(xInfo.rows));
            
			runRelayProecss([new <String>["-ready"], processArgs2, new <String>["-action"]], xListener);
            
        }
		public function downloadMacro(xListener:Function = null):void 
		{
			
			var processArgs2:Vector.<String> = new Vector.<String>();
			processArgs2.push("-macro");
			
			runRelayProecss([new <String>["-ready"], processArgs2, new <String>["-action"]], xListener);
			
		}
		public function downloadQuickMacro(xListener:Function = null):void 
		{
			
			var processArgs2:Vector.<String> = new Vector.<String>();
			processArgs2.push("-qmacro");
			
			runRelayProecss([new <String>["-ready"], processArgs2, new <String>["-action"]], xListener);
			
		}
        
		public function downloadQuickMacroWithExtra(xListener:Function = null):void 
		{
            var result:String = "";
			runRelayProecss([new <String>["-ready"], new <String>["-qmacro"], new <String>["-qmacro-extra"], new <String>["-action"]], function (xSuc:int, xStr:String):void {
                
                var gObj:Object = JSON.parse(xStr);
                if(xSuc == GBManager.SUCCESS_INDEX_QUICK_MACRO_DOWNLOAD){
                    result = gObj.result;
                    // trace("result=> " + result);
                }
                else if(xSuc == GBManager.SUCCESS_INDEX_QUICK_MACRO_EXTRA_DOWNLOAD){
                    result += "+" + gObj.result;
                    gObj.success = SUCCESS_INDEX_QUICK_MACRO_DOWNLOAD_WITH_EXTRA;
                    gObj.result = result;
                    // trace("result2=> " + result);
                    if(null != xListener) xListener(SUCCESS_INDEX_QUICK_MACRO_DOWNLOAD_WITH_EXTRA, JSON.stringify(gObj));
                }
            });
			
		}
		
		public function downloadDualaction(xListener:Function = null):void 
		{
			runRelayProecss([new <String>["-ready"], new <String>["-dualaction"], new <String>["-action"]], xListener);
			
		}

        public function downloadVersion(xListener:Function = null):void {
			runRelayProecss([new <String>["-ready"], new <String>["-info"], new <String>["-action"]], xListener);
        }

        public function getVersionStrings(xStr:String):Array {
            var gObj:Object = JSON.parse(xStr);
            var infoArr:Array = gObj.result;

            var gSize:uint = infoArr[0];
            
            if(gSize > 50)
            {
                // ver 1.2 이상
                // infoArr.shift();
                // var verMajor:int = infoArr[43];
				// 	var verMinor:int = infoArr[44];
				// 	var verPatch:int = infoArr[45];
                return infoArr.slice(44, 47);
            }
            else
            {
                // ver 1.1.0
                return [1, 1, 0];
            }

        }
		
		/**
		 * vector를 이용하면 mxml에서 파싱이 제대로 안되서 문법 오류나 난다. 실행에는 문제가 없지만, 코딩이 번거로워 array로 변경;
		 * */
//        protected var runVec:Vector.<Vector.<String>>;
        protected var runComs:Array;
//        public function runRelayProecss(xVec:Vector.<Vector.<String>>, xListener:Function = null):void{
		public function runRelayProecss(xComs:Array, xListener:Function = null):void{
            runComs = xComs;
            __listener = xListener;
            
            __runNextProcess();
            
        }
        protected function hasNextProcess():Boolean{
            return runComs && runComs.length > 0;
        }
        protected function __clearNextProcess():void{
            runComs = null;
        }
        protected function __runNextProcess():void{
            if(!hasNextProcess()){
                return;
            }
            
            runProcess(runComs.shift(), __listener);
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
            
            var gReg:RegExp = new RegExp("\{.*?\"success\".+?\}", "gm");
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