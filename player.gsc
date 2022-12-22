
///////////////////////////////////////////////////////////////////////////////
// PROJECT: CoDaM/GameTypes
// PURPOSE: Player-related utilities
// UPDATE HISTORY
//	12/1/2003	-- Hammer: started
///////////////////////////////////////////////////////////////////////////////

//
///////////////////////////////////////////////////////////////////////////////
main( phase, register )
{
	codam\utils::debug( 0, "======== player/main:: |", phase, "|",
								register, "|" );

	switch ( phase )
	{
	  case "init":		_init( register );	break;
	  case "load":		_load();		break;
	  //case "start":	  	_start();		break;
	}

	return;
}

//
_init( register )
{
	codam\utils::debug( 0, "======== player/_init:: |", register, "|" );

	[[ register ]](   "connect_statusicon", ::connect_statusicon );
	[[ register ]](     "spawn_statusicon", ::spawn_statusicon );
	[[ register ]]( "spectator_statusicon", ::spectator_statusicon );

	[[ register ]](       "sessionteam", ::_sessionteam );
	[[ register ]](        "lockPlayer", ::lockPlayer );
	[[ register ]](      "unlockPlayer", ::unlockPlayer );
	[[ register ]](       "resetPlayer", ::resetPlayer );
	[[ register ]](      "resetPlayers", ::resetPlayers );
	[[ register ]](        "savePlayer", ::savePlayer );
	[[ register ]](    "saveAllPlayers", ::saveAllPlayers );
	[[ register ]](    "isLockedPlayer", ::isLockedPlayer );
	[[ register ]](     "isSavedPlayer", ::isSavedPlayer );
	[[ register ]](      "monotoneName", ::monotoneName );
	[[ register ]](   "adjustNameColor", ::adjustNameColor );
	[[ register ]](     "isPlayerTKing", ::isPlayerTKing );
	[[ register ]](     "isPlayerTDing", ::isPlayerTDing );
	[[ register ]](           "suicide", ::_suicide );
	[[ register ]](       "playerDeath", ::playerDeath );
	[[ register ]](    "manageSpectate", ::manageSpectate );
	[[ register ]]( "scorePlayerKilled", ::scorePlayerKilled );
	[[ register ]](       "playerScore", ::playerScore );

	level.blackDeath = &"^3YOU ARE DEAD!";
	level.blackKicked = &"^3YOU'VE BEEN KICKED!";
	level.blackRound = &"^3WAITING FOR NEXT ROUND!";
	level.blackSpec = &"^3SPECTATING HAS BEEN DISABLED!";

	// Setup default player info "keys" to save across maps
	level.gtp_defSavePlayerInfo = "name;team;weapon;bot";
	level.gtp_defCheckPlayerInfo = "name;team;weapon;bot;locked";
	level.gtp_savePlayerInfo = level.gtp_defSavePlayerInfo;
	level.gtp_checkPlayerInfo = level.gtp_defCheckPlayerInfo;

	level.gtp_prefix = "codam_gtp_";
	level.gtp_savePlayers =
		codam\utils::getVar( "scr", "saveplayers", "float", 0, 0 );

	level.connect_statusicon = "";
	level.spawn_statusicon = "";
	level.spectator_statusicon = "";

	return;
}

//
_load()
{
	codam\utils::debug( 0, "======== player/_load" );

	if ( !isdefined( game[ "gamestarted" ] ) )
	{
		precacheString( level.blackDeath );
		precacheString( level.blackKicked );
		precacheString( level.blackRound );
		precacheString( level.blackSpec );
	}

	_registerCommands();
	return;
}

//
_start()
{
	codam\utils::debug( 0, "======== player/_start" );

	return;
}

///////////////////////////////////////////////////////////////////////////////
//

//
///////////////////////////////////////////////////////////////////////////////
_registerCommands()
{
	_F = level.codam_f_commander;
	if ( !isdefined( _F ) )
		return;

        // Register special commands
        name = "codam/player";
        [[ _F ]]( name,         "kill", ::_cmd_kill,	  "nowait" );
        [[ _F ]]( name,  "playerReset", ::_cmd_playerCmd, "nowait" );
        [[ _F ]]( name,   "playerLock", ::_cmd_playerCmd, "nowait" );
        [[ _F ]]( name, "playerUnlock", ::_cmd_playerCmd, "nowait" );
        [[ _F ]]( name,      "fixName", ::_cmd_playerCmd, "nowait" );
        [[ _F ]]( name,     "monoName", ::_cmd_playerCmd, "nowait" );
        [[ _F ]]( name,     "talk",     ::_cmd_talk,      "nowait" );

	return;
}

