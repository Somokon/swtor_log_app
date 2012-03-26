package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;

	public class Parser extends EventDispatcher{
		
		private var lineRegex:RegExp = /\[(.*)\] \[(.*)\] \[(.*)\] \[(.*)\] \[(.*)\] \((.*)\)( \<(\d+)\>)?/;
		
		private var rawLines:Vector.<String>;
		
		private var actors:Dictionary = new Dictionary();
		
		private var inCombat:Boolean = false;
		
		private var prevTime:int = 0;
		private var duration:int = 0;
		
		public function Parser() {
			
		}
		
		
		/**
		 * Clears the parser of all stored data
		 */
		public function clear():void {
			
			//Points actors to a new dictionary.
			//This SHOULD be enough to mark all the current actors/abilites/etc. for garbage collection.
			//Will have to check and make sure on this.
			actors = new Dictionary();
			
			prevTime = 0;
			duration = 0;
			inCombat = false;
		}
		
		
		/**
		 * Parses a log file
		 */
		public function parse(log:String):void {
			
			//Reset the time
			prevTime = 0;
			duration = 0;
			
			rawLines = Vector.<String>(log.split(/\n/));
			for each (var line:String in rawLines) {
				if (line != "")
					parseLine(line);
			}
			
			var totalDamage:int = 0;
			for each (var actor:Actor in actors) {
				for each (var ability:Ability in actor.abilities) {
					/*if (ability.timesActivated > 0)
						trace(	actor.name + " - " + ability.name + " - " 
								+ "[Total: " + ability.totalDamage + " (" + ability.timesActivated + ")" + ", Max: " + ability.maxDamage
								+ ", Min: " + ability.minDamage
								+ ", Crit %: " + ability.timesCrit / ability.timesTicked + "]");*/
					totalDamage += ability.totalDamage;
				}
			}
			//trace(totalDamage + " dmg - " + (duration / 1000) + " s - " + (totalDamage / (duration / 1000)) + " DPS");
			dispatchEvent(new ParserEvent(ParserEvent.PARSING_DONE));
		}
		
		
		/**
		 * Returns an ArrayCollector of abilities and their damage of a single actor,
		 * suitable for use in a flex chart.
		 */
		public function getDamageData(actorId:String):ArrayCollection {
			
			if (!actors[actorId])
				return null;
			
			var data:Array = new Array();
			
			for each (var ability:Ability in actors[actorId].abilities) {
				if (ability.totalDamage > 0)
					data.push({Ability:ability.name, Damage:ability.totalDamage});
			}
			
			return new ArrayCollection(data);
		}
		
		
		/**
		 * Returns an ArrayCollector of abilities and their healing of a single actor,
		 * suitable for use in a flex chart.
		 */
		public function getHealData(actorId:String):ArrayCollection {
			
			if (!actors[actorId])
				return null;
			
			var data:Array = new Array();
			
			for each (var ability:Ability in actors[actorId].abilities) {
				if (ability.totalHeal > 0)
					data.push({Ability:ability.name, Healing:ability.totalHeal});
			}
			
			return new ArrayCollection(data);
		}
		
		
		/**
		 * Returns a list of all currently tracked actors
		 */
		public function get actorList():Vector.<Actor> {
			
			var result:Vector.<Actor> = new Vector.<Actor>();
			
			for each (var actor:Actor in actors) {
				result.push(actor);
			}
			
			return result;
		}
		
		
		/**
		 * Parses one line of a log file
		 */
		private function parseLine(line:String):void {
			
			var matches:* = lineRegex.exec(line);
			var time:int = Date.parse(matches[1]);	
			if (prevTime == 0)
				prevTime = time;
			
			/*var effect:String = matches[5];
			var value:String = matches[6];
			var threat:String = matches[8];*/
			
			//Blank source, dont handle yet
			if (matches[2] == "")
				return;
			var source:Actor = parseSourceOrTarget(matches[2]);
			
			//Blank target, dont handle yet
			if (matches[3] == "")
				return;
			var target:Actor = parseSourceOrTarget(matches[3]);
			
			//Blank ability
			if (matches[4] == "") {
				if (matches[5] == LogUtils.ENTER_COMBAT)
					inCombat = true;
				else if (matches[5] == LogUtils.EXIT_COMBAT)
					inCombat = false;
			}
			else {
				var ability:Ability = source.getAbility(matches[4]);
				
				var effectToken:String = matches[5];
				var valueToken:String = matches[6];
				if (effectToken == LogUtils.ACTIVATE_ABILITY) {
					ability.timesActivated++;
				}
				else if (effectToken == LogUtils.DEAL_DAMAGE) {
					var damage:Damage = parseDamage(valueToken);
					ability.timesTicked++;
					if (damage.type != LogUtils.MISS_DAMAGE)
						ability.addDamage(damage.value);
					if (damage.crit)
						ability.timesCrit++;
				}
				else if (effectToken == LogUtils.HEAL) {
					var heal:Heal = parseHeal(valueToken);
					ability.addHeal(heal.value);
					if (heal.crit)
						ability.timesCrit++;
					
				}
			}
			
			if (inCombat) {
				duration += (time - prevTime);
			}
			
			prevTime = time;
		}
		
		
		/**
		 * Returns the Actor for associated with the specified token
		 */
		private function parseSourceOrTarget(token:String):Actor {
			var actor:Actor;
			if (token.charAt(0) == '@') { //Player
				if (actors[token] == null) {
					actor = new Actor(token);
					actor.name = StringUtil.trim(token.replace('@', ''));
					actors[token] = actor;
				}
				actor = actors[token];
			}
			else { //NPC
				var nameAndId:Vector.<String> = LogUtils.splitNameAndId(token);
				if (actors[nameAndId[1]] == null) {
					actor = new Actor(nameAndId[1]);
					actor.name = nameAndId[0];
					actors[nameAndId[1]] = actor;
				}
				actor =  actors[nameAndId[1]];
			}
			
			return actor;
		}
		
		
		/**
		 * Parses a value token for damage dealt
		 */
		private function parseDamage(token:String):Damage {
			
			var damage:Damage = new Damage();
			var split:Array = token.split(" ");
			
			var value:String = split[0];
			if (value.indexOf("*") > -1)
				damage.crit = true;
			else
				damage.crit = false;
			
			damage.value = int(value.replace("*", ""));
			
			damage.type = split[1] + " " + split[2];
			
			return damage;
		}
		
		
		/**
		 * Parses a value token for heals done
		 */
		private function parseHeal(token:String):Heal {
			
			var heal:Heal = new Heal();
			
			if (token.indexOf("*") > -1)
				heal.crit = true;
			else
				heal.crit = false;
			
			heal.value = int(token.replace("*", ""));
			
			return heal;
		}
	}
}

internal class Damage {
	public var value:int;
	public var type:String;
	public var crit:Boolean;
}

internal class Heal {
	public var value:int;
	public var crit:Boolean;
}