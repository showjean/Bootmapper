package
{
	public class KeycapData
	{
		public var keyIndex:int;
		public var width:Number;
		public var height:Number;
		public var marginRight:Number;
		public var marginBottom:Number;
        public var label:String;
        public var uppercase:String;
        public var lowercase:String;
		
		public function KeycapData(xLabel:String, xKeyIndex:int, xWidth:Number, xHeight:Number, xMarginRight:Number, xMarginBottom:Number, xUppercase:String = "", xLowercase:String = "")
		{
			label = xLabel;
			keyIndex = xKeyIndex;
			width = xWidth;
			height = xHeight;
			marginRight = xMarginRight;
			marginBottom = xMarginBottom;
            uppercase = xUppercase;
            lowercase = xLowercase;
		}
	}
}