message(msg)
{
	sendservercommand("i \"^7^7" + level.nameprefix + ": ^7" + msg + "\""); // ^7^7 fixes spaces problem
} // Code from MiscMod

//
///////////////////////////////////////////////////////////////////////////////
// Kill player(s) ...
_cmd_kill( args, adminId )
{
	codam\utils::debug( 0, "_cmd_kill" );

	if ( !isdefined( args ) || ( args.size < 1 ) )
		return;
	if ( args[ 0 ] == "usage" )
		return ( "all|<team>|<player> ..." );
	if ( args.size < 2 )
	{
		codam\utils::playerMsg( adminId, "^1***^3 error: '^2" +
					args[ 0 ] + "^3' missing arguments" );
		return;
	}

	cmd = args[ 0 ];

	// Isolate player arguments from the command
	_tmpa = [];
	for ( i = 1; i < args.size; i++ )
		_tmpa[ _tmpa.size ] = args[ i ];

	_players = codam\utils::playersFromList( _tmpa );
	if ( !isdefined( _players ) )
	{
		codam\utils::playerMsg( adminId, "^3'^2" + args[ 0 ] +
						"^3' no players matched" );
		return;
	}

	if ( _players.size < 1 )
		_players = getentarray( "player", "classname" );

	for ( i = 0; i < _players.size; i++ )
	{
		player = _players[ i ];
		if ( player.sessionstate == "playing" )
		{
			player suicide();
			iprintln( player.name + "^3 was killed by admin." );
			wait( 0.05 );
		}
	}

	codam\utils::playerMsg( adminId, "^3'^2" + args[ 0 ] +
						"^3' command completed" );
	return;
}

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


//
///////////////////////////////////////////////////////////////////////////////
_cmd_playerCmd( args, adminId )
{
	codam\utils::debug( 0, "_cmd_playerCmd" );

	if ( !isdefined( args ) || ( args.size < 1 ) )
		return;
	if ( args[ 0 ] == "usage" )
		return ( "all|spectator|<team>|<player> ..." );
	if ( args.size < 2 )
	{
		codam\utils::playerMsg( adminId, "^1***^3 error: '^2" +
					args[ 0 ] + "^3' missing arguments" );
		return;
	}

	cmd = args[ 0 ];

	// Isolate player arguments from the command
	_tmpa = [];
	for ( i = 1; i < args.size; i++ )
		_tmpa[ _tmpa.size ] = args[ i ];

	_players = codam\utils::playersFromList( _tmpa );
	if ( !isdefined( _players ) )
	{
		codam\utils::playerMsg( adminId, "^3'^2" + args[ 0 ] +
						"^3' no players matched" );
		return;
	}

	if ( _players.size < 1 )
		_players = getentarray( "player", "classname" );

	for ( i = 0; i < _players.size; i++ )
	{
		player = _players[ i ];

		switch( cmd )
		{
		  case "playerreset":
		  	[[ level.gtd_call ]]( "resetPlayer", player );
		  	break;
		  case "playerlock":
		  	player notify( "end_player",
		  				"server rule violation(s)" );
		  	break;
		  case "playerunlock":
		  	player [[ level.gtd_call ]]( "unlockPlayer" );
		  	player iprintln( "^3You've been unblocked, wait for next map/round to begin." );
		  	break;
		  case "fixname":
		  	name = player [[ level.gtd_call ]]( "adjustNameColor" );
		  	if ( name != player.name )
		  		player setClientCvar( "name", name );
		  	break;
		  case "mononame":
		  	name = player [[ level.gtd_call ]]( "monotoneName" );
		  	if ( name != player.name )
		  		player setClientCvar( "name", name );
		  	break;
		}

		wait( 0.05 );
	}

	codam\utils::playerMsg( adminId, "^3'^2" + args[ 0 ] +
						"^3' command completed" );
	return;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//

//
///////////////////////////////////////////////////////////////////////////////
connect_statusicon( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return( "" );

	return ( level.connect_statusicon );
}

//
spawn_statusicon( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return( "" );

	return ( level.spawn_statusicon );
}

//
spectator_statusicon( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return( "" );

	return ( level.spectator_statusicon );
}

//
///////////////////////////////////////////////////////////////////////////////
_sessionteam( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) ||
	     ( level.ham_g_gametype == "dm" ) )
		return( "none" );

	return ( self.pers[ "team" ] );
}

