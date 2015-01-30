use emarketing ;
-- use derrick ;
drop trigger if exists broadcaster_counter_trigger ; 
drop trigger if exists before_campaign_update_trigger ;
delimiter ~

-- create trigger broadcaster_counter_trigger before update on derrick.campaigns 
create trigger broadcaster_counter_trigger before update on emarketing.campaigns 
	for each row  
	begin 
-- 		prevent users from setting schedule time for the past.
-- 		from before_campaign_update_trigger
		IF NEW.schedule < NOW() and OLD.statusint in('700','100','0')
		THEN
			set NEW.schedule := NOW() ;
		END IF ;

		IF 1 = NEW.removed and 0 = OLD.removed
		THEN
			set NEW.statusInt := '900' ;
		END IF ;

/* 		emarketing.settings.BroadcastCounter
                emarketing.settings.MaxBroadcastCounter

                system.server.MaxBroadCastCounter
                system.server.BroadCastCounter

                emarketing.shared_server_broadcasters.broadcasters
                emarketing.shared_server_broadcasters.maxbroadcasters */

-- 		set @settings = @shared = @server = null ;
		set @settings = @max_settings = @shared = @max_shared = @server = @max_server = null ;
-- 		logic to ensure we do not go over the max values
		set @add_settings = @add_shared = @add_server = 0 ;

		IF NEW.statusInt != OLD.statusInt 
		THEN 
-- 			select settings.BroadcastCounter. server.BroadCastCounter, shared_server_broadcasters.broadcasters into @settings, @server, @shared 
			select settings.BroadcastCounter, settings.MaxBroadcastCounter, server.BroadCastCounter, server.maxbroadcastcounter, shared_server_broadcasters.broadcasters, shared_server_broadcasters.maxbroadcasters into @settings,@max_settings, @server, @max_server, @shared, @max_shared 
			from 
				system.accounts as accounts
				inner join emarketing.settings as settings on accounts.AccountID = settings.AccountID and settings.AccountID = OLD.AccountID
				left join emarketing.profiles as profiles on profiles.ID = OLD.ProfileID and accounts.AccountID = profiles.AccountID
				left join system.server as server on profiles.BroadcastServer = server.name and server.removed = 0 
				left join emarketing.shared_server_broadcasters as shared_server_broadcasters on server.id = shared_server_broadcasters.serverid and accounts.AccountID = shared_server_broadcasters.AccountID
				left join emarketing.managedservers as managedservers on managedservers.id = OLD.profileid and managedservers.removed = 0
			limit 1 ;

-- 			logic to ensure we do not go over the max values
			if @settings + 1 <= @max_settings
			then
				set @add_settings := 1 ;
			end if ;

			if @shared + 1 <= @max_shared
			then
				set @add_shared := 1 ;
			end if ;

			if @server + 1 <= @max_server
			then
				set @add_sever := 1 ;
			end if ;

			

			IF OLD.statusInt in('1000','400','500','600','365')
			THEN
				IF NEW.statusInt not in ('1000','400','500','600','365')
				THEN
-- 					we have just moved a campaign into a state in which it is no longer using a broadcaster so we should increment the broadcastcounters
					IF @settings is not null and @server is not null and @shared is not null
					THEN
--				 		if we have all three broadcast counter values, we only update shared_server_broadcasters and settings. otherwise, we will be adjusting settings and server.
/*						update 
							derrick.accounts as accounts
							inner join derrick.settings as settings on accounts.AccountID = settings.AccountID and settings.AccountID = OLD.AccountID
							left join derrick.profiles as profiles on profiles.ID = OLD.ProfileID and accounts.AccountID = profiles.AccountID
							left join derrick.server as server on profiles.BroadcastServer = server.name and server.removed = 0 
							left join derrick.shared_server_broadcasters as shared_server_broadcasters on server.id = shared_server_broadcasters.serverid and accounts.AccountID = shared_server_broadcasters.AccountID
							left join derrick.managedservers as managedservers on managedservers.id = OLD.profileid and managedservers.removed = 0
						set 
							settings.BroadcastCounter = settings.BroadcastCounter + 1
--							, server.BroadCastCounter = server.BroadCastCounter + 1
							, shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters + 1
						;
					ELSE
						update
                                                        derrick.accounts as accounts
                                                        inner join derrick.settings as settings on accounts.AccountID = settings.AccountID and settings.AccountID = OLD.AccountID
                                                        left join derrick.profiles as profiles on profiles.ID = OLD.ProfileID and accounts.AccountID = profiles.AccountID
                                                        left join derrick.server as server on profiles.BroadcastServer = server.name and server.removed = 0
                                                        left join derrick.shared_server_broadcasters as shared_server_broadcasters on server.id = shared_server_broadcasters.serverid and accounts.AccountID = shared_server_broadcasters.AccountID
                                                        left join derrick.managedservers as managedservers on managedservers.id = OLD.profileid and managedservers.removed = 0
                                                set
                                                        settings.BroadcastCounter = settings.BroadcastCounter + 1
                                                      , server.BroadCastCounter = server.BroadCastCounter + 1
--                                                        , shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters + 1
                                                ; */
                                                update 
                                                        system.accounts as accounts
                                                        inner join emarketing.settings as settings on accounts.AccountID = settings.AccountID and settings.AccountID = OLD.AccountID
                                                        left join emarketing.profiles as profiles on profiles.ID = OLD.ProfileID and accounts.AccountID = profiles.AccountID
                                                        left join system.server as server on profiles.BroadcastServer = server.name and server.removed = 0  
                                                        left join emarketing.shared_server_broadcasters as shared_server_broadcasters on server.id = shared_server_broadcasters.serverid and accounts.AccountID = shared_server_broadcasters.AccountID
                                                        left join emarketing.managedservers as managedservers on managedservers.id = OLD.profileid and managedservers.removed = 0
                                                set 
--                                                        settings.BroadcastCounter = settings.BroadcastCounter + 1
                                                        settings.BroadcastCounter = settings.BroadcastCounter + @add_settings
--                                                      , server.BroadCastCounter = server.BroadCastCounter + 1
--                                                      , server.BroadCastCounter = server.BroadCastCounter + @add_server
--                                                        , shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters + 1
--                                                        , shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters + @add_shared
                                                ;
                                        ELSE
                                                update
                                                        system.accounts as accounts
                                                        inner join emarketing.settings as settings on accounts.AccountID = settings.AccountID and settings.AccountID = OLD.AccountID
                                                        left join emarketing.profiles as profiles on profiles.ID = OLD.ProfileID and accounts.AccountID = profiles.AccountID
                                                        left join system.server as server on profiles.BroadcastServer = server.name and server.removed = 0
                                                        left join emarketing.shared_server_broadcasters as shared_server_broadcasters on server.id = shared_server_broadcasters.serverid and accounts.AccountID = shared_server_broadcasters.AccountID
                                                        left join emarketing.managedservers as managedservers on managedservers.id = OLD.profileid and managedservers.removed = 0
                                                set
--                                                         settings.BroadcastCounter = settings.BroadcastCounter + 1
                                                        settings.BroadcastCounter = settings.BroadcastCounter + @add_settings
--                                                       , server.BroadCastCounter = server.BroadCastCounter + 1
--                                                      , server.BroadCastCounter = server.BroadCastCounter + @add_serer
--                                                        , shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters + 1
--                                                        , shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters + @add_shared
                                                ;
					END IF ;
				END IF ;
			END IF ;
		END IF ;
	END ;
~

delimiter ;
