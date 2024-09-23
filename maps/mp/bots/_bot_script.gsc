#include maps\mp\_utility;
#include maps\mp\bots\_bot_utility;

/*
	When the bot gets added into the game.
*/
added()
{
	self endon( "disconnect" );
	
	self set_diff();
	
	if ( randomfloatrange( 0, 1 ) < 0.5 )
	{
		self.pers[ "bots" ][ "behavior" ][ "quickscope" ] = true;
	}
}

/*
	When the bot connects to the game.
*/
connected()
{
	self endon( "disconnect" );
	
	self.killerlocation = undefined;
	self.lastkiller = undefined;
	self.bot_change_class = true;
	
	self thread difficulty();
	self thread teamWatch();
	self thread classWatch();
	self thread onBotSpawned();
	self thread onSpawned();
}

/*
	The callback for when the bot gets killed.
*/
onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	self.killerlocation = undefined;
	self.lastkiller = undefined;
	
	if ( !isdefined( self ) || !isdefined( self.team ) )
	{
		return;
	}
	
	if ( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE" )
	{
		return;
	}
	
	if ( iDamage <= 0 )
	{
		return;
	}
	
	if ( !isdefined( eAttacker ) || !isdefined( eAttacker.team ) )
	{
		return;
	}
	
	if ( eAttacker == self )
	{
		return;
	}
	
	if ( level.teambased && eAttacker.team == self.team )
	{
		return;
	}
	
	if ( !isdefined( eInflictor ) || eInflictor.classname != "player" )
	{
		return;
	}
	
	if ( !isalive( eAttacker ) )
	{
		return;
	}
	
	self.killerlocation = eAttacker.origin;
	self.lastkiller = eAttacker;
}

/*
	The callback for when the bot gets damaged.
*/
onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( !isdefined( self ) || !isdefined( self.team ) )
	{
		return;
	}
	
	if ( !isalive( self ) )
	{
		return;
	}
	
	if ( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE" )
	{
		return;
	}
	
	if ( iDamage <= 0 )
	{
		return;
	}
	
	if ( !isdefined( eAttacker ) || !isdefined( eAttacker.team ) )
	{
		return;
	}
	
	if ( eAttacker == self )
	{
		return;
	}
	
	if ( level.teambased && eAttacker.team == self.team )
	{
		return;
	}
	
	if ( !isdefined( eInflictor ) || eInflictor.classname != "player" )
	{
		return;
	}
	
	if ( !isalive( eAttacker ) )
	{
		return;
	}
	
	self bot_cry_for_help( eAttacker );
	
	self SetAttacker( eAttacker );
}

/*
	When the bot gets attacked, have the bot ask for help from teammates.
*/
bot_cry_for_help( attacker )
{
	if ( !level.teambased )
	{
		return;
	}
	
	theTime = gettime();
	
	if ( isdefined( self.help_time ) && theTime - self.help_time < 1000 )
	{
		return;
	}
	
	self.help_time = theTime;
	
	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[ i ];
		
		if ( !player is_bot() )
		{
			continue;
		}
		
		if ( !isdefined( player.team ) )
		{
			continue;
		}
		
		if ( !player IsPlayerModelOK() )
		{
			continue;
		}
		
		if ( !isalive( player ) )
		{
			continue;
		}
		
		if ( player == self )
		{
			continue;
		}
		
		if ( player.team != self.team )
		{
			continue;
		}
		
		dist = player.pers[ "bots" ][ "skill" ][ "help_dist" ];
		dist *= dist;
		
		if ( distancesquared( self.origin, player.origin ) > dist )
		{
			continue;
		}
		
		if ( randomint( 100 ) < 50 )
		{
			self SetAttacker( attacker );
			
			if ( randomint( 100 ) > 70 )
			{
				break;
			}
		}
	}
}

