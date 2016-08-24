/*
 * Sharp Project Editor and Player
 * Copyright (C) 2016 Sharp Scratch Mod
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package uiwidgets{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.text.*;
	import ui.parts.UIPart;

public class TutorialDoBox extends Sprite{
	private var text:String;
	private var locx:int;
	private var locy:int;
	
	public function TutorialDoBox(text:String = "Do something!",
	locx:int = 0, locy:int = 0){
		this.text = text;
		this.locx = locx;
		this.locy = locy;
	}
	
	private function drawBackground():void{
		var borderColor:int = 0xB0B0B0;
		var arrowColor:int = 0xEEEEEE;
		var g:Graphics = graphics;
		g.clear();
		g.lineStyle(1.5, arrowColor, 1, true);
		g.moveTo(locx, locy);
		g.lineTo(locx+10, locy-10);
		g.moveTo(locx, locy);
		g.lineTo(locx+10, locy+10);
		g.lineStyle(0.5, borderColor, 1, true);
		g.beginFill(0xFFFFFF);
		g.drawRect(locx+10, locy-10, 200, 100);
	}
	
	private function drawNoArrow():void{
		var borderColor:int = 0xB0B0B0;
		var g:Graphics = graphics;
		g.clear();
		g.lineStyle(0.5, borderColor, 1, true);
		g.beginFill(0xFFFFFF);
		g.drawRect(locx+10, locy-10, 190, 100);
	}
	
	private function makeTheTextLabel():VariableTextField{
		var format:TextFormat = new TextFormat(CSS.font, 14, CSS.textColor);
		var result:VariableTextField = new VariableTextField();
		result.autoSize = TextFieldAutoSize.LEFT;
		result.selectable = false;
		result.background = false;
		result.setText(text, null);
		result.setTextFormat(format);
		result.x = locx+15;
		result.y = locy-10;
		return result;
	}
	
	public function remove():void{
		parent.removeChild(this);
	}
	
	public function addButton(label:String, action:Function, x:int = 15, y:int = 60):void{
		function doAction():void {
			remove();
			if(action != null) action();
		}
		var b:Button = new Button(label, doAction);
		b.x = locx+x;
		b.y = locy+y;
		addChild(b);
	}
	
	public function showOnStage(stage:Stage, arrow:Boolean = true):void{
		if(arrow) drawBackground();
		if(!arrow) drawNoArrow();
		var t:TextField = makeTheTextLabel();
		addChild(t);
		stage.addChild(this);
	}
}

}