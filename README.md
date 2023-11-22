# Super-Castlevania-IV-Practice
 ASM-Patch for this romhack

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

	
Hello Beloved CV4 Fans			
	This hack has savestate support using Select+R to save, 
	and Select+L to load.
	This does work on SD2SNES but not emulators!

	If you are on emulator use emulator patch.	


!! To access the in-game menu, press Select+Start	
	
Menu Functions Overview: (Use A to select and B to go out of a submenu)
	Stage Select: 	Here you can select a level with the D-Pad and lunch them with Button A
	Refill			Will revill your Equipment with Hearts, Cross, Whip, Multi, Life and Time
	Subweapons: 	Equip and unequip Subweapons 
	Multi:			Equip and unequip Multi Shot upgrade
	Whip:			Equip and unequip Whip Upgrades
	Health:			Select the amount of Health Points you like to have 
	Exit: 			Does the same as the A button. 


Extra:			
	Loop Room:			This can be set or unset. When set you will just loop the room when exiting or dieing.  Health will be refilled.									
	Break-Time-Xpos:	When set it will copy your current X Position to stop the timer when you get there after a room reset.		
	Break-Time-Xpos:	Same for the yPos. Remember to unset both and exit the menu so it can copy a new position again.
	XPos-Viewer:		This will show Simons X and Y position in the HUD. This will tell you the pixel he is standing on.
	Second-Quest-Switch:Here you can toggle first and second quest. Remember to reset/transit the room if you like the enemy buff to be applied.	
	RNG-Disable			This will disable the RNG and set all values to FF
	Invincible			Toggle 
	Flight				This is not a true flight and you rather jump to get hight. You can also sink in any ground once crouched. So you can explore anything with this. 

HotkeyFunctions:
	Holding select and pressing X will rotate music. Select and A will play it.


EXTRA INFO:
	The Hack is originally created by Redguy.
	
ASM_PATCHING:
	- create ".rom" folder in the root directory
	- make a copy of mentioned target rom below to the foler mentioned above and rename it to "sc4.sfc" 
	- double click the make.bat file to lunch and a new patched sc4.sfc rom should appear in the root directory 
	
Known Bugs:
	- lvl 1 and lvl2 can not be looped. Since the exits are coded along other events.. I did not care
	- Credits will fail at VipersBoss
	- On emulators the savestate version might fail to load SRAM sicne the header does use overcapacity.. Make address $007FD8 from 08 to 07 and the menu could be used..
	- Save State does crash MOST emulator when loading. 
	...

TargetROM:
	Database match: Super Castlevania IV (USA)
	Database: No-Intro: Super Nintendo Entertainment System (v. 20210222-050638)
	File/ROM SHA-1: 684C1DFAFF8E5999422C24D48054D96BB12DA2F4
	File/ROM CRC32: B64FFB12