/*
	Sets the bot difficulty.
*/
set_diff()
{
	rankVar = getcvarint( "bots_skill" );
	
	switch ( rankVar )
	{
		case 0:
			self.pers[ "bots" ][ "skill" ][ "base" ] = RoundNum( random_normal_distribution( 3.5, 1.75, 1, 7 ) );
			break;
			
		case 8:
			break;
			
		case 9:
			self.pers[ "bots" ][ "skill" ][ "base" ] = randomintrange( 1, 7 );
			self.pers[ "bots" ][ "skill" ][ "aim_time" ] = 0.05 * randomintrange( 1, 20 );
			self.pers[ "bots" ][ "skill" ][ "init_react_time" ] = 50 * randomint( 100 );
			self.pers[ "bots" ][ "skill" ][ "reaction_time" ] = 50 * randomint( 100 );
			self.pers[ "bots" ][ "skill" ][ "no_trace_ads_time" ] = 50 * randomint( 100 );
			self.pers[ "bots" ][ "skill" ][ "no_trace_look_time" ] = 50 * randomint( 100 );
			self.pers[ "bots" ][ "skill" ][ "remember_time" ] = 50 * randomint( 100 );
			self.pers[ "bots" ][ "skill" ][ "fov" ] = randomfloatrange( -1, 1 );
			
			randomNum = randomintrange( 500, 25000 );
			self.pers[ "bots" ][ "skill" ][ "dist_start" ] = randomNum;
			self.pers[ "bots" ][ "skill" ][ "dist_max" ] = randomNum * 2;
			
			self.pers[ "bots" ][ "skill" ][ "spawn_time" ] = 0.05 * randomint( 20 );
			self.pers[ "bots" ][ "skill" ][ "help_dist" ] = randomintrange( 500, 25000 );
			self.pers[ "bots" ][ "skill" ][ "semi_time" ] = randomfloatrange( 0.05, 1 );
			self.pers[ "bots" ][ "skill" ][ "shoot_after_time" ] = randomfloatrange( 0.05, 1 );
			self.pers[ "bots" ][ "skill" ][ "aim_offset_time" ] = randomfloatrange( 0.05, 1 );
			self.pers[ "bots" ][ "skill" ][ "aim_offset_amount" ] = randomfloatrange( 0.05, 1 );
			self.pers[ "bots" ][ "skill" ][ "bone_update_interval" ] = randomfloatrange( 0.05, 1 );
			self.pers[ "bots" ][ "skill" ][ "bones" ] = "j_head,j_spine4,j_ankle_ri,j_ankle_le";
			
			self.pers[ "bots" ][ "behavior" ][ "strafe" ] = randomint( 100 );
			self.pers[ "bots" ][ "behavior" ][ "nade" ] = randomint( 100 );
			self.pers[ "bots" ][ "behavior" ][ "camp" ] = randomint( 100 );
			self.pers[ "bots" ][ "behavior" ][ "follow" ] = randomint( 100 );
			self.pers[ "bots" ][ "behavior" ][ "crouch" ] = randomint( 100 );
			self.pers[ "bots" ][ "behavior" ][ "switch" ] = randomint( 100 );
			self.pers[ "bots" ][ "behavior" ][ "class" ] = randomint( 100 );
			self.pers[ "bots" ][ "behavior" ][ "jump" ] = randomint( 100 );
			break;
			
		default:
			self.pers[ "bots" ][ "skill" ][ "base" ] = rankVar;
			break;
	}
}

