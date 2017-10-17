package
{
	

	public class MatrixParser
	{
		/**
		 * 배열을 16진수 스트링으로 변환해 1열로 나열한 스트링 반환; 
		 * @param xMatrixData
		 * @param xData
		 * @return 
		 * 
		 */		
		static public function serialize(xMatrixData:Array, xData:HexInfoKeymap):String {
			var gLayerLen:int = xData.layers;
			var gColLen:int = xData.columns;
			var gRowLen:int = xData.rows;
			var gDataStr:String = "";			
			var gStr:String;
			var gObj:Object;
			var gVal:int;
			for(var layer:int = 0;layer < gLayerLen; ++layer){				
				for(var row:int = 0;row < gRowLen; ++row){
					for(var col:int = 0;col < gColLen; ++col){
						gObj = xMatrixData[layer][row][col];
						gVal = 0;
						if(gObj){
							gVal = Number(gObj.index);
						}
						gStr = gVal.toString(16).toUpperCase();						
						gStr = Util.toDigitalType(gStr);	
//						trace(layer, row, col, gStr);
						gDataStr += gStr;
						
					}
				}
			}
//			trace(gDataStr.length);
			return gDataStr;
		}
		
		/**
		 * 정보에 해당하는 크기에 맞는 빈 데이터 반환 
		 * @param xData
		 * @return 
		 * 
		 */		
		static public function parseBlank(xData:HexInfoKeymap):Array{
			var gLayerLen:int = xData.layers;
			var gColLen:int = xData.columns;
			var gRowLen:int = xData.rows;
			var gDataArr:Array = [];
			var gObj:CellObject;
			for(var layer:int = 0;layer < gLayerLen; ++layer){	
				gDataArr[layer] = [];
				for(var row:int = 0;row < gRowLen; ++row){
					gDataArr[layer][row] = {};
					for(var col:int = 0;col < gColLen; ++col){
						gObj = new CellObject(0, KeyIndex.findNameByIndex(0)); //{index:0, label: KeyIndex.findNameByIndex(0)}
						gDataArr[layer][row][col] = gObj;						
					}
				}
			}
			return gDataArr;
		}
        
        /**
         * 주소 등이 제거된 순수 데이터 파일을 그리드 데이터로 파싱 
         * @param xStr
         * @param xData
         * @return 
         * 
         */        
        static public function parseToGridData(xStr:String, xData:HexInfoKeymap):Array{
            
            var gLayerLen:int = xData.layers;
            var gColLen:int = xData.columns;
            var gRowLen:int = xData.rows;
            
            // col, row별로 정렬;
            //			var gMatrixVec:Vector.<Vector.<Vector.<Object>>> = new Vector.<Vector.<Vector.<Object>>>;
            var gMatrixVec:Array = [];
            
            var gByteIndex:int = 0;
            var gIdx:int, gLabel:String;
            for(var layer:int = 0;layer < gLayerLen; ++layer){
                gMatrixVec[layer] = [];
                for(var row:int = 0;row < gRowLen; ++row){
                    gMatrixVec[layer][row] = {};
                    for(var col:int = 0;col < gColLen; ++col){
                        if(xStr.length <= gByteIndex-2){
                            gIdx = 0;
                        }else{
                            gIdx = parseInt("0x"+xStr.substr(gByteIndex, 2), 16);							
                        }
                        gLabel = KeyIndex.findNameByIndex(gIdx);
                        gMatrixVec[layer][row][col] = new CellObject(gIdx, gLabel); //{index:gIdx, label:gLabel};
                        gByteIndex += 2;
                    }
                    //					trace(row, gMatrixVec[layer][row]);
                }
            }
            
            return gMatrixVec;
        }
		/**
		 * .hex (키맵 파일) 데이터를  Array[row]{0:c0, 1:c1, ...} 형태로 변환해서 반환;
		 * @param xHexData
		 * @param xData
		 * @return 
		 * 
		 */		
		static public function parseKeymap(xHexData:String, xData:HexInfoKeymap):Array{
			
			var gMatrixStr:String = xHexData; 
			if(gMatrixStr == null) return null;		
            
            var gLayerLen:int = xData.layers;
            var gColLen:int = xData.columns;
            var gRowLen:int = xData.rows;
            
			var gMatrixLen:int = gLayerLen * gColLen * gRowLen;
			gMatrixStr = HexParser.extractHexData(gMatrixStr, gMatrixLen);
            if(gMatrixStr == null){
                return null;
            }
            trace("gMatrixStr: ", gMatrixStr, gMatrixLen);
						
			return parseToGridData(gMatrixStr, xData);
		}
		/**
		 * .json 파일의 배열/오브젝트 길이를 현재 데이터에 맞게 변환한 배열을 반환한다. 
		 * @param xJsonArr
		 * @param xData
		 * @return 
		 * 
		 */		
		public static function migrateJsonData(xJsonArr:Array, xData:HexInfoKeymap):Array{
			var gLayerLen:int = xData.layers;
			var gColLen:int = xData.columns;
			var gRowLen:int = xData.rows;
			var gDataArr:Array = [];
			var gJsonArr:Array;
			var gObj:CellObject;
			var gJsonRowObj:Object;
			var gJsonObj:Object;
			for(var layer:int = 0;layer < gLayerLen; ++layer){	
				gJsonArr = xJsonArr[layer];
				gDataArr[layer] = []
				if(gJsonArr == null){
					gJsonArr = [];
				}
				for(var row:int = 0;row < gRowLen; ++row){
					gDataArr[layer][row] = [];
					gJsonRowObj = gJsonArr[row];
					if(gJsonRowObj == null){
						gJsonRowObj = {};
					}
					for(var col:int = 0;col < gColLen; ++col){
						gJsonObj = gJsonRowObj[col];
						// {"index":0,"label":"    "}
						if(gJsonObj == null){
							gObj = new CellObject(0, KeyIndex.findNameByIndex(0)); //{index:0, label: KeyIndex.findNameByIndex(0)}
						}else{
							gObj = new CellObject(gJsonObj.index, gJsonObj.label.replace(/\n/, " ")); //{index:0, label: KeyIndex.findNameByIndex(0)}
						}
						gDataArr[layer][row][col] = gObj;						
					}
				}
			}
			
			return gDataArr;
		}
		
		
	}
}