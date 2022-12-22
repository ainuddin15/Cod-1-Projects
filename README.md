# Talk in Cod 1 Server through discord.


*open the discord-bot.py*

Change the variables according to your needs.

Like

Prefix = "<TYPE_YOUR_PREFIX_HERE>" # for example '!', '$', etc..

Host = "<TYPE_YOUR_SERVER_IP_ADDRESS>" # Server ip e.g 123.123.123.123 etc

Port = "<TYPE_YOUR_SERVER_PORTS>" # Server port e.g 28960, 28961, etc

Rcon = "<TYPE_YOUR_SERVER_RCON_PASSWORD>" # Rcon pass for the specified server

bot_name = "~Message-sender-bot" # Your bot name doesn't matter what name you give. The name you give the bot in discord developer dashboard.

Server_name = "<YOUR_SERVER_NAME>" # your server name.

path = "" # Location of the file where the Command.py file is saved. Like e.g /data/myserver/Command.py

TOKEN = "<YOUR_BOT_TOKEN>" # Your bot token...

Now before you run the script see the methods down below, Complete one of them so that your bot should work:

[Method No. 1](https://github.com/ainuddin15/Cod-1-discord-messenger/blob/main/README.md#method-1)

[Method No. 2](https://github.com/ainuddin15/Cod-1-discord-messenger/blob/main/README.md#method-2)

  
## Method 1
  
After doing that go to your main folder open the ___CoDaM__CoD1.1__.pk3 file go to codam/player.gsc
  
at line 119 press enter and add the below line:

  `[[ _F ]]( name,     "talk",     ::_cmd_talk,      "nowait" );`
  
now come down a little

before the _cmd_kill command

type the following code:

```
message(msg)
{
	sendservercommand("i \"^7^7" + level.nameprefix + ": ^7" + msg + "\""); // ^7^7 fixes spaces problem
} // Code from MiscMod
```

now come down a little, where the _cmd_kill command ends.

press enter and add the following code:

```
_cmd_talk(args, adminId )
{
	if ( !isdefined( args ) || ( args.size < 2 ) )
		return;		
	msg = " ";
	for(i=1;i<args.size;i++)
		msg = msg + " " + args[i];
	
	players = getentarray("player", "classname");
	//for(i = 0; i < players.size; i++)		// If you want to enable a sound when people talks from discord remove the // from the code.	
	//	players[i] playLocalSound("hq_score");	
	message(msg);
	return;
}
```
Now save it.

## Method 2

Now if you are not a coder and got confused don't be upset i got your back, i already made a player.gsc file which you need to replace it with  your ___CoDaM__CoD1.1__.pk3 codam/player.gsc





Now run the discord-bot.py :)

enjoy! 😉