/*
	Updates the bot's difficulty variables.
*/
difficulty()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		if ( getcvarint( "bots_skill" ) != 9 )
		{
			switch ( self.pers[ "bots" ][ "skill" ][ "base" ] )
			{
				case 1:
					self.pers[ "bots" ][ "skill" ][ "aim_time" ] = 0.6;
					self.pers[ "bots" ][ "skill" ][ "init_react_time" ] = 1500;
					self.pers[ "bots" ][ "skill" ][ "reaction_time" ] = 1000;
					self.pers[ "bots" ][ "skill" ][ "no_trace_ads_time" ] = 500;
					self.pers[ "bots" ][ "skill" ][ "no_trace_look_time" ] = 600;
					self.pers[ "bots" ][ "skill" ][ "remember_time" ] = 750;
					self.pers[ "bots" ][ "skill" ][ "fov" ] = 0.7;
					self.pers[ "bots" ][ "skill" ][ "dist_max" ] = 2500;
					self.pers[ "bots" ][ "skill" ][ "dist_start" ] = 1000;
					self.pers[ "bots" ][ "skill" ][ "spawn_time" ] = 0.75;
					self.pers[ "bots" ][ "skill" ][ "help_dist" ] = 0;
					self.pers[ "bots" ][ "skill" ][ "semi_time" ] = 0.9;
					self.pers[ "bots" ][ "skill" ][ "shoot_after_time" ] = 1;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_time" ] = 1.5;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_amount" ] = 4;
					self.pers[ "bots" ][ "skill" ][ "bone_update_interval" ] = 2;
					self.pers[ "bots" ][ "skill" ][ "bones" ] = "j_spine4,j_ankle_le,j_ankle_ri";
					self.pers[ "bots" ][ "skill" ][ "ads_fov_multi" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "ads_aimspeed_multi" ] = 0.5;
					
					self.pers[ "bots" ][ "behavior" ][ "strafe" ] = 0;
					self.pers[ "bots" ][ "behavior" ][ "nade" ] = 10;
					self.pers[ "bots" ][ "behavior" ][ "camp" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "follow" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "crouch" ] = 20;
					self.pers[ "bots" ][ "behavior" ][ "switch" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "class" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "jump" ] = 0;
					break;
					
				case 2:
					self.pers[ "bots" ][ "skill" ][ "aim_time" ] = 0.55;
					self.pers[ "bots" ][ "skill" ][ "init_react_time" ] = 1000;
					self.pers[ "bots" ][ "skill" ][ "reaction_time" ] = 800;
					self.pers[ "bots" ][ "skill" ][ "no_trace_ads_time" ] = 1000;
					self.pers[ "bots" ][ "skill" ][ "no_trace_look_time" ] = 1250;
					self.pers[ "bots" ][ "skill" ][ "remember_time" ] = 1500;
					self.pers[ "bots" ][ "skill" ][ "fov" ] = 0.65;
					self.pers[ "bots" ][ "skill" ][ "dist_max" ] = 3000;
					self.pers[ "bots" ][ "skill" ][ "dist_start" ] = 1500;
					self.pers[ "bots" ][ "skill" ][ "spawn_time" ] = 0.65;
					self.pers[ "bots" ][ "skill" ][ "help_dist" ] = 500;
					self.pers[ "bots" ][ "skill" ][ "semi_time" ] = 0.75;
					self.pers[ "bots" ][ "skill" ][ "shoot_after_time" ] = 0.75;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_time" ] = 1;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_amount" ] = 3;
					self.pers[ "bots" ][ "skill" ][ "bone_update_interval" ] = 1.5;
					self.pers[ "bots" ][ "skill" ][ "bones" ] = "j_spine4,j_ankle_le,j_ankle_ri,j_head";
					self.pers[ "bots" ][ "skill" ][ "ads_fov_multi" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "ads_aimspeed_multi" ] = 0.5;
					
					self.pers[ "bots" ][ "behavior" ][ "strafe" ] = 10;
					self.pers[ "bots" ][ "behavior" ][ "nade" ] = 15;
					self.pers[ "bots" ][ "behavior" ][ "camp" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "follow" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "crouch" ] = 15;
					self.pers[ "bots" ][ "behavior" ][ "switch" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "class" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "jump" ] = 10;
					break;
					
				case 3:
					self.pers[ "bots" ][ "skill" ][ "aim_time" ] = 0.4;
					self.pers[ "bots" ][ "skill" ][ "init_react_time" ] = 750;
					self.pers[ "bots" ][ "skill" ][ "reaction_time" ] = 500;
					self.pers[ "bots" ][ "skill" ][ "no_trace_ads_time" ] = 1000;
					self.pers[ "bots" ][ "skill" ][ "no_trace_look_time" ] = 1500;
					self.pers[ "bots" ][ "skill" ][ "remember_time" ] = 2000;
					self.pers[ "bots" ][ "skill" ][ "fov" ] = 0.6;
					self.pers[ "bots" ][ "skill" ][ "dist_max" ] = 4000;
					self.pers[ "bots" ][ "skill" ][ "dist_start" ] = 2250;
					self.pers[ "bots" ][ "skill" ][ "spawn_time" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "help_dist" ] = 750;
					self.pers[ "bots" ][ "skill" ][ "semi_time" ] = 0.65;
					self.pers[ "bots" ][ "skill" ][ "shoot_after_time" ] = 0.65;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_time" ] = 0.75;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_amount" ] = 2.5;
					self.pers[ "bots" ][ "skill" ][ "bone_update_interval" ] = 1;
					self.pers[ "bots" ][ "skill" ][ "bones" ] = "j_spine4,j_spine4,j_ankle_le,j_ankle_ri,j_head";
					self.pers[ "bots" ][ "skill" ][ "ads_fov_multi" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "ads_aimspeed_multi" ] = 0.5;
					
					self.pers[ "bots" ][ "behavior" ][ "strafe" ] = 20;
					self.pers[ "bots" ][ "behavior" ][ "nade" ] = 20;
					self.pers[ "bots" ][ "behavior" ][ "camp" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "follow" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "crouch" ] = 10;
					self.pers[ "bots" ][ "behavior" ][ "switch" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "class" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "jump" ] = 25;
					break;
					
				case 4:
					self.pers[ "bots" ][ "skill" ][ "aim_time" ] = 0.3;
					self.pers[ "bots" ][ "skill" ][ "init_react_time" ] = 600;
					self.pers[ "bots" ][ "skill" ][ "reaction_time" ] = 400;
					self.pers[ "bots" ][ "skill" ][ "no_trace_ads_time" ] = 1000;
					self.pers[ "bots" ][ "skill" ][ "no_trace_look_time" ] = 1500;
					self.pers[ "bots" ][ "skill" ][ "remember_time" ] = 3000;
					self.pers[ "bots" ][ "skill" ][ "fov" ] = 0.55;
					self.pers[ "bots" ][ "skill" ][ "dist_max" ] = 5000;
					self.pers[ "bots" ][ "skill" ][ "dist_start" ] = 3350;
					self.pers[ "bots" ][ "skill" ][ "spawn_time" ] = 0.35;
					self.pers[ "bots" ][ "skill" ][ "help_dist" ] = 1000;
					self.pers[ "bots" ][ "skill" ][ "semi_time" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "shoot_after_time" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_time" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_amount" ] = 2;
					self.pers[ "bots" ][ "skill" ][ "bone_update_interval" ] = 0.75;
					self.pers[ "bots" ][ "skill" ][ "bones" ] = "j_spine4,j_spine4,j_ankle_le,j_ankle_ri,j_head,j_head";
					self.pers[ "bots" ][ "skill" ][ "ads_fov_multi" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "ads_aimspeed_multi" ] = 0.5;
					
					self.pers[ "bots" ][ "behavior" ][ "strafe" ] = 30;
					self.pers[ "bots" ][ "behavior" ][ "nade" ] = 25;
					self.pers[ "bots" ][ "behavior" ][ "camp" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "follow" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "crouch" ] = 10;
					self.pers[ "bots" ][ "behavior" ][ "switch" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "class" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "jump" ] = 35;
					break;
					
				case 5:
					self.pers[ "bots" ][ "skill" ][ "aim_time" ] = 0.25;
					self.pers[ "bots" ][ "skill" ][ "init_react_time" ] = 500;
					self.pers[ "bots" ][ "skill" ][ "reaction_time" ] = 300;
					self.pers[ "bots" ][ "skill" ][ "no_trace_ads_time" ] = 1500;
					self.pers[ "bots" ][ "skill" ][ "no_trace_look_time" ] = 2000;
					self.pers[ "bots" ][ "skill" ][ "remember_time" ] = 4000;
					self.pers[ "bots" ][ "skill" ][ "fov" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "dist_max" ] = 7500;
					self.pers[ "bots" ][ "skill" ][ "dist_start" ] = 5000;
					self.pers[ "bots" ][ "skill" ][ "spawn_time" ] = 0.25;
					self.pers[ "bots" ][ "skill" ][ "help_dist" ] = 1500;
					self.pers[ "bots" ][ "skill" ][ "semi_time" ] = 0.4;
					self.pers[ "bots" ][ "skill" ][ "shoot_after_time" ] = 0.35;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_time" ] = 0.35;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_amount" ] = 1.5;
					self.pers[ "bots" ][ "skill" ][ "bone_update_interval" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "bones" ] = "j_spine4,j_head";
					self.pers[ "bots" ][ "skill" ][ "ads_fov_multi" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "ads_aimspeed_multi" ] = 0.5;
					
					self.pers[ "bots" ][ "behavior" ][ "strafe" ] = 40;
					self.pers[ "bots" ][ "behavior" ][ "nade" ] = 35;
					self.pers[ "bots" ][ "behavior" ][ "camp" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "follow" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "crouch" ] = 10;
					self.pers[ "bots" ][ "behavior" ][ "switch" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "class" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "jump" ] = 50;
					break;
					
				case 6:
					self.pers[ "bots" ][ "skill" ][ "aim_time" ] = 0.2;
					self.pers[ "bots" ][ "skill" ][ "init_react_time" ] = 250;
					self.pers[ "bots" ][ "skill" ][ "reaction_time" ] = 150;
					self.pers[ "bots" ][ "skill" ][ "no_trace_ads_time" ] = 2000;
					self.pers[ "bots" ][ "skill" ][ "no_trace_look_time" ] = 3000;
					self.pers[ "bots" ][ "skill" ][ "remember_time" ] = 5000;
					self.pers[ "bots" ][ "skill" ][ "fov" ] = 0.45;
					self.pers[ "bots" ][ "skill" ][ "dist_max" ] = 10000;
					self.pers[ "bots" ][ "skill" ][ "dist_start" ] = 7500;
					self.pers[ "bots" ][ "skill" ][ "spawn_time" ] = 0.2;
					self.pers[ "bots" ][ "skill" ][ "help_dist" ] = 2000;
					self.pers[ "bots" ][ "skill" ][ "semi_time" ] = 0.25;
					self.pers[ "bots" ][ "skill" ][ "shoot_after_time" ] = 0.25;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_time" ] = 0.25;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_amount" ] = 1;
					self.pers[ "bots" ][ "skill" ][ "bone_update_interval" ] = 0.25;
					self.pers[ "bots" ][ "skill" ][ "bones" ] = "j_spine4,j_head,j_head";
					self.pers[ "bots" ][ "skill" ][ "ads_fov_multi" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "ads_aimspeed_multi" ] = 0.5;
					
					self.pers[ "bots" ][ "behavior" ][ "strafe" ] = 50;
					self.pers[ "bots" ][ "behavior" ][ "nade" ] = 45;
					self.pers[ "bots" ][ "behavior" ][ "camp" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "follow" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "crouch" ] = 10;
					self.pers[ "bots" ][ "behavior" ][ "switch" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "class" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "jump" ] = 75;
					break;
					
				case 7:
					self.pers[ "bots" ][ "skill" ][ "aim_time" ] = 0.1;
					self.pers[ "bots" ][ "skill" ][ "init_react_time" ] = 100;
					self.pers[ "bots" ][ "skill" ][ "reaction_time" ] = 50;
					self.pers[ "bots" ][ "skill" ][ "no_trace_ads_time" ] = 2500;
					self.pers[ "bots" ][ "skill" ][ "no_trace_look_time" ] = 4000;
					self.pers[ "bots" ][ "skill" ][ "remember_time" ] = 7500;
					self.pers[ "bots" ][ "skill" ][ "fov" ] = 0.4;
					self.pers[ "bots" ][ "skill" ][ "dist_max" ] = 15000;
					self.pers[ "bots" ][ "skill" ][ "dist_start" ] = 10000;
					self.pers[ "bots" ][ "skill" ][ "spawn_time" ] = 0.05;
					self.pers[ "bots" ][ "skill" ][ "help_dist" ] = 3000;
					self.pers[ "bots" ][ "skill" ][ "semi_time" ] = 0.1;
					self.pers[ "bots" ][ "skill" ][ "shoot_after_time" ] = 0;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_time" ] = 0;
					self.pers[ "bots" ][ "skill" ][ "aim_offset_amount" ] = 0;
					self.pers[ "bots" ][ "skill" ][ "bone_update_interval" ] = 0.05;
					self.pers[ "bots" ][ "skill" ][ "bones" ] = "j_head";
					self.pers[ "bots" ][ "skill" ][ "ads_fov_multi" ] = 0.5;
					self.pers[ "bots" ][ "skill" ][ "ads_aimspeed_multi" ] = 0.5;
					
					self.pers[ "bots" ][ "behavior" ][ "strafe" ] = 65;
					self.pers[ "bots" ][ "behavior" ][ "nade" ] = 65;
					self.pers[ "bots" ][ "behavior" ][ "camp" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "follow" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "crouch" ] = 5;
					self.pers[ "bots" ][ "behavior" ][ "switch" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "class" ] = 2;
					self.pers[ "bots" ][ "behavior" ][ "jump" ] = 90;
					break;
			}
		}
		
		wait 5;
	}
}