//
///////////////////////////////////////////////////////////////////////////////
lockPlayer( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 76, "GameTypes/Player/lockPlayer:: |",
							self.name, "|" );

	if ( !isPlayer( self ) )
		return;

	self.pers[ "gtp_locked" ] = true;
	self [[ level.gtd_call ]]( "savePlayer", "name;locked 1" );
	return;
}

unlockPlayer( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 76, "GameTypes/Player/unlockPlayer:: |",
							self.name, "|" );

	if ( !isPlayer( self ) )
		return;

	self.pers[ "gtp_locked" ] = undefined;
	[[ level.gtd_call ]]( "resetPlayer", self );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
isLockedPlayer( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return ( false );

	return ( isdefined( self.pers[ "gtp_locked" ] ) );
}

//
///////////////////////////////////////////////////////////////////////////////
resetPlayer( player, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 70, "GameTypes/Player/resetPlayer:: |",
								player, "|" );

	if ( !isPlayer( player ) )
		return;

	_ent = player getEntityNumber();
	setcvar( level.gtp_prefix + _ent, "" );

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
resetPlayers( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 0, "GameTypes/Player/resetPlayers" );

	// level.ham_sv_maxclients set in codam\utils.gsc
	for ( i = 0; i < level.ham_sv_maxclients; i++ )
		setcvar( level.gtp_prefix + i, "" );

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
__savePlayer( keys )
{
	codam\utils::debug( 75, "GameTypes/Player/__savePlayer:: |",
								keys, "|" );

	_ent = self getEntityNumber();

	_playerStr = "" + getTime();	// timestamp entry
	for ( i = 0; i < keys.size; i++ )
	{
	  	_playerStr += ( ";" + keys[ i ] );
		switch ( keys[ i ] )
		{
		  case "name":
			_playerStr += " " + codam\utils::enquote(
		  					monotoneName( self ) );
			break;
		  case "health":
			_playerStr += " " + self.health;
			break;
		  case "bot":
		  	if ( isdefined( self.pers[ "dumbbot" ] ) )
			  	_playerStr += " 1";
			break;
		  default:
			_tmps = self.pers[ keys[ i ] ];
			if ( isdefined( _tmps ) )
			  	_playerStr += " " +
			  			codam\utils::enquote( _tmps );
		  	break;
		}
	}

	setcvar( level.gtp_prefix + _ent, _playerStr );

	codam\utils::debug( 76, "SAVED PLAYER #", _ent, " |", _playerStr, "|" );

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
savePlayer( keys, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 75, "GameTypes/Player/savePlayer:: |",
						self.name, "|", keys, "|" );

	if ( !isPlayer( self ) )
		return;

	if ( !isdefined( keys ) || ( keys == "" ) )
		keys = level.gtp_savePlayerInfo;

	_keys = codam\utils::splitArray( keys, ";", "", true );
	if ( !isdefined( _keys ) || ( _keys.size < 1 ) )
		return;

	self __savePlayer( _keys );

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
saveAllPlayers( keys, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 0, "GameTypes/Player/saveAllPlayers:: |",
								keys, "|" );

	if ( !isdefined( keys ) || ( keys == "" ) )
		keys = level.gtp_savePlayerInfo;

	_keys = codam\utils::splitArray( keys, ";", "", true );
	if ( !isdefined( _keys ) || ( _keys.size < 1 ) )
		return;

	players = getentarray( "player", "classname" );
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		if ( isdefined( player.pers[ "gtp_locked" ] ) )
			player [[ level.gtd_call ]]( "lockPlayer" );
		else
			player __savePlayer( _keys );
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
isSavedPlayer( keys, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 70, "GameTypes/Player/isSavedPlayer:: |",
								keys, "|" );

	if ( !isPlayer( self ) )
		return ( undefined );

	_ent = self getEntityNumber();
	_savedStr = getcvar( level.gtp_prefix + _ent );
	if ( _savedStr == "" )
		return ( undefined );

	setcvar( level.gtp_prefix + _ent, "" );

	_savedVals = codam\utils::splitArray( _savedStr, "; " );
	// Make sure the timestamp plus at least one keys/value exist
	if ( !isdefined( _savedVals ) || ( _savedVals.size < 2 ) )
		return ( undefined );

	// Check for stale player info ...
	if ( level.gtp_savePlayers > 0 )
	{
		_time = (int) _savedVals[ 0 ][ "str" ];
		_now = getTime();
		if ( ( _time >= _now ) ||
		     ( ( ( _now - _time ) / 60000.0 ) >=
		     				level.gtp_savePlayers ) )
			return ( undefined );	// Stale entry!!!???
	}
	else
		keys = "name;locked";	// Always check for locked player!!!!

	if ( !isdefined( keys ) || ( keys == "" ) )
		keys = level.gtp_checkPlayerInfo;

	_keys = codam\utils::splitArray( keys, ";", "", true );
	if ( !isdefined( _keys ) || ( _keys.size < 1 ) )
		return;

	_matchedKeys = [];
	for ( i = 0; i < _keys.size; i++ )
	{
		_key = _keys[ i ];
		for ( j = 1; j < _savedVals.size; j++ )
			if ( _savedVals[ j ][ "fields" ][ 0 ] == _key )
			{
				_tmps = codam\utils::dequote(
					_savedVals[ j ][ "fields" ][ 1 ] );
				if ( _tmps != "" )
				{
					codam\utils::debug( 72, "GameTypes/Player/isSavedPlayer = |",
							_key, "=", _tmps, "|" );
					_matchedKeys[ _key ] = _tmps;
				}
			}
	}

	codam\utils::debug( 71, "GameTypes/Player/isSavedPlayer = found ",
						_matchedKeys.size, " keys" );

	return ( _matchedKeys );
}

