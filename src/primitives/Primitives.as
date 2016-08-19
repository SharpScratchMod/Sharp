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
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;

	import mx.utils.Base64Encoder;
	import mx.utils.Base64Decoder;
	
	import uiwidgets.DialogBox;

public class Primitives {

	private const MaxCloneCount:int = Scratch.app.sharpSettings.data.cloneLimit; //Scratch default: 300

	protected var app:Scratch;
	protected var interp:Interpreter;
	private var counter:int;
	private var httpReturn:String = "";
	private var httpRequestsAllowed:int = 10; private var httpRequestsActive:int = 0; // TODO: Add "hidden" setting for HTTP requests allowed
	private var fileNameValue:String; private var fileDataValue:String; private var fileLoadedValue:Boolean; private var fileErrored:Boolean; private var fileErrorValue:String;

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
		primTable["~"]			= function(b:*):* { return !interp.boolarg(b[0]) };



		primTable["nand"] =  function(b:*):* { return !(interp.boolarg(b[0]) && interp.boolarg(b[1])) };
		primTable["nor"] = function(b:*):* { return !(interp.boolarg(b[0]) || interp.boolarg(b[1])) }; //if i had realized that it was this simple i should've implemented logic gates since i started making sharp!
		primTable["xor"] = primLogicXor;
		primTable["xnor"] = primLogicXnor;
		primTable["abs"]			= function(b:*):* { return Math.abs(interp.numarg(b[0])) };
		primTable["sqrt"]			= function(b:*):* { return Math.sqrt(interp.numarg(b[0])) };
		primTable["power:of:"] 			= function(b:*):* { return Math.pow(interp.numarg(b[0]), interp.numarg(b[1])) };
		primTable["reverseString:"] 		= primReverseString;
		primTable["splitStringFrom:"]		= primSplit;
		primTable["bitwiseAnd:"]	= function(b:*):* { return interp.numarg(b[0]) & interp.numarg(b[1]) };
		primTable["bitwiseOr:"]		= function(b:*):* { return interp.numarg(b[0]) | interp.numarg(b[1]) };
		primTable["bitwiseNot:"]	= function(b:*):* { return ~ interp.numarg(b[0]) };
		primTable["bitwiseXor:"]		= function(b:*):* { return interp.numarg(b[0]) ^ interp.numarg(b[1]) };
		primTable["bitwiseLeftShift:"]	= function(b:*):* { return interp.numarg(b[0]) << interp.numarg(b[1])};
		primTable["bitwiseRightShift:"]	= function(b:*):* { return interp.numarg(b[0]) >> interp.numarg(b[1])};
		//this block doesn't work so please don't use it until we can fix it
		//primTable["bitwiseUnsignedShift"]	= function(b:*):* { return interp.numarg(b[0]) >>> interp.numarg(b[1])};

