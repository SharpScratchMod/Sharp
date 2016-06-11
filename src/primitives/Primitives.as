/*
 * Scratch Project Editor and Player
 * Copyright (C) 2014 Massachusetts Institute of Technology
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

// Primitives.as
// John Maloney, April 2010
//
// Miscellaneous primitives. Registers other primitive modules.
// Note: A few control structure primitives are implemented directly in Interpreter.as.

package primitives {
	import flash.utils.Dictionary;
	import blocks.*;
	import interpreter.*;
	import scratch.ScratchSprite;
	import translation.Translator;
	
	import flash.net.*;
	import flash.events.Event;

public class Primitives {

	private const MaxCloneCount:int = Scratch.app.sharpSettings.data.cloneLimit; //Scratch default: 300

	protected var app:Scratch;
	protected var interp:Interpreter;
	private var counter:int;
	private var httpReturn:String = "";
	private var httpRequestsAllowed:int = 10; private var httpRequestsActive:int = 0; // TODO: Add "hidden" setting for HTTP requests allowed

	public function Primitives(app:Scratch, interpreter:Interpreter) {
		this.app = app;
		this.interp = interpreter;
	}

	public function addPrimsTo(primTable:Dictionary, specialTable:Dictionary):void {
		// operators
		primTable["+"]				= function(b:*):* { return interp.numarg(b[0]) + interp.numarg(b[1]) };
		primTable["-"]				= function(b:*):* { return interp.numarg(b[0]) - interp.numarg(b[1]) };
		primTable["*"]				= function(b:*):* { return interp.numarg(b[0]) * interp.numarg(b[1]) };
		primTable["/"]				= function(b:*):* { return interp.numarg(b[0]) / interp.numarg(b[1]) };
		primTable["randomFrom:to:"]		= primRandom;
		primTable["<"]				= function(b:*):* { return compare(b[0], b[1]) < 0 };
		primTable["="]				= function(b:*):* { return compare(b[0], b[1]) == 0 };
		primTable[">"]				= function(b:*):* { return compare(b[0], b[1]) > 0 };
		primTable["&"]				= function(b:*):* { return interp.boolarg(b[0]) && interp.boolarg(b[1]) };
		primTable["|"]				= function(b:*):* { return interp.boolarg(b[0]) || interp.boolarg(b[1]) };
		primTable["not"]			= function(b:*):* { return !interp.boolarg(b[0]) };
		primTable["abs"]			= function(b:*):* { return Math.abs(interp.numarg(b[0])) };
		primTable["sqrt"]			= function(b:*):* { return Math.sqrt(interp.numarg(b[0])) };
		primTable["power:of:"] 			= function(b:*):* { return Math.pow(interp.numarg(b[0]), interp.numarg(b[1])) };
		primTable["reverseString:"] 		= primReverseString;
		primTable["splitStringFrom:"]		= primSplit;

		primTable["concatenate:with:"]	= function(b:*):* { return ("" + b[0] + b[1]).substr(0, 10240); };
		primTable["letter:of:"]			= primLetterOf;
		primTable["stringLength:"]		= function(b:*):* { return String(b[0]).length };

		primTable["%"]				= primModulo;
		primTable["rounded"]			= function(b:*):* { return Math.round(interp.numarg(b[0])) };
		primTable["computeFunction:of:"] 	= primMathFunction;
		primTable["chooseConstant:"] 		= primGetConstant;

		// clone
		primTable["createCloneOf"]		= primCreateCloneOf;
		primTable["deleteClone"]		= primDeleteClone;
		primTable["whenCloned"]			= interp.primNoop;

		// testing (for development)
		primTable["NOOP"]			= interp.primNoop;
		primTable["COUNT"]			= function(b:*):* { return counter };
		primTable["INCR_COUNT"]			= function(b:*):* { counter++ };
		primTable["CLR_COUNT"]			= function(b:*):* { counter = 0 };
		
		// Sharp
		primTable["inlineComment:"]     	= function(b:*):* {};
		primTable["true"]               	= function(b:*):* {return true};
		primTable["false"]      	 	= function(b:*):* {return false};
		// Sharp -- HTTP
		primTable["httpBlock:"] = primHttp;
		primTable["httpReturn:"] = function(b:*):* {return httpReturn};
		
		new LooksPrims(app, interp).addPrimsTo(primTable, specialTable);
		new MotionAndPenPrims(app, interp).addPrimsTo(primTable, specialTable);
		new SoundPrims(app, interp).addPrimsTo(primTable, specialTable);
		new VideoMotionPrims(app, interp).addPrimsTo(primTable, specialTable);
		addOtherPrims(primTable, specialTable);
	}

	protected function addOtherPrims(primTable:Dictionary, specialTable:Dictionary):void {
		new SensingPrims(app, interp).addPrimsTo(primTable, specialTable);
		new ListPrims(app, interp).addPrimsTo(primTable, specialTable);
	}

	private function primRandom(b:Array):Number {
		var n1:Number = interp.numarg(b[0]);
		var n2:Number = interp.numarg(b[1]);
		var low:Number = (n1 <= n2) ? n1 : n2;
		var hi:Number = (n1 <= n2) ? n2 : n1;
		if (low == hi) return low;
		// if both low and hi are ints, truncate the result to an int
		if ((int(low) == low) && (int(hi) == hi)) {
			return low + int(Math.random() * ((hi + 1) - low));
		}
		return (Math.random() * (hi - low)) + low;
	}

	private function primLetterOf(b:Array):String {
		var s:String = b[1];
		var i:int = interp.numarg(b[0]) - 1;
		if ((i < 0) || (i >= s.length)) return "";
		return s.charAt(i);
	}

	private function primModulo(b:Array):Number {
		var n:Number = interp.numarg(b[0]);
		var modulus:Number = interp.numarg(b[1]);
		var result:Number = n % modulus;
		if (result / modulus < 0) result += modulus;
		return result;
	}

	private function primMathFunction(b:Array):Number {
		var op:* = b[0];
		var n:Number = interp.numarg(b[1]);
		switch(op) {
		case "abs": return Math.abs(n);
		case "floor": return Math.floor(n);
		case "ceiling": return Math.ceil(n);
		case "int": return n - (n % 1); // used during alpha, but removed from menu
		case "sqrt": return Math.sqrt(n);
		case "sin": return Math.sin((Math.PI * n) / 180);
		case "cos": return Math.cos((Math.PI * n) / 180);
		case "tan": return Math.tan((Math.PI * n) / 180);
		case "asin": return (Math.asin(n) * 180) / Math.PI;
		case "acos": return (Math.acos(n) * 180) / Math.PI;
		case "atan": return (Math.atan(n) * 180) / Math.PI;
		case "ln": return Math.log(n);
		case "log": return Math.log(n) / Math.LN10;
		case "e ^": return Math.exp(n);
		case "10 ^": return Math.pow(10, n);
		}
		return 0;
	}

	private static const emptyDict:Dictionary = new Dictionary();
	private static var lcDict:Dictionary = new Dictionary();
	public static function compare(a1:*, a2:*):int {
		// This is static so it can be used by the list "contains" primitive.
		var n1:Number = Interpreter.asNumber(a1);
		var n2:Number = Interpreter.asNumber(a2);
		// X != X is faster than isNaN()
		if (n1 != n1 || n2 != n2) {
			// Suffix the strings to avoid properties and methods of the Dictionary class (constructor, hasOwnProperty, etc)
			if (a1 is String && emptyDict[a1]) a1 += '_';
			if (a2 is String && emptyDict[a2]) a2 += '_';

			// at least one argument can't be converted to a number: compare as strings
			var s1:String = lcDict[a1];
			if(!s1) s1 = lcDict[a1] = String(a1).toLowerCase();
			var s2:String = lcDict[a2];
			if(!s2) s2 = lcDict[a2] = String(a2).toLowerCase();
			return s1.localeCompare(s2);
		} else {
			// compare as numbers
			if (n1 < n2) return -1;
			if (n1 == n2) return 0;
			if (n1 > n2) return 1;
		}
		return 1;
	}

	private function primCreateCloneOf(b:Array):void {
		var objName:String = b[0];
		var proto:ScratchSprite = app.stagePane.spriteNamed(objName);
		if ('_myself_' == objName) proto = interp.activeThread.target;
		if (!proto) return;
		if (app.runtime.cloneCount > MaxCloneCount) return;
		var clone:ScratchSprite = new ScratchSprite();
		if (proto.parent == app.stagePane)
			app.stagePane.addChildAt(clone, app.stagePane.getChildIndex(proto));
		else
			app.stagePane.addChild(clone);

		clone.initFrom(proto, true);
		clone.objName = proto.objName;
		clone.isClone = true;
		for each (var stack:Block in clone.scripts) {
			if (stack.op == "whenCloned") {
				interp.startThreadForClone(stack, clone);
			}
		}
		app.runtime.cloneCount++;
	}

	private function primDeleteClone(b:Array):void {
		var clone:ScratchSprite = interp.targetSprite();
		if ((clone == null) || (!clone.isClone) || (clone.parent == null)) return;
		if (clone.bubble && clone.bubble.parent) clone.bubble.parent.removeChild(clone.bubble);
		clone.parent.removeChild(clone);
		app.interp.stopThreadsFor(clone);
		app.runtime.cloneCount--;
	}

	private function primReverseString(b:Array):String {
		var reverse:String = b[0];
		var result:String = "";
		var i:int;
		for(i = reverse.length; i > 0; i--) {
			result += reverse.charAt(i-1);
		}
		return result;

	}
	
	private function primGetConstant(b:Array):Number {
		var pickConstant:* = b[0];
		switch(pickConstant) {
			case "Pi": return Math.PI;
			case "E": return Math.E;
		}
		return 0;
	}
	private function primSplit(b:Block):String {
		var a:String = interp.arg(b, 0);
		var result:String = "";
		var i:int;
		var j:int = interp.numarg(b, 2);
		for(i = interp.numarg(b, 1); i < j + 1; i++) {
			result += a.charAt(i -1);
		}
		return result;

	}
	// Sharp --- HTTP
	private function primHttp(b:Array):void {
		if(httpRequestsActive == httpRequestsAllowed) return;
		httpRequestsActive++;
		var url:String = b[0];
		var req:URLRequest = new URLRequest(url);
		req.method = URLRequestMethod.GET;
		
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, onComplete);
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		loader.load(req);
		
		function onComplete(e:Event){
			httpReturn = e.target.data;
			httpRequestsActive--;
		}
	}
}}
