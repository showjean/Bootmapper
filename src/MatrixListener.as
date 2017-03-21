package
{
	import flash.events.EventDispatcher;

	public class MatrixListener extends EventDispatcher		
	{
		public static const SELECTED_CELL:String = "SELECTED_CELL";
		
		public function MatrixListener()
		{
		}
		
		private var _positionStr:String;
		private var _row:int;
		private var _col:int;
        private var _countOfDot:int = 0;
		public function push(xChar:String):void{
			//-COL,ROW=	
            // .COL,ROW.
			switch(xChar){
				case "-":
					__resetPosition();
					break;
				case ",":
                    if(_countOfDot == 2)
                    {
                        _countOfDot = 3;
                    }
					_col = parseInt(_positionStr, 10);
					_positionStr = "";
					break;
				case "=":
					__closePosition();
					break;
                case ".":
                    if(_countOfDot == 0)
                    {
                        _countOfDot = 1;
                        __resetPosition();
                    }else if(_countOfDot == 4)
                    {
                        __closePosition();
                        _countOfDot = 0;
                    }else
                    {
                        _countOfDot = 1;
                    }
                    break;
				default:
                    if(_countOfDot == 1)
                    {
                        _countOfDot = 2;
                    }else if(_countOfDot == 3)
                    {
                        _countOfDot = 4;
                    }
					_positionStr += xChar;
			}
            
//            trace("_countOfDot : ", _countOfDot);
		}
        
        private function __closePosition():void
        {
            _row = parseInt(_positionStr, 10);
            _positionStr = "";
            
            dispatchEvent(new MatrixEvent(SELECTED_CELL, _col, _row));
        }
        
        private function __resetPosition():void
        {
            _positionStr = "";
            _col = -1;
            _row = -1;
        }
    }
}