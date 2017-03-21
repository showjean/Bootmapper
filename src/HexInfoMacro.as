package
{
	public class HexInfoMacro
	{		
		// json 에서 전달되는 기초 데이터;
		public var fileName:String;
        public var targetName:String;
		public var fileExt:String;
		public var startAddress:String;
		public var macroLength:int;
		public var macroNum:int;

		
		public function HexInfoMacro(xHexInfo:Object)
		{
			// {"startAddress":"6800","targetName":"ps2avrU","macroLength":168,"macroNum":12,"fileName":"macro_","fileExt":".hex"}
            targetName = xHexInfo.targetName;
			fileName = xHexInfo.fileName;
			fileExt = xHexInfo.fileExt;
			startAddress = xHexInfo.startAddress;
			macroLength = parseInt(xHexInfo.macroLength, 10);
			macroNum = xHexInfo.macroNum;
		}
	}
}