/*
	Makes sure the bot is on a team.
*/
teamWatch()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		while ( !isdefined( self.pers[ "team" ] ) || !allowTeamChoice() )
		{
			wait .05;
		}
		
		wait 0.1;
		
		if ( self.team != "axis" && self.team != "allies" )
		{
			self notify( "menuresponse", game[ "menu_team" ], getcvar( "bots_team" ) );
		}
		
		while ( isdefined( self.pers[ "team" ] ) )
		{
			wait .05;
		}
	}
}

/*
	Chooses a random class
*/
chooseRandomClass()
{
	weap = "";
	weapons = [];
	
	if ( self.team == "axis" )
	{
		weapons[ weapons.size ] = "mp40_mp";
		weapons[ weapons.size ] = "mp44_mp";
		weapons[ weapons.size ] = "kar98k_mp";
		weapons[ weapons.size ] = "kar98k_sniper_mp";
		weapons[ weapons.size ] = "shotgun_mp";
		weapons[ weapons.size ] = "g43_mp";
	}
	else
	{
		if ( game[ "allies" ] == "american" )
		{
			weapons[ weapons.size ] = "shotgun_mp";
			weapons[ weapons.size ] = "bar_mp";
			weapons[ weapons.size ] = "thompson_mp";
			weapons[ weapons.size ] = "springfield_mp";
			weapons[ weapons.size ] = "m1garand_mp";
			weapons[ weapons.size ] = "m1carbine_mp";
			weapons[ weapons.size ] = "greasegun_mp";
		}
		else if ( game[ "allies" ] == "british" )
		{
			weapons[ weapons.size ] = "shotgun_mp";
			weapons[ weapons.size ] = "sten_mp";
			weapons[ weapons.size ] = "bren_mp";
			weapons[ weapons.size ] = "enfield_mp";
			weapons[ weapons.size ] = "enfield_scope_mp";
			weapons[ weapons.size ] = "m1garand_mp";
			weapons[ weapons.size ] = "thompson_mp";
		}
		else
		{
			weapons[ weapons.size ] = "shotgun_mp";
			weapons[ weapons.size ] = "ppsh_mp";
			weapons[ weapons.size ] = "mosin_nagant_mp";
			weapons[ weapons.size ] = "mosin_nagant_sniper_mp";
			weapons[ weapons.size ] = "SVT40_mp";
			weapons[ weapons.size ] = "PPS42_mp";
		}
	}
	
	weap = weapons[ randomint( weapons.size ) ];
	
	return weap;
}