		primTable["concatenate:with:"]	= function(b:*):* { return ("" + b[0] + b[1]).substr(0, 10240); };
		primTable["letter:of:"]			= primLetterOf;
		primTable["stringLength:"]		= function(b:*):* { return String(b[0]).length };
		primTable["digitalRootOf:"]	=	primDigitalRoot;
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
		primTable["blockReplace:"]     = primStrReplace;
		primTable["blockSplitReturn:"] = function(b:*):* {return b[0].split(b[1])[b[2]-1]};
		// Sharp -- HTTP
		primTable["httpBlock:"] = primHttp;
		primTable["httpReturn:"] = function(b:*):* {return httpReturn};
		primTable["goToURL:"] = primGoTo;
		// Sharp -- Files
		primTable["saveFile:"] = primFileSave;
		primTable["loadFile:"] = primFileLoad;
		primTable["loadedFileName:"] = function(b:*):*{ return fileNameValue; };
		primTable["loadedFileData:"] = function(b:*):*{ return fileDataValue; };
		primTable["fileLoaded:"] = primFileLoaded;
		primTable["fileLoadFailed:"] = primFileLoadFail;
		primTable["fileLoadFailReason:"] = primFileLoadFailReason;

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
			case "Phi": return (1 + Math.sqrt(5)) / 2;
		}
		return 0;
	}
	private function primSplit(b:Array):String {
		var a:String = b[0];
		var result:String = "";
		var i:int;
		var j:int = interp.numarg(b[2]);
		for(i = interp.numarg(b[1]); i < j + 1; i++) {
			result += a.charAt(i -1);
		}
		return result;

	}
	// Sharp
	private function primStrReplace(b:Array):String{
		return b[1].replace(new RegExp(b[0], "g"), b[2]);
	}
	private function primDigitalRoot(b:Array):Number{
		if(interp.numarg(b[0]) < 9){
			return interp.numarg(b[0])
		} else {
			return interp.numarg(b[0]) - (9 * Math.floor((interp.numarg(b[0])-1)/9));
		}
	}


	private function primLogicXor(b:Array):Boolean{
		if(interp.boolarg(b[0]) !== interp.boolarg(b[1])){
			return true;
		} else if (interp.boolarg(b[0]) == interp.boolarg(b[1])) {
			return false;
		} else {
			return false;
		}
	}

	private function primLogicXnor(b:Array):Boolean{
		if (interp.boolarg(b[0]) == interp.boolarg(b[1])) {
			return true;
		} else {
			return false;
		}
		return false;
	}
	// Sharp --- HTTP
	private function primHttp(b:Array):void {
		if(httpRequestsActive == httpRequestsAllowed) return;
		httpRequestsActive++;
		var url:String = b[1];
		var req:URLRequest = new URLRequest(url);
		req.method = URLRequestMethod.GET;

		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, onComplete);
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		loader.load(req);

		function onComplete(e:Event){
			httpReturn = e.target.data.readUTFBytes(e.target.data.bytesAvailable);
			httpRequestsActive--;
		}
	}
	private function primGoTo(b:Array):void{
		DialogBox.confirm("Do you want to go to '" + b[0] + "'?", null, okFunc);
		function okFunc():void{
			var request:URLRequest = new URLRequest(b[0]);
			navigateToURL(request, "_blank");
		}
	}
	//Sharp --- Files
	private function primFileSave(b:Array):void{
		DialogBox.confirm("Would you like to save the file '" + b[1] + "' to your computer?", null, okFunc, cancelFunc);
		function okFunc():void{
			function cancelHandle(e:Event){
				fileLoadedValue = true;
				fileErrored = true;
				fileErrorValue = "Cancelled by user";
			}
			function ioErrorHandle(e:IOErrorEvent){
				fileLoadedValue = true;
				fileErrored = true;
				fileErrorValue = "An IO error occurred!";
			}
			function securityError(e:SecurityErrorEvent){
				fileLoadedValue = true;
				fileErrored = true;
				fileErrorValue = "A security error occurred! This is most likely a problem with Sharp!";
			}
			var file:FileReference = new FileReference();
			file.addEventListener(Event.CANCEL, cancelHandle);
			file.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandle);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
			file.save(b[0], b[1]);
			fileLoadedValue = true;
		}
		function cancelFunc():void{
			fileLoadedValue = true;
			fileErrored = true;
			fileErrorValue = "Denied by user";
		}
	}
	private function primFileLoad(b:Array):void{
		DialogBox.confirm("Would you like to open a file from your computer?", null, okFunc, cancelFunc);
		function okFunc():void{
			var fileName:String, data:ByteArray;
			function cancelHandle(e:Event){
				fileLoadedValue = true;
				fileErrored = true;
				fileErrorValue = "Cancelled by user";
			}
			function ioErrorHandle(e:IOErrorEvent){
				fileLoadedValue = true;
				fileErrored = true;
				fileErrorValue = "An IO error occurred!";
			}
			function securityError(e:SecurityErrorEvent){
				fileLoadedValue = true;
				fileErrored = true;
				fileErrorValue = "A security error occurred! This is most likely a problem with Sharp!";
			}
			function fileLoaded(event:Event):void{
				var file:FileReference = FileReference(event.target);
				file.addEventListener(Event.CANCEL, cancelHandle);
				file.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandle);
				file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
				fileName = file.name;
				data = file.data;

				fileNameValue = fileName;
				fileDataValue = data.readUTFBytes(data.bytesAvailable);
				fileLoadedValue = true;
			}
			function fileSelected(event:Event):void{
				var file:FileReference = FileReference(fileList.fileList[0]);
				file.addEventListener(Event.COMPLETE, fileLoaded);
				file.load();
			}
			var fileList:FileReferenceList = new FileReferenceList();
			fileList.addEventListener(Event.SELECT, fileSelected);
			fileList.addEventListener(Event.CANCEL, cancelHandle);
			fileList.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandle);
			fileList.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
			try{
				fileList.browse(null);
			}catch(e:*){}
		}
		function cancelFunc():void{
			fileLoadedValue = true;
			fileErrored = true;
			fileErrorValue = "Denied by user";
		}
	}
	private function primFileLoaded(b:Array):Boolean{
		var bl:Boolean = fileLoadedValue;
		fileLoadedValue = false;
		return bl;
	}
	private function primFileLoadFail(b:Array):Boolean{
		return fileErrored;
	}
	private function primFileLoadFailReason(b:Array):String{
		return fileErrorValue;
	}
}}
