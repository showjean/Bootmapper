package
{
	public class CellObject
	{
		
		public static  const cellColorNormal:uint = 0xFFFFFF;
		public static  const cellColorDiff:uint = 0xCCCCCC;
		public static  const cellColorDiffSpace:uint = 0xEEEEEE;
		public static  const cellColorFocus:uint = 0x00FF00;
		
		public var label:String;
		public var index:int;
		public var color:uint;
		public var isFocused:Boolean;
		
		public function CellObject(xIndex:int, xLabel:String, xColor:uint = 0xFFFFFF)
		{
			label = xLabel;
			index = xIndex;
			color = xColor;
			isFocused = false;
		}
		
		public function toJSON(s:String):*{
			return {index:index, label:label};
		}
		
		/*public function toString():String{
			return label;
		}*/
	}
}