/*
	Selects a class for the bot.
*/
classWatch()
{
	self endon( "disconnect" );
	
	// cod2 has to wait this long or else theres a crash?
	wait 3;
	
	for ( ;; )
	{
		while ( !isdefined( self.pers[ "team" ] ) || !allowClassChoice() )
		{
			wait .05;
		}
		
		wait 0.5;
		
		if ( !isdefined( self.pers[ "weapon" ] ) || self.pers[ "weapon" ] == "" || !isdefined( self.bot_change_class ) )
		{
			self notify( "menuresponse", game[ "menu_weapon_" + self.team ], self chooseRandomClass() );
		}
		
		self.bot_change_class = true;
		
		while ( isdefined( self.pers[ "team" ] ) && isdefined( self.pers[ "weapon" ] ) && self.pers[ "weapon" ] != "" && isdefined( self.bot_change_class ) )
		{
			wait .05;
		}
	}
}

/*
	When the bot spawns.
*/
onSpawned()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		self waittill( "spawned_player" );
		
		if ( randomint( 100 ) <= self.pers[ "bots" ][ "behavior" ][ "class" ] )
		{
			self.bot_change_class = undefined;
		}
		
		self.bot_lock_goal = false;
		self.help_time = undefined;
		self.bot_was_follow_script_update = undefined;
	}
}

