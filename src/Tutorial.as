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

// Tutorial.as
// Mrcomputer1, August 2016
//
// The tutorial's code

package {
	import uiwidgets.*;
	import flash.display.*;

public class Tutorial {
	
	private static var stage:Stage = Scratch.app.stage;
	
	public static function editorMap():void{
		
		var box:TutorialDoBox = new TutorialDoBox(
		"Welcome to Sharp!\nLet's look at the editor!", 
		(stage.stageWidth - 190)/2, (stage.stageHeight - 100)/2);
		function next18():void{
			box = new TutorialDoBox(
			"This is the block categories.",
			Scratch.app.scriptsPart.selector.x+40,
			Scratch.app.scriptsPart.selector.y+40
			);
			box.addButton("Next", null);
			box.addButton("End Tutorial", null, 70);
			box.showOnStage(stage, false);
		}
		function next17():void{
			box = new TutorialDoBox(
			"This is where all your\nsprites are listed!",
			Scratch.app.libraryPart.x+40,
			Scratch.app.libraryPart.y+40
			);
			box.addButton("Next", next18);
			box.addButton("End Tutorial", null, 70);
			box.showOnStage(stage, false);
		}
		function next16():void{
			box = new TutorialDoBox(
			"This is the XY location\nof the mouse pointer",
			Scratch.app.stagePart.yReadout.x+40,
			Scratch.app.stagePart.yReadout.y+40
			);
			box.addButton("Next", next17);
			box.addButton("End Tutorial", null, 70);
			box.showOnStage(stage, true);
		}
		function next15():void{
			box = new TutorialDoBox(
			"This is the Stop Sign!\nIt stops all the scripts\nrunning in the project",
			Scratch.app.stagePart.stopButton.x+40,
			Scratch.app.stagePart.stopButton.y+40
			);
			box.addButton("Next", next16);
			box.addButton("End Tutorial", null, 70);
			box.showOnStage(stage, true);
		}
		function next14():void{
			box = new TutorialDoBox(
			"This is the Green Flag!\nIt runs the project!",
			Scratch.app.stagePart.runButton.x+40,
			Scratch.app.stagePart.runButton.y+40
			);
			box.addButton("Next", next15);
			box.addButton("End Tutorial", null, 70);
			box.showOnStage(stage, true);
		}
		function next13():void{
			box = new TutorialDoBox(
			"This is fullscreen button\nClick it to toggle fullscreen\nBelow it is the Sharp\nversion information",
			Scratch.app.stagePart.fullscreenButton.x+40,
			Scratch.app.stagePart.fullscreenButton.y+40
			);
			box.addButton("Next", next14);
			box.addButton("End Tutorial", null, 70);
			box.showOnStage(stage, true);
		}
		function next12():void{
			box = new TutorialDoBox(
			"This is the stage\nIt is where your sprites\nare shown",
			Scratch.app.stagePart.x+40,
			Scratch.app.stagePart.y+40
			);
			box.addButton("Next", next13);
			box.addButton("End Tutorial", null, 70);
			box.showOnStage(stage, false);
		}
		function next11():void{
			var box12:TutorialDoBox = new TutorialDoBox(
			"That is all for the top bar\nNext is the layout of the\nmain editor!",
			Scratch.app.topBarPart.helpTool.x+40,
			Scratch.app.topBarPart.helpTool.y+10
			);
			box12.addButton("Next", next12);
			box12.addButton("End Tutorial", null, 70);
			box12.showOnStage(stage, false);
		}
		function next10():void{
			var box11:TutorialDoBox = new TutorialDoBox(
			"This button does nothing at\nthis time\nJust ignore it!",
			Scratch.app.topBarPart.helpTool.x+20,
			Scratch.app.topBarPart.helpTool.y+10
			);
			box11.addButton("Next", next11);
			box11.addButton("End Tutorial", null, 70);
			box11.showOnStage(stage, true);
		}
		function next9():void{
			var box10:TutorialDoBox = new TutorialDoBox(
			"You can use this to make\na sprite or costume smaller",
			Scratch.app.topBarPart.shrinkTool.x+20,
			Scratch.app.topBarPart.shrinkTool.y+10
			);
			box10.addButton("Next", next10);
			box10.addButton("End Tutorial", null, 70);
			box10.showOnStage(stage, true);
		}
		function next8():void{
			var box9:TutorialDoBox = new TutorialDoBox(
			"You can use this to make\na sprite or costume bigger",
			Scratch.app.topBarPart.growTool.x+20,
			Scratch.app.topBarPart.growTool.y+10
			);
			box9.addButton("Next", next9);
			box9.addButton("End Tutorial", null, 70);
			box9.showOnStage(stage, true);
		}
		function next7():void{
			var box8:TutorialDoBox = new TutorialDoBox(
			"You can use this to delete\na sprite or something else",
			Scratch.app.topBarPart.cutTool.x+20,
			Scratch.app.topBarPart.cutTool.y+10
			);
			box8.addButton("Next", next8);
			box8.addButton("End Tutorial", null, 70);
			box8.showOnStage(stage, true);
		}
		function next6():void{
			var box7:TutorialDoBox = new TutorialDoBox(
			"You can use this to get\nmore of a sprite or something\nelse",
			Scratch.app.topBarPart.copyTool.x+20,
			Scratch.app.topBarPart.copyTool.y+10
			);
			box7.addButton("Next", next7);
			box7.addButton("End Tutorial", null, 70);
			box7.showOnStage(stage, true);
		}
		function next5():void{
			var box6:TutorialDoBox = new TutorialDoBox(
			"In the Help menu you can\nreport bugs and see credits\nbut that is about it!",
			Scratch.app.topBarPart.helpMenu.x+40,
			Scratch.app.topBarPart.helpMenu.y+10
			);
			box6.addButton("Next", next6);
			box6.addButton("End Tutorial", null, 70);
			box6.showOnStage(stage, true);
		}
		function next4():void{
			var box5:TutorialDoBox = new TutorialDoBox(
			"In the Edit menu you can\nundelete something and change\nthe colours of blocks",
			Scratch.app.topBarPart.editMenu.x+40,
			Scratch.app.topBarPart.editMenu.y+10
			);
			box5.addButton("Next", next5);
			box5.addButton("End Tutorial", null, 70);
			box5.showOnStage(stage, true);
		}
		function next3():void{
			var box4:TutorialDoBox = new TutorialDoBox(
			"This is the File menu\nYou can save, load and create\na new project from it\nYou can also record the project",
			Scratch.app.topBarPart.fileMenu.x+40,
			Scratch.app.topBarPart.fileMenu.y+10
			);
			box4.addButton("Next", next4);
			box4.addButton("End Tutorial", null, 70);
			box4.showOnStage(stage, true);
		}
		function next2():void{
			var box3:TutorialDoBox = new TutorialDoBox(
			"This is the language menu!\nYou can change what language\neverything is shown in\nTheir aren't many languages yet",
			Scratch.app.topBarPart.languageButton.x+20,
			Scratch.app.topBarPart.languageButton.y+10
			);
			box3.addButton("Next", next3);
			box3.addButton("End Tutorial", null, 70);
			box3.showOnStage(stage, true);
		}
		function next1():void{
			var box2:TutorialDoBox = new TutorialDoBox(
			"This is the top bar!\nYou can do a lot of stuff with\nit",
			Scratch.app.topBarPart.x+100, Scratch.app.topBarPart.y+20
			);
			box2.addButton("Next", next2);
			box2.addButton("End Tutorial", null, 70);
			box2.showOnStage(stage, false);
		}
		box.addButton("Next", next1);
		box.addButton("End Tutorial", null, 70);
		box.showOnStage(stage, false);
		
	}
	
}


}