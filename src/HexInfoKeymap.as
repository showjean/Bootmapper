package
{
	public class HexInfoKeymap
	{		
		// json 에서 전달되는 기초 데이터;
		public var ver:int;
//		public var url:Object;
		public var fileName:String;
        public var targetName:String;
		public var fileExt:String;
		public var startAddress:String;
		public var startOffset:int;
		public var layerNames:Array;
		public var layers:int;
		public var columns:int;
		public var rows:int;
		
		// 계산되어 나중에 전달되는 데이터;
//		public var endOffset:int;
//		public var lines:int;		
		
		public function HexInfoKeymap(xHexInfo:Object)
		{
			ver = parseInt(xHexInfo.ver, 10);
//			url = xHexInfo.url;
            targetName = xHexInfo.targetName;
			fileName = xHexInfo.fileName;
			fileExt = xHexInfo.fileExt;
			startAddress = xHexInfo.startAddress;
			startOffset = parseInt(xHexInfo.startOffset, 10);
			layerNames = xHexInfo.layerNames;
			layers = parseInt(xHexInfo.layers, 10);
			columns = parseInt(xHexInfo.columns, 10);
			rows = parseInt(xHexInfo.rows, 10);
		}
	}
}