/*
	When the bot spawned, after the difficulty wait. Start the logic for the bot.
*/
onBotSpawned()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	for ( ;; )
	{
		self waittill( "bot_spawned" );
		
		self thread start_bot_threads();
	}
}

/*
	Starts all the bot thinking
*/
start_bot_threads()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "death" );
	
	self thread doReloadCancel();
	self thread bot_weapon_think();

	self thread bot_revenge_think();
	self thread follow_target();
	self thread bot_listen_to_steps();
	self thread bot_uav_think();

	if ( getcvarint( "bots_play_nade" ) )
	{
		// self thread bot_use_grenade_think();
	}

	if ( getcvarint( "bots_play_obj" ) )
	{
	}
}

/*
	Changes to the weap
*/
changeToWeapon( weap )
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if ( !self hasweapon( weap ) )
	{
		return false;
	}
	
	self BotBuiltinBotWeapon( weap );
	
	if ( self getcurrentweapon() == weap )
	{
		return true;
	}
	
	self waittill_any_timeout( 5, "weapon_change" );
	
	return ( self getcurrentweapon() == weap );
}

/*
	Clears goal when events death
*/
stop_go_target_on_death( tar )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "new_goal" );
	self endon( "bad_path" );
	self endon( "goal" );
	
	tar waittill_either( "death", "disconnect" );
	
	self ClearScriptGoal();
}

