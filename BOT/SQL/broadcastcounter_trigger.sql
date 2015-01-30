use emarketing ;
-- use derrick ;
drop trigger if exists broadcaster_counter_trigger ; 
delimiter ~

-- create trigger broadcaster_counter_trigger before update on derrick.campaigns 
create trigger broadcaster_counter_trigger before update on emarketing.campaigns 
	for each row  
	begin 
/* 		emarketing.settings.BroadcastCounter
                emarketing.settings.MaxBroadcastCounter

                system.server.MaxBroadCastCounter
                system.server.BroadCastCounter

                emarketing.shared_server_broadcasters.broadcasters
                emarketing.shared_server_broadcasters.maxbroadcasters */

		set @settings = @shared = @server = null ;

		IF NEW.statusInt != OLD.statusInt 
		THEN 
--	 		//if we have all three broadcast counter values, we only update shared_server_broadcasters and settings. otherwise, we will be decrementing settings and server.
/*			select settings.BroadcastCounter, server.BroadCastCounter, shared_server_broadcasters.broadcasters into @settings, @server, @shared 
			from 
				derrick.accounts as accounts
				inner join derrick.settings as settings on accounts.AccountID = settings.AccountID and settings.AccountID = OLD.AccountID
				left join derrick.profiles as profiles on profiles.ID = OLD.ProfileID and accounts.AccountID = profiles.AccountID
				left join derrick.server as server on profiles.BroadcastServer = server.name and server.removed = 0 
				left join derrick.shared_server_broadcasters as shared_server_broadcasters on server.id = shared_server_broadcasters.serverid and accounts.AccountID = shared_server_broadcasters.AccountID
				left join derrick.managedservers as managedservers on managedservers.id = OLD.profileid and managedservers.removed = 0
			limit 1 ; */
			select settings.BroadcastCounter, server.BroadCastCounter, shared_server_broadcasters.broadcasters into @settings, @server, @shared 
			from 
				system.accounts as accounts
				inner join emarketing.settings as settings on accounts.AccountID = settings.AccountID and settings.AccountID = OLD.AccountID
				left join emarketing.profiles as profiles on profiles.ID = OLD.ProfileID and accounts.AccountID = profiles.AccountID
				left join system.server as server on profiles.BroadcastServer = server.name and server.removed = 0 
				left join emarketing.shared_server_broadcasters as shared_server_broadcasters on server.id = shared_server_broadcasters.serverid and accounts.AccountID = shared_server_broadcasters.AccountID
				left join emarketing.managedservers as managedservers on managedservers.id = OLD.profileid and managedservers.removed = 0
			limit 1 ;

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
                                                        settings.BroadcastCounter = settings.BroadcastCounter + 1
--                                                      , server.BroadCastCounter = server.BroadCastCounter + 1
                                                        , shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters + 1
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
                                                        settings.BroadcastCounter = settings.BroadcastCounter + 1
                                                      , server.BroadCastCounter = server.BroadCastCounter + 1
--                                                        , shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters + 1
                                                ;
					END IF ;
				END IF ;
			END IF ;

			IF OLD.statusInt not in('1000','400','500','600','365')
			THEN
				IF NEW.statusInt in('1000','400','500','600','365')
				THEN
-- 					we have just moved a campaign into a state in which it should consume a broadcaster so we should decrement the broadcastcounters
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
							settings.BroadcastCounter = settings.BroadcastCounter - 1
--							, server.BroadCastCounter = server.BroadCastCounter - 1
							, shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters - 1
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
                                                        settings.BroadcastCounter = settings.BroadcastCounter - 1
                                                      , server.BroadCastCounter = server.BroadCastCounter - 1
--                                                        , shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters - 1
                                                ;*/
						update 
							system.accounts as accounts
							inner join emarketing.settings as settings on accounts.AccountID = settings.AccountID and settings.AccountID = OLD.AccountID
							left join emarketing.profiles as profiles on profiles.ID = OLD.ProfileID and accounts.AccountID = profiles.AccountID
							left join system.server as server on profiles.BroadcastServer = server.name and server.removed = 0 
							left join emarketing.shared_server_broadcasters as shared_server_broadcasters on server.id = shared_server_broadcasters.serverid and accounts.AccountID = shared_server_broadcasters.AccountID
							left join emarketing.managedservers as managedservers on managedservers.id = OLD.profileid and managedservers.removed = 0
						set 
							settings.BroadcastCounter = settings.BroadcastCounter - 1
--							, server.BroadCastCounter = server.BroadCastCounter - 1
							, shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters - 1
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
                                                        settings.BroadcastCounter = settings.BroadcastCounter - 1
                                                      , server.BroadCastCounter = server.BroadCastCounter - 1
--                                                        , shared_server_broadcasters.broadcasters = shared_server_broadcasters.broadcasters - 1
                                                ;
					END IF ;
				END IF ;
			END IF ;
		END IF ;
	END ;
~

delimiter ;
