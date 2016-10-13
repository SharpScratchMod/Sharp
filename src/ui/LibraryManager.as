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

package ui {
import flash.display.*;
import flash.events.*
import flash.geom.*;
import flash.text.*;
import flash.net.*;
import blocks.*;
import uiwidgets.*;
import util.*;

public class LibraryManager extends Sprite{
	
	public static function display(){
		DialogBox.ask("Please enter the library ID (see https://libraries.sharpscratchmod.cf for a list)", "", null, function(id:String){
			Scratch.app.importLibrary(id);
		});
	}
	
}


}