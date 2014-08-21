SA-MP 0.3 Server Setup
----------------------

Once the configuration is complete, run samp-server.exe to
launch the server process.

CONFIGURATION:

Example server.cfg:
	echo Executing Server Config...
	lanmode 0
	maxplayers 32
	port 7777
	hostname Unnamed Server
	announce 0
	gamemode0 lvdm 1
	gamemode1 rivershell 1
	weburl www.sa-mp.com
	rcon_password changeme

To configure the server, you must edit the values in server.cfg. They are explained below:

hostname
--------
	Parameters:
		string
	
	Description:
		Specifies the hostname shown in the server browser
		
port
----
	Parameters:
		int
	
	Description:
		Specifies the port to listen on.
		This port is used for game connections, rcon connections, and for querying.
	
maxplayers
----------
	Parameters:
		int
	
	Description:
		Specifies the maximum amount of players.
		
lanmode
-------
	Parameters:
		int (0 or 1)
		
	Description:
		Turns lanmode on (1) or off (0). Lanmode (as the name suggests) is for use on LAN games, where bandwidth is not a problem. Lanmode sends data at a higher rate, for a smoother game.
		

announce
-------
	Parameters:
		int (0 or 1)
		
	Description:
		Announces your server to the 'Internet' server list in the SA:MP browser. On (1) or Off (0).

weburl
------
	Parameters:
		string
	
	Description:
		Specifies the URL shown in the server browser, which is associated to the server.
		
rcon_password
-------------
	Parameters:
		string
		
	Description:
		Specifies the password needed to connect to rcon, or login to rcon ingame.
		
gamemode0 - gamemode15
----------------------
	Parameters:
		string
		int
		
	Description:
		Specifies the rotation settings. The first parameter sets the game mode name. The second is the number of times it will repeat.
		You can use gamemode0 to specify the first gamemode, gamemode1 to specify the second, etc.
