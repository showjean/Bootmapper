package
{
	
	import mx.collections.IList;
	import mx.utils.ObjectProxy;
	
	public class Util
	{
		static public function getItemIndexWithData(xList:IList, xData:Object):int
		{
			var gLen:int = xList.length;
			for(var i:int = 0; i < gLen; ++i)
			{
				if(xList.getItemAt(i).data == xData)
					return i;
			}
			return -1;
		}
		
		
		[inline]
		static public function isVersionGreaterOrEqual(xMaj:int, xMin:int, xPat:int, xTMaj:int, xTMin:int, xTPat:int):Boolean
		{
			return (xMaj > xTMaj || (xMaj == xTMaj && xMin > xTMin) || (xMaj == xTMaj && xMin == xTMin && xPat >= xTPat));
		}
		
		[inline]
		static public function toDigitalType(n:String):String {
			var out:String = n;
			
			if (n.length==1) {
				out = "0"+out;
			}
			return out;
		}
        
        static public function addLeadingZero(aNum:int):String 
        {
            return toDigitalType(String(aNum));
        }
        
		[inline]
		static public function toTwoByteHex(n:uint):String {
			return toDigitalType(n.toString(16).toUpperCase());
		}
		
		[inline]
		static public function toHex(n:uint):String {
			return n.toString(16).toUpperCase();
		}
		
		/**
		 * date to 20130409133000
		 * @param xDate
		 * @return 
		 * 
		 */	
		[inline]
		public static function dateToString(xDate:Date):String
		{
			var gStr:String = "";//DateUtil.toW3CDTF(xDate);
			gStr += String(xDate.fullYear) + addLeadingZero(xDate.month+1) + addLeadingZero(xDate.date) 
				+ addLeadingZero(xDate.hours) + addLeadingZero(xDate.minutes) + addLeadingZero(xDate.seconds);
			return gStr;
		}
		
		/**
		 * 
		 * @param xMacroKey
		 * @return 
		 * 
		 */		
		[inline]		
		public static function getListObjectProxy(xMacroKey:MacroKey):Object
		{
			return new ObjectProxy({label:getLabel(xMacroKey), macroKey:xMacroKey});
		}
		/**
		 * 
		 * @param xMacroKey
		 * @return 
		 * 
		 */		
		[inline]	
		public static function getLabel(xMacroKey:MacroKey):String {
			var gLabel:String;
			gLabel = KeyIndex.findNameByIndex(xMacroKey.keyIndex).replace("\n", " ");
			if(xMacroKey.mode != MacroKey.MODE_DOWN_UP){
				gLabel += " [" + xMacroKey.mode + "]";
			}
			if(xMacroKey.delay > 0){
				gLabel += "\t+" + (xMacroKey.delay/10) + "sec";
			}
			return gLabel;
		}
		/**
		 * 
		 * @param xDelay
		 * @return 
		 * 
		 */		
		[inline]	
		public static function getDelay(xDelay:Number):uint {
			xDelay = Math.min(xDelay, MacroKey.DELAY_MAX);
			var gDelay:uint = xDelay * 10;
			return gDelay
		}
	}
}