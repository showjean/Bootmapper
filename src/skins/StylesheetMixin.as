
	// =================================================================
	/*
	*  Copyright (c) 2010 viatropos http://www.viatropos.com/
	*  Lance Pollard
	*  lancejpollard at gmail dot com
	*  
	*  Permission is hereby granted, free of charge, to any person
	*  obtaining a copy of this software and associated documentation
	*  files (the "Software"), to deal in the Software without
	*  restriction, including without limitation the rights to use,
	*  copy, modify, merge, publish, distribute, sublicense, and/or sell
	*  copies of the Software, and to permit persons to whom the
	*  Software is furnished to do so, subject to the following
	*  conditions:
	* 
	*  The above copyright notice and this permission notice shall be
	*  included in all copies or substantial portions of the Software.
	* 
	*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	*  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	*  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	*  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	*  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	*  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	*  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	*  OTHER DEALINGS IN THE SOFTWARE.
	*/
	// =================================================================
	
package skins
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	import mx.core.IMXMLObject;
	import mx.core.Singleton;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.IStyleManager2;
	import mx.styles.StyleManager;
	
	public class StylesheetMixin implements IMXMLObject
	{
		private var _palettes:Array;
		/**
		 *  Classes of static constants storing values for css
		 */
		public function get palettes():Array
		{
			return _palettes;
		}
		public function set palettes(value:Array):void
		{
			_palettes = value;
		}
		
		public function StylesheetMixin()
		{
		}
		
		public function setStyles():void
		{
			// get all selectors in the application
			var styleManager:IStyleManager2 = getStyleManager();
			var selectors:Array = styleManager.selectors;
			var declaration:CSSStyleDeclaration;
			var i:int = 0;
			var n:int = selectors.length;
			for (i; i < n; i++)
			{
				declaration = styleManager.getStyleDeclaration(selectors[i]);
				// set palette properties to each declaration
				setProperties(declaration);
			}
		}
		
		protected function getStyleManager():IStyleManager2
		{
			var application:*;
			try {
				application = flash.utils.getDefinitionByName("mx.core::FlexGlobals")["topLevelApplication"];
				if (application)
					return application.styleManager as IStyleManager2;
			} catch (error:Error) {
				application = flash.utils.getDefinitionByName("mx.core::Application")["application"];
				if (application)
					return IStyleManager2(Singleton.getInstance("mx.styles::IStyleManager2"));
			} 
			return null;
		}
		
		protected function setProperties(declaration:CSSStyleDeclaration):void
		{
			var selector:Object = getDeclarationToken(declaration);
			var property:String;
			for (property in selector)
			{
				setProperty(declaration, property, selector[property]);
			}
		}
		
		public function getDeclarationToken(declaration:CSSStyleDeclaration):Object
		{
			var selector:Object = {factory:declaration.factory};
			// maybe your selector has a "factory" property which we should avoid?
			if (!(typeof(selector.factory) == "function") || selector.factory == null)
				return null;
			selector.factory();
			delete selector.factory;
			return selector;
		}
		
		public function setProperty(declaration:CSSStyleDeclaration, property:String, value:*):*
		{
			var paletteValue:*;
			var changed:Boolean = false;
			if (value is Array)
			{
				var i:int = 0;
				var n:int = value.length;
				for (i; i < n; i++)
				{
					paletteValue = getPaletteItem(value[i]);
					if (paletteValue)
					{
						changed = true;
						value[i] = paletteValue;
					} 
				}
				
			}
			else if (value is String)
			{
				paletteValue = getPaletteItem(value);
				if (paletteValue)
				{
					value = paletteValue;
					changed = true;
				}
			}
			if (changed)
			{
				declaration.setStyle(property, value);
			}
		}
		
		public function getPaletteItem(targetId:String):*
		{
			var i:int = 0;
			var n:int = palettes.length;
			var PaletteClass:Object;
			for (i; i < n; i++)
			{
				PaletteClass = palettes[i];
				if (PaletteClass[targetId])
					return PaletteClass[targetId];
			}
			return null;
		}
		
		private var timer:Sprite = new Sprite();
		// have to wait a frame for styles to be initialized
		public function initialized(document:Object, id:String):void
		{
			var handler:Function = function(event:Event):void
			{
				timer.removeEventListener(Event.ENTER_FRAME, handler);
				timer = null;
				setStyles();
			}
			timer.addEventListener(Event.ENTER_FRAME, handler);
		}
	}	
}