/*
	Bot logic for UAV detection here. Checks for UAV and players who are shooting.
*/
bot_uav_think_loop()
{
	dist = self.pers[ "bots" ][ "skill" ][ "help_dist" ];
	dist *= dist * 8;
	
	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[ i ];
		
		if ( !player IsPlayerModelOK() )
		{
			continue;
		}
		
		if ( player == self )
		{
			continue;
		}
		
		if ( !isdefined( player.team ) )
		{
			continue;
		}
		
		if ( player.sessionstate != "playing" )
		{
			continue;
		}
		
		if ( level.teambased && player.team == self.team )
		{
			continue;
		}
		
		if ( !isalive( player ) )
		{
			continue;
		}
		
		distFromPlayer = distancesquared( self.origin, player.origin );
		
		if ( distFromPlayer > dist )
		{
			continue;
		}
		
		if ( player.bots_firing )
		{
			self BotNotifyBotEvent( "uav_target", "start", player );
			
			distSq = self.pers[ "bots" ][ "skill" ][ "help_dist" ] * self.pers[ "bots" ][ "skill" ][ "help_dist" ];
			
			if ( distFromPlayer < distSq && bullettracepassed( self getEyePos(), player getTagOrigin( "j_spine4" ), false, player ) )
			{
				self SetAttacker( player );
			}
			
			if ( !self HasScriptGoal() && !self.bot_lock_goal )
			{
				self SetScriptGoal( player.origin, 128 );
				self thread stop_go_target_on_death( player );
				
				if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				{
					self ClearScriptGoal();
				}
				
				self BotNotifyBotEvent( "uav_target", "stop", player );
			}
			
			break;
		}
	}
}

/*
	Bot logic for UAV detection here. Checks for UAV and players who are shooting.
*/
bot_uav_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	for ( ;; )
	{
		wait 0.75;
		
		if ( self.pers[ "bots" ][ "skill" ][ "base" ] <= 1 )
		{
			continue;
		}
		
		self bot_uav_think_loop();
	}
}

/*
	Bot logic for detecting nearby players.
*/
bot_listen_to_steps_loop()
{
	dist = level.bots_listendist;
	
	dist *= dist;
	
	heard = undefined;
	
	for ( i = level.players.size - 1 ; i >= 0; i-- )
	{
		player = level.players[ i ];
		
		if ( !player IsPlayerModelOK() )
		{
			continue;
		}
		
		if ( player == self )
		{
			continue;
		}
		
		if ( level.teambased && self.team == player.team )
		{
			continue;
		}
		
		if ( player.sessionstate != "playing" )
		{
			continue;
		}
		
		if ( !isalive( player ) )
		{
			continue;
		}
		
		if ( lengthsquared( player getVelocity() ) < 20000 )
		{
			continue;
		}
		
		if ( distancesquared( player.origin, self.origin ) > dist )
		{
			continue;
		}
		
		heard = player;
		break;
	}
	
	if ( !isdefined( heard ) )
	{
		return;
	}
	
	self BotNotifyBotEvent( "heard_target", "start", heard );
	
	if ( bullettracepassed( self getEyePos(), heard getTagOrigin( "j_spine4" ), false, heard ) )
	{
		self SetAttacker( heard );
		return;
	}
	
	if ( self HasScriptGoal() || self.bot_lock_goal )
	{
		return;
	}
	
	self SetScriptGoal( heard.origin, 64 );
	
	if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
	{
		self ClearScriptGoal();
	}
	
	self BotNotifyBotEvent( "heard_target", "stop", heard );
}

/*
	Bot logic for detecting nearby players.
*/
bot_listen_to_steps()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for ( ;; )
	{
		wait 1;
		
		if ( self.pers[ "bots" ][ "skill" ][ "base" ] < 3 )
		{
			continue;
		}
		
		self bot_listen_to_steps_loop();
	}
}

/*
	Goes to the target's location if it had one
*/
follow_target_loop()
{
	threat = self getThreat();
	
	if ( !isplayer( threat ) )
	{
		return;
	}
	
	if ( randomint( 100 ) > self.pers[ "bots" ][ "behavior" ][ "follow" ] * 5 )
	{
		return;
	}
	
	self BotNotifyBotEvent( "follow_threat", "start", threat );
	
	self SetScriptGoal( threat.origin, 64 );
	self thread stop_go_target_on_death( threat );
	
	if ( self waittill_any_return( "new_goal", "goal", "bad_path" ) != "new_goal" )
	{
		self ClearScriptGoal();
	}
	
	self BotNotifyBotEvent( "follow_threat", "stop", threat );
}

/*
	Goes to the target's location if it had one
*/
follow_target()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	for ( ;; )
	{
		wait 1;
		
		if ( self HasScriptGoal() || self.bot_lock_goal )
		{
			continue;
		}
		
		if ( !self HasThreat() )
		{
			continue;
		}
		
		self follow_target_loop();
	}
}