//
///////////////////////////////////////////////////////////////////////////////
// Prepares names for display (strips out any existing color changes)
monotoneName( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return ( "" );

	return ( codam\utils::monotone( self.name ) );
}

//
///////////////////////////////////////////////////////////////////////////////
// Checks name for colors and ensures it ends in white
adjustNameColor( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return ( "" );

	name = self.name;
	_c = codam\utils::hasColor( name );
	if ( _c & 2 )
		name += "^";
	if ( _c & 4 )
		name += "^7";

	return ( name );
}

//
///////////////////////////////////////////////////////////////////////////////
// Team Killing limits
isPlayerTKing( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 90, "player/isPlayerTKing" );

	if ( !isPlayer( self ) )
		return ( false );

	if ( isdefined( self.pers[ "tk" ] ) )
		self.pers[ "tk" ]++;
	else
	{
		self.pers[ "tk" ] = 1;
		self.pers[ "tkTime" ] = getTime();	// First TK time
	}

	if ( ( level.tklimit > 0 ) && ( self.pers[ "tk" ] >= level.tklimit ) )
		return ( true );

	_mins = ( getTime() - self.pers[ "tkTime" ] ) / 60000.0;
	if ( _mins <= 1 )
		_rate = self.pers[ "tk" ];
	else
		_rate = self.pers[ "tk" ] / _mins;

	if ( ( level.tkrate > 0 ) && ( _rate >= level.tkrate ) )
		return ( true );

	if ( ( level.tkwarn > 0 ) &&
	     ( ( self.pers[ "tk" ] % level.tkwarn ) == 0 ) )
		self iprintln( "^1WARNING: ^2Team Kill detected!^3  Stop or you'll be locked out." );

	return ( false );
}

//
///////////////////////////////////////////////////////////////////////////////
// Team Damage limits
isPlayerTDing( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 90, "player/isPlayerTDing" );

	if ( !isPlayer( self ) )
		return ( false );

	if ( isdefined( self.pers[ "td" ] ) )
		self.pers[ "td" ]++;
	else
	{
		self.pers[ "td" ] = 1;
		self.pers[ "tdTime" ] = getTime();	// First TD time
	}

	if ( ( level.tdlimit > 0 ) && ( self.pers[ "td" ] >= level.tdlimit ) )
		return ( true );

	_mins = ( getTime() - self.pers[ "tdTime" ] ) / 60000.0;
	if ( _mins <= 1 )
		_rate = self.pers[ "td" ];
	else
		_rate = self.pers[ "td" ] / _mins;

	if ( ( level.tdrate > 0 ) && ( _rate >= level.tdrate ) )
		return ( true );

	if ( ( level.tdwarn > 0 ) &&
	     ( ( self.pers[ "td" ] % level.tdwarn ) == 0 ) )
		self iprintln( "^1WARNING: ^2Team Damage detected!^3  Stop or you'll be locked out." );

	return ( false );
}

