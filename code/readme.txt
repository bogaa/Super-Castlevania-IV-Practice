     /\
     )(
  __/  \__
 /  ____  \
/  |    |  \
|  |    |  |
|  |    `-.|           _    _                      ,-'/
|  |   _____  _____  _| |_ | |  ___  _            /  /_____  _ __   _   _____
|  |  /  _  \/  _  \|_   _|| | / _ \\ \          /  //  _  \| '_ \ | | /  _  \
|  |  '.| | || / \,'  | |  | || | | |\ \        /  / '.| | || / \ || | '.| | |
|  |     _| || \____  | |  | || |_| | \ \      /  /     _| || | | || |    _| |
|  |  ,-'   | \____ \ | |  | ||  ___|  \ \    /  /   ,-'   || | | || | ,-'   |
|  |  | ,-| |,-'   \ || |  | || |   __  \ \  /  /   |  .-| || | | || | | .-| |
|  |  | |_| || \___/ /| |_ | || |__/ /   \ \/  /    | |__| || | | || | | |_| |
|  |  |___,_|\_____,' \___||_| \____/     \   /     |____,_||_| |_||_| |___,_|
|  |           							   \_/         
|  |     ,-|   	 _								
|  |    |  |   	| \	,__	 _ 	 _ 	_ '	 _ 	 _ 				
\  |____|  /   	|-/	|  	 _\	/	| |	/	/_\ 	 	
 \__    __/     |   |  	\_/	\_,	| |	\_,	\_,		
    \  /                               
     )(
     \/
		
		Hello Beloved CV4 Fans!

This hack has savestate support using L+A to save, 
and L+R to load and retry. (Original Patch Select+R to Save and Select+L to Load)
This does work on SD2SNES but not emulators. 

To access the in-game menu, press Select+Start.

Holding select and pressing X will rotate music. Select and A will play it.

Menu Functions Overview: (Use A to select and B to go out of a submenu)

Stage Select: 	Here you can select a level to go to when pressing A
Refill			Will revill your Equipment with Hearts, Cross, Whip, Multi, Life and Time
Subweapons: 	Equip and unequip Subweapons 
Multi:			Equip and unequip Multi Shot upgrade
Whip:			Equip and unequip Whip Upgrades
Exit: 			Does the same as the A button. 

Extra:			
	Loop Room:			This can be set or unset. When set you will just loop the room when exiting or dieing.  Health will be refilled.									
	Break-Time-Xpos:	When set it will copy your current X Position to stop the timer when you get there after a room reset.		
	Break-Time-Xpos:	Same for the yPos. Remember to unset both and exit the menu so it can copy a new position again.
	No-Out-O-B-Death:	This will disable that Simons dies when jumping into a pit.. will probably just result you in resetting the room..  	

	Auto-Move:			Will move Simon with walking speed in the direction he is facing till you use directions again.
	XPOS-Viewer:		This will show Simons X position in the HUD. This will tell you the pixel he is standing on.
	MAX-REMOVE-Health	This will give Simon almost infinite Health. When unflag it will also remove all the health and is a good way to kill Simon.	
	Second-Quest-Switch	Here you can toggle first and second quest. Remember to reset/transit the room if you like the enemy buff to be applied.


Cosmetic:
	See-Through-Walls	Will make bg1 to transparence. Just a effect what will do what it said or the opposite in other screens..    
	Blue-Skin-Switch	This will give Simon new Blue armor.
	Skywalk-Attribute	This will set that Simon can stand and Walk in the Air. The game uses this for Mode7 stuff and Platforms. This can help you to get to strange places.
	Subw-Button-Map-X R Well this will make the X and R Shoot subweapons when unset you will not longer shoot anything and you need to go to the options or enable it again..


The Hack is originally created by Redguy and it toke me forever to 
reverse engineer it and butcher the code to add some more stuff to it.
I could learn a lot so far making this. Still the code is not all documented but might 
be in the future. Or I might just butcher it for other things..

Anyway hope you enjoin some practice sessions.

Known Bugs:
- lvl 1 and lvl2 can not be looped. Since the exits are coded along other events.. I did not care
- mode7 grahics will not be loaded correctly when resetting a room. Make sure you come from a other room or do a savestate.
- Credits will fail at VipersBoss
- On emulators the savestate version might fail to load SRAM sicne the header does use overcapacity.. Make address $007FD8 from 08 to 07 and the menu could be used..
- Save State does crash every emulator when loading. 