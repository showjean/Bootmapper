package
{
	

	public class KeyIndex		
	{
		
		static private var keyIndexVec:Vector.<Object>;			
		
		public function KeyIndex()
		{
		}
		
		// KeycapData의 1번째 인자 "라벨"은 참고를 위한 것으로 실제로 사용되는 이름은 KeyIndex.as에 정의 되어 있고, 2번째 인자 "index"에 따라 표시된다. 
		static private var keycapsArr:Array;			
		
		static public function setKeyIndexData(xArr:Array):void{			
			keycapsArr = parseKeyIndex(xArr);
			
			setData(keycapsArr);
		}
		
		static public function parseKeyIndex(xArr:Array):Array{
			var gColLen:int = xArr.length;			
			for(var i:int = 0; i < gColLen; ++i){
				var gVec:Array = xArr[i];
				var gLen:int = gVec.length;
				for(var k:int = 0; k < gLen; ++k){
					var gObj:Object = gVec[k];
					var gKeycapData:KeycapData = new KeycapData(gObj.label, gObj.keyIndex, gObj.width, gObj.height, gObj.marginRight, gObj.marginBottom, gObj.uppercase, gObj.lowercase);
					gVec[k] = gKeycapData;
				}
			}
			return xArr;
		}
		
		static public function getKeyIndexData():Array{
			return keycapsArr;
		}
		
		static private function setData(xArr:Array):void{			
			keyIndexVec = new Vector.<Object>;
			
			var gColLen:int = xArr.length;			
			for(var i:int = 0; i < gColLen; ++i){
				var gVec:Array = xArr[i];
				var gLen:int = gVec.length;
				for(var k:int = 0; k < gLen; ++k){
					var gKeycapData:KeycapData = gVec[k] as KeycapData;
					
					keyIndexVec.push({name:gKeycapData.label, index:gKeycapData.keyIndex});
				}
			}
		}
		
		static public function findIndexByName(xName:String="NONE"):int{
			var gLen:int = keyIndexVec.length;
			
			for(var i:int = 0; i< gLen; ++i){
				if(keyIndexVec[i].name == xName){
					return keyIndexVec[i].index;
				}
			}
			
			return -1;
		}
		
		
		static public function findNameByIndex(xIndex:int = 0):String{
			var gLen:int = keyIndexVec.length;
			
			for(var i:int = 0; i< gLen; ++i){
				if(keyIndexVec[i].index == xIndex){
					return String(keyIndexVec[i].name); //.replace(/\n/, " ");
				}
			}
			
			return "BAD";
		}
	}
}