//
///////////////////////////////////////////////////////////////////////////////
_suicide( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return;

	if ( !isdefined( self.nosuicide ) &&
	     !codam\utils::getVar( "scr", "nosuicide", "bool", 1|2, false ) )
	{
		self suicide();
		return;
	}

	self.nosuicide = undefined;

	switch ( level.ham_g_gametype )
	{
	  case "re":
		self thread [[ level.gtd_call ]]( "gt_dropObjective" );

		//Remove HUD text if there's any
		if ( isdefined(	self.hudelem ) )
		{
			for ( i	= 1 ; i	< 16; i++ )
				if ( isdefined(	self.hudelem[ i ] ) )
					self.hudelem[ i	] destroy();
		}

		if ( isdefined(	self.progressbackground	) )
			self.progressbackground	destroy();
		if ( isdefined(	self.progressbar ) )
			self.progressbar destroy();
		/*FALLTHROUGH*/
	  default:
	  	self.sessionstate = "dead";
		self.statusicon = "gfx/hud/hud@status_dead.tga";
		level thread [[ level.gtd_call ]]( "gt_updateTeamStatus" );
		self thread [[ level.gtd_call ]]( "manageSpectate", "death" );
		wait( 0.05 );
	  	break;
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
playerDeath( attacker, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	// Make the player drop his weapon
	self thread [[ level.gtd_call ]]( "dropWeapon" );

	// Make the player drop health
	self thread [[ level.gtd_call ]]( "dropHealth" );

	// Drop player's dead body
	self thread [[ level.gtd_call ]]( "dropBody" );

	delay = 2;	// Delay becoming a spectator till after he's done dying
	wait( delay );	// ? Also required for Callback_PlayerKilled to complete
			//   before respawn/killcam can execute

	// Go show Killcam
	if ( self.dokillcam &&
	     codam\utils::getVar( "scr", "killcam", "bool", 1|2, true ) )
	{
		self thread [[ level.gtd_call ]]( "killcam", attacker, delay );
		wait( 0.05 );	// Allow time for killcam to start
	}

	// Handle spectate on death
	self thread [[ level.gtd_call ]]( "manageSpectate", "death" );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
scorePlayerKilled( eAttacker, a1, a2, a3, a4, a5, a6, a7, a8, a9,
				b0, b1, b2, b2, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return;

	if ( isPlayer( eAttacker ) )
	{
		if ( eAttacker == self )	// killed himself
			self.pers[ "kills" ]--;
		else
		if ( [[ level.gtd_call ]]( "usingPlayerScore" ) )
		{
			eAttacker.pers[ "kills" ]++;
			eAttacker.pers[ "score" ] =
				eAttacker [[ level.gtd_call ]]( "playerScore" );
			eAttacker.score = eAttacker.pers[ "score" ];

			eAttacker [[ level.gtd_call ]]( "checkScoreLimit",
							"gt_playerScoreLimit" );
		}
		else
		if ( !isdefined( eAttacker.pers[ "team" ] ) ||
		     ( eAttacker.pers[ "team" ] == "spectator" ) ||
		     ( eAttacker.pers[ "team" ] == self.pers[ "team" ] ) )
		{
			// killed by a friendly
			eAttacker.pers[ "kills" ]--;
			eAttacker.pers[ "score" ] =
				eAttacker [[ level.gtd_call ]]( "playerScore" );
			eAttacker.score = eAttacker.pers[ "score" ];
		}
		else
		{
			// Killed by opponent
			eAttacker.pers[ "kills" ]++;
			eAttacker.pers[ "score" ] =
				eAttacker [[ level.gtd_call ]]( "playerScore" );
			eAttacker.score = eAttacker.pers[ "score" ];

			if ( [[ level.gtd_call ]]( "usingTeamScore" ) )
			{
				teamscore = [[ level.gtd_call ]](
						"getTeamScore",
						eAttacker.pers[ "team" ] );
				[[ level.gtd_call ]]( "setTeamScore",
							eAttacker.pers[ "team" ],
							teamscore + 1 );
				level notify( "update_scorelimit" );
			}
		}
	}
	else //	You were in the	wrong place at the wrong time
		self.pers[ "kills" ]--;

	self.pers[ "deaths" ]++;
	self.deaths = self.pers[ "deaths" ];
	self.pers[ "score" ] = self [[ level.gtd_call ]]( "playerScore" );
	self.score = self.pers[ "score" ];

	return;
}

//
playerScore( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
				b0, b1, b2, b2, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return;

	kills = (float) self.pers[ "kills" ];
	deaths = (float) self.pers[ "deaths" ];

	switch ( level.scoresystem )
	{
	  case 1:
		if ( kills < 0 )
			return ( kills );

		if ( deaths < 1 )
			return ( ( kills * 100.0 ) + 100.0 );

		return ( ( kills * 100.0 / deaths ) + 0.5 );
	  default:
	  	return ( self.pers[ "kills" ] );
	}
}

//
///////////////////////////////////////////////////////////////////////////////
manageSpectate( whyHere, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 98, "manageSpectate:: |", whyHere, "|" );

	level endon( "intermission" );

	self notify( "end_spectate" );
	self endon( "end_spectate" );
	self endon( "spawned" );

	if ( !isPlayer( self ) )
		return;

	if ( !isdefined( whyHere ) )
		whyHere = "";

	if ( whyHere == "spec" )
	{
		// Player is spectator, does server restrict free view
		if ( level.restrictspec )
			self thread _specToBlack( whyHere );

		return;
	}

	if ( ( level.specmode == "stay" ) &&
	     ( whyHere != "kick" ) )
	{
		// Specmode: stay in place; simply float around dead body
		return;
	}

	// If killcam is active, wait for it to complete ...
	while ( isdefined( self.killcam ) ||
		self.archivetime )
		wait( 0.05 );

	if ( ( level.specmode == "black" ) ||
	     ( whyHere == "kick" ) )
	{
		// Specmode: spectate to black screen
		self thread _specToBlack( whyHere );
		return;
	}

	if ( level.specmode == "score" )
	{
		// Specmode: Watch scoreboard mode
		[[ level.gtd_call ]]( "gt_spawnIntermission" );
		return;
	}

	team = self.sessionteam;
	if ( !isdefined( team ) || ( team == "none" ) )
		team = self.pers[ "team" ];

	if ( ( level.specmode == "free" ) ||
	     ( isdefined( team ) && ( team == "spectator" ) ) )
	{
		// Specmode 3: free spectate starting from above dead body
		self.spectatorclient = -1;
		self.sessionstate = "spectator";
		self spawn( self.origin + ( 0, 0, 10 ), self.angles );
		return;
	}

	// Specmode: team lock
	if ( !isdefined( team ) ||
	     ( level.specmode != "team" ) )
		return;

	_emptyTeamList = [];
	for ( i = 0; i < level.ham_sv_maxclients; i++ )
		_emptyTeamList[ i ] = false;

	_myEnt = self getEntityNumber();

	cur = self.spectatorclient;
	if ( ( cur < 0 ) || ( cur >= level.ham_sv_maxclients ) )
		cur = _myEnt;	// Start with me

	_doNext = true;	// First time through ... find next live teammate
	_doPrev = false;
	for (;;)
	{
		// Identify this team's current players
		_team = _emptyTeamList;
		players = getentarray( "player", "classname" );
		for ( i = 0; i < players.size; i++ )
		{
			player = players[ i ];

			// Is player alive?
			if ( player.sessionstate != "playing" )
				continue;

			// Get player's proper team
			pteam = player.sessionteam;
			if ( !isdefined( pteam ) || ( pteam == "none" ) )
				pteam = player.pers[ "team" ];

			// Mark all players in my team
			if ( isdefined( pteam ) && ( pteam == team ) )
				_team[ player getEntityNumber() ] = true;
		}

		if ( _doPrev )
		{
			// Find previous team member to spectate on ...
			for ( i = 0; i < _team.size; i++ )
			{
				cur--;
				if ( cur < 0 )
					cur = level.ham_sv_maxclients - 1;
				if ( _team[ cur ] )
					break;	// Found previous teammate
			}
		}
		else
		{
			// Find next team member to spectate on ...
			for ( i = 0; i < _team.size; i++ )
			{
				cur++;
				if ( cur >= level.ham_sv_maxclients )
					cur = 0;
				if ( _team[ cur ] )
					break;	// Found next teammate
			}
		}

		if ( i >= _team.size )
		{
			// All team members are dead ...

			if ( isdefined( level.roundbased ) &&
			     level.roundbased &&
			     !level.allowrespawn )
			{
				// Allow free spectate in round-based GTs
				// ... round should be ending.
				self.spectatorclient = -1;
				self.sessionstate = "spectator";
				return;
			}

			// No team members to lock onto ... play dead Fido!
			self.sessionstate = "dead";
			_doNext = true;
			wait( 0.05 );
			continue;
		}

		_doNext = false;
		_doPrev = false;
		_inUse = true;

		// Wait for button press ...
		while ( !( _doNext || _doPrev ) )
		{
			if ( self.sessionstate == "playing" )
				return;	// hmm, endon's didn't work??!!

			nteam = self.sessionteam;
			if ( !isdefined( nteam ) || ( nteam == "none" ) )
				nteam = self.pers[ "team" ];
			if ( !isdefined( nteam ) || ( nteam == "spectator" ) )
			{
				// Cannot determine player's team???
				// Must do something, simply mark as dead
				// to force dropping to ground.
				self.sessionstate = "dead";
				return;	// Can't determine player's team?????
			}
			else
			if ( nteam != team )
			{
				// Switched teams while spectating???
				team = nteam;
				_doNext = true;
				wait( 0.05 );
				continue;
			}

			player = getEntByNum( cur );
			if ( isdefined( player ) &&
			     ( player.sessionstate != "playing" ) )
			{
				// Current team player went away or died
				_doNext = true;
			}
			else
			{
				self.sessionstate = "spectator";
				self.spectatorclient = cur;

				_doNext = self attackButtonPressed();
				_doPrev = self meleeButtonPressed();
				if ( _inUse )
				{
					_inUse = ( _doNext || _doPrev );
					_doNext = false;
					_doPrev = false;
				}
			}

			wait( 0.05 );
		}
	}
}

//
///////////////////////////////////////////////////////////////////////////////
_specToBlack( whyHere )
{
	level endon( "intermission" );

	self notify( "end_spectoblack" );
	self endon( "end_spectoblack" );
	self endon( "spawned" );

	if ( whyHere == "kick" )
	{
		self closeMenu();
		self setClientCvar( "g_scriptMainMenu", "main" );
	}

	if ( !isdefined( self.spec_black ) )
	{
		self.spec_black = newClientHudElem( self );
		self.spec_black.archived = false;
		self.spec_black.x = 0;
		self.spec_black.y = 0;
		self.spec_black.alpha = 1;
		self.spec_black.sort = 9990;	// Clock is set to 9999
		self.spec_black setShader( "black", 640, 480 );
	}

	switch ( whyHere )
	{
	  case "round":	text = level.blackRound;	break;
	  case "death":	text = level.blackDeath;	break;
	  case "kick": 	text = level.blackKicked; 	break;
	  case "spec": 	text = level.blackSpec; 	break;
	  default:  	text = undefined;		break;
	}

	if ( isdefined( text ) )
	{
		if ( !isdefined( self.spec_title ) )
		{
			self.spec_title = newClientHudElem( self );
			self.spec_title.archived = false;
			self.spec_title.x = 320;
			self.spec_title.y = 200;
			self.spec_title.alignX = "center";
			self.spec_title.alignY = "middle";
			self.spec_title.sort = 9991;
			self.spec_title.fontScale = 2.0;
			self.spec_title setText( text );
		}
	}

	if ( whyHere != "kick" )
	{
		self thread _removeSpecBlack();
		self thread _msgSpecBlack( "spawned" );
	}

	for (;;)
	{
		self.spectatorclient = self getEntityNumber();
		wait( 0.05 );	// Stay put until next round
	}
}

//
_msgSpecBlack( msg )
{
	self endon( "end_spectoblack" );
	self endon( "remove_specblack" );

	self waittill( msg );
	self notify( "remove_specblack" );
	return;
}

//
_removeSpecBlack()
{
	self endon( "end_spectoblack" );

	self waittill( "remove_specblack" );
	if ( isdefined( self.spec_black ) )
		self.spec_black destroy();
	if ( isdefined( self.spec_title ) )
		self.spec_title destroy();
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