/*
	bots will go to their target's kill location
*/
bot_revenge_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	if ( self.pers[ "bots" ][ "skill" ][ "base" ] <= 1 )
	{
		return;
	}
	
	if ( isdefined( self.lastkiller ) && isalive( self.lastkiller ) )
	{
		if ( bullettracepassed( self getEyePos(), self.lastkiller getTagOrigin( "j_spine4" ), false, self.lastkiller ) )
		{
			self SetAttacker( self.lastkiller );
		}
	}
	
	if ( !isdefined( self.killerlocation ) )
	{
		return;
	}
	
	loc = self.killerlocation;
	
	for ( ;; )
	{
		wait( randomintrange( 1, 5 ) );
		
		if ( self HasScriptGoal() || self.bot_lock_goal )
		{
			return;
		}
		
		if ( randomint( 100 ) < 75 )
		{
			return;
		}
		
		self BotNotifyBotEvent( "revenge", "start", loc, self.lastkiller );
		
		self SetScriptGoal( loc, 64 );
		
		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
		{
			self ClearScriptGoal();
		}
		
		self BotNotifyBotEvent( "revenge", "stop", loc, self.lastkiller );
	}
}

/*
	Reload cancels
*/
doReloadCancel_loop()
{
	ret = self waittill_either_return( "reload", "weapon_change" );
	
	if ( self BotIsFrozen() )
	{
		return;
	}
	
	if ( self isPlantingOrDefusing() )
	{
		return;
	}
	
	curWeap = self getcurrentweapon();
	
	if ( !isWeaponDroppable( curWeap ) )
	{
		return;
	}
	
	if ( ret == "reload" )
	{
		// check single reloads
		if ( self getweaponslotclipammo( self getWeaponSlot( curWeap ) ) < WeaponClipSize( curWeap ) )
		{
			return;
		}
	}
	
	// check difficulty
	if ( self.pers[ "bots" ][ "skill" ][ "base" ] <= 3 )
	{
		return;
	}
	
	// check if got another weapon
	weaponslist = self getWeaponsListPrimaries();
	weap = "";
	
	while ( weaponslist.size )
	{
		weapon = weaponslist[ randomint( weaponslist.size ) ];
		weaponslist = array_remove( weaponslist, weapon );
		
		if ( !isWeaponDroppable( curWeap ) )
		{
			continue;
		}
		
		if ( curWeap == weapon || weapon == "none" || weapon == "" )
		{
			continue;
		}
		
		weap = weapon;
		break;
	}
	
	if ( weap == "" )
	{
		return;
	}
	
	// do the cancel
	wait 0.1;
	self thread changeToWeapon( weap );
	wait 0.25;
	self thread changeToWeapon( curWeap );
	wait 2;
}

/*
	Reload cancels
*/
doReloadCancel()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for ( ;; )
	{
		self doReloadCancel_loop();
	}
}

/*
	Bot logic for switching weapons.
*/
bot_weapon_think_loop( data )
{
	ret = self waittill_any_timeout( randomintrange( 2, 4 ), "bot_force_check_switch" );
	
	if ( self BotIsFrozen() )
	{
		return;
	}
	
	if ( self isPlantingOrDefusing() )
	{
		return;
	}
	
	hasTarget = self HasThreat();
	curWeap = self getcurrentweapon();
	
	force = ( ret == "bot_force_check_switch" );
	
	if ( data.first )
	{
		data.first = false;
		
		if ( randomint( 100 ) > self.pers[ "bots" ][ "behavior" ][ "initswitch" ] )
		{
			return;
		}
	}
	else
	{
		if ( curWeap != "none" && self getAmmoCount( curWeap ) )
		{
			if ( randomint( 100 ) > self.pers[ "bots" ][ "behavior" ][ "switch" ] )
			{
				return;
			}
			
			if ( hasTarget )
			{
				return;
			}
		}
		else
		{
			force = true;
		}
	}
	
	weaponslist = self getWeaponsListPrimaries();
	weap = "";
	
	while ( weaponslist.size )
	{
		weapon = weaponslist[ randomint( weaponslist.size ) ];
		weaponslist = array_remove( weaponslist, weapon );
		
		if ( !self getAmmoCount( weapon ) && !force )
		{
			continue;
		}
		
		if ( !isWeaponDroppable( weapon ) )
		{
			continue;
		}
		
		if ( curWeap == weapon || weapon == "none" || weapon == "" )
		{
			continue;
		}
		
		weap = weapon;
		break;
	}
	
	if ( weap == "" )
	{
		return;
	}
	
	self thread changeToWeapon( weap );
}

/*
	Bot logic for switching weapons.
*/
bot_weapon_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	data = spawnstruct();
	data.first = true;
	
	for ( ;; )
	{
		self bot_weapon_think_loop( data );
	}
}
