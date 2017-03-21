package
{
	public class HexInfoDualAction
	{
		// json 에서 전달되는 기초 데이터;
		public var fileName:String;
		public var targetName:String;
		public var fileExt:String;
		public var startAddress:String;
		public var dualactionNum:int;
		
		public function HexInfoDualAction(xHexInfo:Object)
		{
			targetName = xHexInfo.targetName;
			fileName = xHexInfo.fileName;
			fileExt = xHexInfo.fileExt;
			startAddress = xHexInfo.startAddress;
			dualactionNum = xHexInfo.dualactionNum;
		}
	}
}