package
{
	public class MacroKey
	{
		public static const MODE_UP:String = "up";
		public static const MODE_DOWN:String = "down";
		public static const MODE_DOWN_UP:String = "downUp";
		public static const DELAY_MAX:uint = 5;		// 5 second
		
		private static var _splitIndex:uint = 0;
		
		public var keyIndex:int;
		public var mode:String;
		public var delay:int = 0;
		public var splitIndex:int = -1;
		
		public function MacroKey()
		{
		}
		
		public static function getNextSplitIndex():uint
		{
			return _splitIndex++;	
		}
		public static function resetSplitIndex():void
		{
			_splitIndex = 0;	
		}
		
		/**
		 * 매크로를 차지하는 byte 길이 반환; 모든 길이를 더해서 최대 매크로 수를 넘지 않도록 확인할 때 사용;
		 * @return 
		 * 
		 */		
		public function getMacroLength():uint{
			return (splitIndex > -1) ? 2 : 4;
		}
        
        public function clone():MacroKey
        {
            var gMacroKey:MacroKey = new MacroKey();
            gMacroKey.keyIndex = keyIndex;
            gMacroKey.mode = mode;
            gMacroKey.delay = delay;
            gMacroKey.splitIndex = splitIndex;
            
            return gMacroKey;
        }
	}
}