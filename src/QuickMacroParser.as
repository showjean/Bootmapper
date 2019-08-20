package
{
	
	import mx.collections.IList;
	import mx.utils.ObjectProxy;
	
	public class QuickMacroParser
	{
        /**
         * 1.5.0 이후의 quick macro 는 extra data 가 '+' 로 구분되어있다.
         * 이를 개별 매크로로 병합해준다.
         * @param xDataStr 
         * @param xMacroNum 
         * @param xMacroLen 
         * @param xMacroExtraLen 
         * @return 
         */
        public static function migrateToMass(xDataStr:String, xMacroNum:uint, xMacroLen:uint, xMacroExtraLen:uint):String {
            var datas:Array = xDataStr.split("+");
            var macroString:String = datas[0];
            var macroExtraString:String = datas[1];
            if(null != macroExtraString && macroExtraString.length > 0) {
                var num:uint = xMacroNum;
                var macroLen:uint = xMacroLen * 2;		// 1byte 는 2글자 FF
                var macroExtraLen:uint = xMacroExtraLen * 2;		// 1byte 는 2글자 FF
                xDataStr = "";
                for(var i:uint = 0; i < num; ++i) {
                    xDataStr += macroString.substr(i * macroLen, macroLen);
                    xDataStr += macroExtraString.substr(i * macroExtraLen, macroExtraLen);
                }
            }

            return xDataStr;
        }

        /**
         * extra data를 분리하여 배열로 반환한다. [0]= macro, [1]= extra macro
         * 
         * @param xDataStr 
         * @param xMacroNum 
         * @param xMacroLen 
         * @param xMacroExtraLen 
         * @return 
         */
        public static function split(xDataStr:String, xMacroNum:uint, xMacroLen:uint, xMacroExtraLen:uint):Array {
            var num:uint = xMacroNum;
            var macroLen:uint = xMacroLen * 2;		// 1byte 는 2글자 FF
            var macroExtraLen:uint = xMacroExtraLen * 2;		// 1byte 는 2글자 FF
            var macroLenTotal:uint = macroLen + macroExtraLen;
            var macroString:String ="";
            var macroExtraString:String = "";
            var gStr:String;
            for(var i:uint = 0; i < num; ++i) {
                gStr = xDataStr.substr(i * macroLenTotal, macroLenTotal);
                macroString += gStr.substr(0, macroLen);
                macroExtraString += gStr.substr(macroLen);
            }
            return [macroString, macroExtraString];
        }
    }
}