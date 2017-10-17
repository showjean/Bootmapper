package
{
	import mx.collections.ArrayList;
	import mx.collections.IList;
	
	public class HexParser
	{
		public static const HEX_MARK_LENGTH:int = 1;
		public static const HEX_LEN_LENGTH:int = 2;
		public static const HEX_OFFSET_LENGTH:int = 4;
		public static const HEX_TYPE_LENGTH:int = 2;
		public static const HEX_INDEX_LENGTH:int = 9;	//HEX_MARK_LENGTH + HEX_LEN_LENGTH + HEX_OFFSET_LENGTH + HEX_TYPE_LENGTH
		
		public static const HEX_DATA_LENGTH:int = 32;
		
		public static const HEX_PARITY_LENGTH:int = 2;
		
		public static const HEX_LINE_LENGTH:int = 43;	// DATA_INDEX_LENGTH + DATA_LENGTH +  DATA_PARITY_LENGTH;
		
		public static const MASK_DELAY:int = 0x7F;
		public static const BIT_DOWN_UP:int = 7;
		
		/**
		 * hex 파일의 시작 주소를 string으로 반환한다. 
		 * @param xHexStr
		 * @return 
		 * 
		 */		
		static public function getStartAddress(xHexStr:String):String{
			// ":10 6500 00"
			var gStr:String;
			var gHeader:String = "";
			var gAddressHeader:int = 0;
			var gAddress:int = 0;
			var gIdx:int = xHexStr.indexOf(":");
			if(gIdx == -1){
				return "0";
			}
			// :02 0000 02 1000 EC or :02 0000 04 0001 F9
			// 02 type : GGGG0 + offset
			// 04 type : GGGG0000 + offset
			gIdx = gIdx + HEX_MARK_LENGTH + HEX_LEN_LENGTH;			
			var gType:String = xHexStr.substr(gIdx + HEX_OFFSET_LENGTH, HEX_TYPE_LENGTH);
			trace("getStartAddress type : ", gType);
			if(gType == "02" || gType == "04"){
				gHeader = xHexStr.substr(gIdx+ HEX_OFFSET_LENGTH + HEX_TYPE_LENGTH, 4);
				if(gType == "02"){
					gAddressHeader = parseInt("0x"+gHeader+"0", 16);
				}else{
					gAddressHeader = parseInt("0x"+gHeader+"0000", 16);
				}
				
				gIdx = xHexStr.indexOf(":", gIdx);
				if(gIdx == -1){
					return "0";
				}
				gIdx = gIdx + HEX_MARK_LENGTH + HEX_LEN_LENGTH;
			}
			
			gStr = xHexStr.substr(gIdx, HEX_OFFSET_LENGTH);
			gAddress = parseInt("0x"+gStr, 16);
			trace("gAddressHeader : ", gAddressHeader.toString(16), "gAddress : ", gAddress.toString(16));
			gAddress = gAddressHeader + gAddress;
			gStr = gAddress.toString(16).toUpperCase();
			
			trace("getStartAddress: ", gStr);
			return gStr;
		}
		
		static public function getStringWithParityByte(xStr:String):String{	
			var gParityIndex:int;
			var gParitySum:int;
			var gParityStr:String;
			var gLen:int = xStr.length >> 1;
			
			// parity check
			var gStr:String = xStr; //.substr(0, HEX_LINE_LENGTH-HEX_PARITY_LENGTH);
			gParityIndex = 0;
			gParitySum = 0;
			for(var k:int=0;k<gLen; ++k){
				var gVal:int = parseInt(gStr.substr(gParityIndex, 2), 16);
				gParitySum += gVal;
				gParityIndex += 2;
				//					trace(gVal.toString(16));
			}
			gParityStr = Util.toTwoByteHex(uint(((~gParitySum)+1)&0xFF));
			//				trace(gParityStr);
			// parity check end
			
			return xStr + gParityStr;
		}
		
		/**
		 * serialize된 string 데이터를 hex파일로 변환해서 반환  
		 * @param xMatrixStr
		 * @param xData
		 * @return 
		 * 
		 */		
		static public function convertToHex(xMatrixStr:String, xLen:int, xStartAddress:int, xExceptNewline:Boolean = false):String{			
			
			// ":10 6500 00"
			var gMatrixLen:int = xLen; 
			gMatrixLen = gMatrixLen * 2;
			var gLines:int = Math.ceil(gMatrixLen / HEX_DATA_LENGTH);
			trace("xMatrixStr.length = ", xMatrixStr.length, "lines = ", gLines);
			var gLen:int = gLines;
			var gDataLen:int = HEX_DATA_LENGTH;
			var gDataStr:String;
			var gMatrixIndex:int = 0;
			var gMatrixStr:String = "";
			var gHexMark:String = ":";
			var gHexType:String = "00";	// data type
			var gHexLength:String;
			var gOffset:String;
			var gIndexNumber:int = xStartAddress; //parseInt(xData.startLine.substr(3, 6), 16);
            var gDummyZero:String = "00";
			
			// :02 0000 02 1000 EC or :02 0000 04 0001 F9
			// 02 type : GGGG0 + offset
			// 04 type : GGGG0000 + offset
			var gExtendAddress:uint = 0xFFFF;
			// offset over
			if(gIndexNumber > gExtendAddress) {
				gIndexNumber = gIndexNumber & gExtendAddress;	// 2byte
				gExtendAddress = xStartAddress - gIndexNumber;
				trace("convertToHex:: gExtendAddress: ", gExtendAddress, "IndexNumber : ", gIndexNumber);
				gMatrixStr = gHexMark + getStringWithParityByte("02" + "0000" + "02" + Util.toHex(gExtendAddress >> 4));
				trace(gMatrixStr);
				if(!xExceptNewline) gMatrixStr += "\r\n";
			}
			for(var i:int = 0; i< gLen; ++i){
				var gStr:String = "";
				gDataStr = xMatrixStr.substr(gMatrixIndex, gDataLen);
				//				if(gDataStr.length < DATA_LENGTH){
				//					gDataStr = gDataStr + gTailStr.substr(0, DATA_LENGTH-gDataStr.length);
				//				}
				gHexLength = Util.toTwoByteHex(gDataStr.length/2);
				gOffset = Util.toHex(gIndexNumber);
                if(gOffset.length < 4) gOffset = gDummyZero.substr(0, 4-gOffset.length) + gOffset;
				gStr = gHexMark + getStringWithParityByte(gHexLength + gOffset + gHexType + gDataStr);
				gIndexNumber += 0x10;
//				trace(gStr);				
				
				gMatrixIndex += gDataLen;
				gMatrixStr += gStr;
				if(i < gLen-1){
                    if(!xExceptNewline) gMatrixStr += "\r\n";
				}
			}
			
			return gMatrixStr;
		}
        /**
         * 주소 등이 제거된 순수 데이터 파일을 list 데이터로 파싱  
         * @param xStr
         * @param xData
         * @return 
         * 
         */        
        static public function parseToListDataForMacro(xStr:String, xData:HexInfoMacro, xIsQuickMacro:Boolean = false):Vector.<IList>{
            // col, row별로 정렬;
            var gMacroVec:Vector.<IList> = new Vector.<IList>;
            
            var gMacroNum:int = xData.macroNum;
            var gMacroLen:int = xData.macroLength >> 1 ;
			if(xIsQuickMacro) 
			{
				gMacroLen = xData.macroLength;				
			}
			var gUpDownArray:Vector.<int> = new Vector.<int>;
			
            var gByteIndex:int = 0;
            var gIdx:int, gLabel:String;
            var gList:IList;
            var gIndex:int;
            var gModeDelay:int;
            var gDelay:int;
            var gMode:int;
            var gMacroKey:MacroKey;
            var gSplitIndexObj:Object = {};
            var gSplitIndex:int;
            var gSplitIndexPrev:int = -1;
            var gItem:Object;
            var gPrevMacroKey:MacroKey;
            for(var i:int = 0;i < gMacroNum; ++i){
                gList = new ArrayList();
                for(var k:int = 0;k < gMacroLen; ++k){
                    // 2byte = key index, 2byte = isDown/delay 
                    
                    // key index;
                    gMacroKey = new MacroKey();
                    gIndex = parseInt("0x"+xStr.substr(gByteIndex, 2), 16);
                    gByteIndex += 2;
                    
					if(xIsQuickMacro == false)
					{
	                    // isDown/delay
	                    gModeDelay = parseInt("0x"+xStr.substr(gByteIndex, 2), 16);
	                    gByteIndex += 2;
					}
                    
                    if(gIndex == 0 || gIndex == 0xFF) continue;
                    
                    gMacroKey.keyIndex = gIndex;
                    if(gSplitIndexObj[gIndex] == null){
                        gSplitIndex = MacroKey.getNextSplitIndex();
                        gSplitIndexObj[gIndex] = gSplitIndex;
                        gMacroKey.splitIndex = gSplitIndex; 
                    }else{
                        gSplitIndex = gSplitIndexObj[gIndex];
                        gMacroKey.splitIndex = gSplitIndex; 
                        gSplitIndexObj[gIndex] = null;						
                    }
					
					if(xIsQuickMacro == false)
					{
	                    gDelay = gModeDelay & MASK_DELAY;
	                    gMode = (gModeDelay >> BIT_DOWN_UP) & 0x01;
					}else{
						
						var gRef:int = gUpDownArray.indexOf(gIndex);
						if(gRef > -1)
						{
							gMode = 0;	// up;		
							gUpDownArray.splice(gRef, 1);
						}else{
							gMode = 1;	// down;
							gUpDownArray.push(gIndex);
						}
						
					}
//					trace("gIndex : ", gIndex, "gSplitIndex: ", gSplitIndex);
                    
                    if(gSplitIndexPrev == gSplitIndex && gSplitIndexObj[gIndex] == null){
                        // 같은 키 이므로 downUp으로 합친다.
                        gItem = gList.getItemAt(gList.length-1);
                        gPrevMacroKey = gItem.macroKey as MacroKey;
						
						if(xIsQuickMacro == false)
						{
                        	gPrevMacroKey.delay = gModeDelay & MASK_DELAY;
						}
						
                        gPrevMacroKey.mode = MacroKey.MODE_DOWN_UP;
                        gPrevMacroKey.splitIndex = -1;
                        gItem.label = Util.getLabel(gPrevMacroKey);
                    }else{
						if(xIsQuickMacro == false)
						{
                        	gMacroKey.delay = gDelay;
						}
						
                        gMacroKey.mode = (gMode == 1) ? MacroKey.MODE_DOWN : MacroKey.MODE_UP;
                        
                        gList.addItem(Util.getListObjectProxy(gMacroKey));
                    }
                    
                    gSplitIndexPrev = gSplitIndex;
                }
                gMacroVec[i] = gList;
            }
            
            return gMacroVec;
        }
		/**
		 * 
		 * @param xHexData
		 * @param xData
		 * @return 
		 * 
		 */
		static public function parseMacro(xHexData:String, xData:HexInfoMacro):Vector.<IList>{
			
			var gMacroStr:String = xHexData; 
			if(gMacroStr == null) return null;		
			
			var gMatrixLen:int = xData.macroNum * xData.macroLength;
			gMacroStr = extractHexData(gMacroStr, gMatrixLen);
            if(gMacroStr == null){
                return null;
            }
			//			trace("gMatrixStr: ", gMatrixStr);
			
			return parseToListDataForMacro(gMacroStr, xData);
		}
		
		static public function parseToListDataForDualAction(xStr:String, xData:HexInfoDualAction):Vector.<uint>{
			
//			trace("xStr : ", xStr);
			//FE8E FFFF FE39 FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
			var gDualactionNum:int = xData.dualactionNum;
			var gDualactionVec:Vector.<uint> = new Vector.<uint>(gDualactionNum);
			var gIndex:Number = 0;
			var gByteIndex:int = 0;
			for(var i:int = 0;i < gDualactionNum; ++i){
				// 한 쌍의 키코드 (조합키 +싱클 키)를 순서에 맞게 나열 한다.
				gDualactionVec[gIndex] = parseInt("0x"+xStr.substr(gByteIndex, 2), 16);
				gByteIndex += 2;				
				++gIndex;
				
				gDualactionVec[gIndex] = parseInt("0x"+xStr.substr(gByteIndex, 2), 16);
				gByteIndex += 2;
				++gIndex;				
			}
			
//			trace("gDualactionVec : ", gDualactionVec);
			
			return gDualactionVec;
		}
		
		private static function getHex(xIsDown:Boolean, xMacroKey:MacroKey, xHasDelay:Boolean = true):String{
			var gStr:String;
			// key index
			var gKeyidx:String = xMacroKey.keyIndex.toString(16).toUpperCase();						
			gKeyidx = Util.toDigitalType(gKeyidx);
			
			if(xHasDelay == false)
			{
				return gKeyidx;
			}
			
			// down/up, delay
			var gIsDown:int = xIsDown ? 1 : 0;			
			var gDelay:int = 0;
			if(xMacroKey.splitIndex > -1){
				gDelay = xMacroKey.delay;	
			}else if(xIsDown == false){	// split되지 않은 키는 up일때만 딜레이 적용;
				gDelay = xMacroKey.delay;
			}
			
			// 1byte = 0b00000000
			// 8bit = down/up
			// 1~7bit = delay
			var gDownDelayByte:int = (gIsDown << BIT_DOWN_UP);
//			trace("gDownDelayByte: ", gDownDelayByte);
			gDownDelayByte |= (MASK_DELAY & gDelay);			
//			trace(gDownDelayByte.toString(2));
			
			var gExtByte:String = gDownDelayByte.toString(16).toUpperCase();						
			gExtByte = Util.toDigitalType(gExtByte);
			
			gStr = gKeyidx + gExtByte;
			
			return gStr;
		}
		
		public static function getHexString(xMacroKey:MacroKey, xHasDelay:Boolean = true):String{
			var gStr:String;
			if(xMacroKey.splitIndex > -1){
				gStr = getHex(xMacroKey.mode == MacroKey.MODE_DOWN, xMacroKey, xHasDelay);
			}else{
				// down
				// up				
				gStr = getHex(true, xMacroKey, xHasDelay) + getHex(false, xMacroKey, xHasDelay);
			}
//			trace(xMacroKey.mode, gStr);
			return gStr;
		}
		
		public static function getHexByte(xInt:int):String
		{
			var gKeyidx:String = xInt.toString(16).toUpperCase();						
			return Util.toDigitalType(gKeyidx);
		}
		
		
		/**
		 * .hex 파일에서 address와 crc를 제거한 순수 데이터 파일만 반환한다. 
		 * @param xMatrixStr
		 * @param xLen
		 * @return 
		 * 
		 */		
		public static function extractHexData(xHexStr:String, xLen:int):String
		{
			// 첫 9바이트 제거, 끝 2바이트 제거
			var gSplitArr:Array = xHexStr.split("\r\n");
			var gLen:int = gSplitArr.length;
			xHexStr = "";
			var gStr:String;
			var gType:String;
			for(var i:int = 0 ; i < gLen ; ++i){
				gStr = gSplitArr[i] as String;
				
				// 2byte이상의 주소를 가지는 경우 Hex format의 "type"이 02인 라인이 있으므로 이를 처리;
				gType = gStr.substr(HexParser.HEX_INDEX_LENGTH - HexParser.HEX_TYPE_LENGTH, HexParser.HEX_TYPE_LENGTH);
				if(gType != "00"){
					trace("extractHexData:: type pass, type: ", gType);
					continue;
				}
				
				gStr = gStr.substr(HexParser.HEX_INDEX_LENGTH, gStr.length-HexParser.HEX_INDEX_LENGTH-2);
				//				trace(i, gStr);
				xHexStr += gStr;
			}
			var gMatrixLen:int = xLen;
			if(xHexStr.length>>1 != gMatrixLen){
				return null;
			}
			xHexStr = xHexStr.substr(0, gMatrixLen *2);
			return xHexStr;
		}
	}
}