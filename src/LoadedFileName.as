package
{
	public class LoadedFileName
	{
		
		private var __loadedFileName:String = null;
		private var __loadedFileType:String = null;
		
		public function LoadedFileName()
		{
		}
		
		public function clear():void
		{
			__loadedFileName = null;
		}
		
		public function get name():String
		{
			return __loadedFileName;
		}
		
		public function set name(value:String):void
		{
			//			__loadedFileName = value;
			// 확장자 제거;
			var gDotIndex:int = value.lastIndexOf(".");
			if(gDotIndex > -1)
			{
				__loadedFileName = value.substring(0, gDotIndex);
				
				__loadedFileType = value.substring(gDotIndex+1, value.length);
			}
		}
		public function get type():String
		{
			return __loadedFileType.toLowerCase();
		}
		
		
		public function hasName():Boolean
		{
			return (__loadedFileName != null && __loadedFileName != "");
		}
		
	}
}