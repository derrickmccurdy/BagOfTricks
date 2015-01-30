use emarketing ;
drop procedure if exists emarketing.campaign_prep_test ;
drop procedure if exists emarketing.campaign_prep ;
delimiter ~

-- CREATE  PROCEDURE campaign_prep_test()
CREATE  PROCEDURE campaign_prep()
BEGIN

	DECLARE diteration_id bigint default 0 ;
        DECLARE done INT DEFAULT 0 ;
	DECLARE dqueue_id int(10) ;
	DECLARE dAccountID int(10) ;
	DECLARE dcampaign_id int(10) ;
        DECLARE dfqtname varchar(100) DEFAULT "" ;
        DECLARE dsuppression_fqtname varchar(100) DEFAULT "" ;
        DECLARE dfqtemp_table_name varchar(100) DEFAULT "" ;
	DECLARE dstartIndex int(10) ;
	DECLARE dendIndex int(10) ;
	DECLARE dlist_segment_conditionals varchar(254) ;
        DECLARE dtschema varchar(100) DEFAULT "" ;
        DECLARE dtname varchar(100) DEFAULT "" ;

	set @diteration_id := datastore.email_hash(now()) ;
	update emarketing.prepare_campaign set status_int = 1000, iteration_id = @diteration_id where status_int = 0 ;

	BEGIN

        DECLARE cur1 CURSOR FOR SELECT
			iteration_id as iteration_id,
			id AS dqueue_id,
			AccountID AS dAccountID,
			CONCAT("d",AccountID) AS dtschema,
			campaign_id AS dcampaign_id,
			fqtname AS dfqtname ,
			SUBSTR(fqtname, INSTR(fqtname,'.')+1) AS dtname,
			suppression_fqtname AS dsuppression_fqtname,
			fqtemp_table_name AS dfqtemp_table_name,
			startIndex AS dstartIndex,
			endIndex AS dendIndex,
			list_segment_conditionals as dlist_segment_conditionals
		FROM emarketing.prepare_campaign
		WHERE status_int = 1000 ;

        OPEN cur1 ;

	REPEAT  
		dfull_event : BEGIN

			DECLARE CONTINUE HANDLER FOR 1194
			BEGIN
				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 1.2 of x30x: failure adding email_hash column. ",@fqtname," does not exist\", status_int = 320 where id = ",@queue_id );
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;

				SET @email_hash_error_triggered := 1 ;
			END ;   


			DECLARE CONTINUE HANDLER FOR 1146
			BEGIN
				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 1.2 of x30x: failure adding email_hash column. ",@fqtname," is crashed\", status_int = 320 where id = ",@queue_id );
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;

				SET @email_hash_error_triggered := 1 ;
			END ;   


			FETCH cur1 INTO  diteration_id, dqueue_id, dAccountID, dtschema, dcampaign_id, dfqtname, dtname, dsuppression_fqtname, dfqtemp_table_name, dstartIndex, dendIndex, dlist_segment_conditionals ;

			SET @email_hash_error_triggered := 0 ;

			SET @queue_id := dqueue_id ;
			SET @AccountID := dAccountID ;
			SET @tschema := dtschema ;
			SET @campaign_id := dcampaign_id ;
			SET @fqtname := dfqtname ;
			SET @tname := dtname ;
			SET @suppression_fqtname := dsuppression_fqtname ;
			SET @fqtemp_table_name := dfqtemp_table_name ;
			SET @startIndex := dstartIndex ;
			SET @endIndex := dendIndex ;
			SET @list_segment_conditionals := dlist_segment_conditionals ;

			IF diteration_id = @diteration_id
			THEN
				SET @prep_error := "" ;
			
				IF @fqtname = ""
				THEN
					SET @prep_error := "fqtname is empty" ;
					SET @status_int := 325 ;
					SET @status_update_string := CONCAT("update emarketing.prepare_campaign set message = \"",@prep_error,"\", status_int = ",@status_int," where id = ",@queue_id) ;
					PREPARE status_update_statement from @status_update_string ;
					EXECUTE status_update_statement ;
					DEALLOCATE PREPARE status_update_statement ;
					LEAVE dfull_event ;
				ELSE
					SET @checked_email_hash := NULL ;
					SET @check_for_email_hash_string := CONCAT("select COLUMN_NAME into @checked_email_hash from information_schema.COLUMNS where TABLE_SCHEMA = \"d",@AccountID,"\" and TABLE_NAME = \"",@tname,"\" and COLUMN_NAME = \"email_hash\"") ;
					PREPARE check_for_email_hash_statement from @check_for_email_hash_string ;
					EXECUTE check_for_email_hash_statement ;
					DEALLOCATE PREPARE check_for_email_hash_statement ;
					
					IF @checked_email_hash IS NULL
					THEN
						SET @fix_email_hash_string := CONCAT("call datastore.remove_dups_2(\"",@fqtname,"\")");
						PREPARE fix_email_hash_statement from @fix_email_hash_string ;
						EXECUTE fix_email_hash_statement ;
						DEALLOCATE PREPARE fix_email_hash_statement ;

						IF 1 = @email_hash_error_triggered
						THEN
							LEAVE dfull_event ;
						END IF ;
					END IF ;
				END IF ;

				IF @fqtemp_table_name = ""
				THEN
					SET @prep_error := "fqtemp_table_name is empty" ;
					SET @status_int := 326 ;
					SET @status_update_string := CONCAT("update emarketing.prepare_campaign set message = \"",@prep_error,"\", status_int = ",@status_int," where id = ",@queue_id) ;
					PREPARE status_update_statement from @status_update_string ;
					EXECUTE status_update_statement ;
					DEALLOCATE PREPARE status_update_statement ;
					LEAVE dfull_event ;
				END IF ;

				IF @AccountID = 0 
				THEN
					SET @prep_error := "No Account ID " ;
					SET @status_int := 327 ;
					SET @status_update_string := CONCAT("update emarketing.prepare_campaign set message = \"",@prep_error,"\", status_int = ",@status_int," where id = ",@queue_id) ;
					PREPARE status_update_statement from @status_update_string ;
					EXECUTE status_update_statement ;
					DEALLOCATE PREPARE status_update_statement ;
					LEAVE dfull_event ;
				END IF ;
	
				IF @endIndex < @startIndex
				THEN
					SET @prep_error := "end index cannot be less than startIndex" ;
					SET @status_int := 329 ;
					SET @status_update_string := CONCAT("update emarketing.prepare_campaign set message = \"",@prep_error,"\", status_int = ",@status_int," where id = ",@queue_id) ;
-- 					Somehow, startindex is regularly WRONG when it get inserted into this table. If startindex is greater than endindex, it is assumed that we want to start over.
-- 					SET @status_update_string := CONCAT("update emarketing.prepare_campaign set message = \"",@prep_error,"\", status_int = 0, iteration_id = 0, startindex = 0 where id = ",@queue_id) ;
					PREPARE status_update_statement from @status_update_string ;
					EXECUTE status_update_statement ;
					DEALLOCATE PREPARE status_update_statement ;
					LEAVE dfull_event ;
				END IF ;

	
				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 2 of x30x: creating temp table\" where id = ",@queue_id) ;
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;

				SET @temp_table_error_triggered := 0 ;
				SET @temp_table_exists_exception := 0 ;
				BEGIN
					DECLARE CONTINUE HANDLER FOR SQLSTATE '42S02'
					BEGIN
						SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 2 of x30x: failure creating temp table. ",@fqtname," does not exist\", status_int = 320 where id = ",@queue_id );
						PREPARE status_update_statement from @status_update_string ;
						EXECUTE status_update_statement ;
						DEALLOCATE PREPARE status_update_statement ;
	
						SET @temp_table_error_triggered := 1 ;
					END ;

					DECLARE CONTINUE HANDLER FOR SQLSTATE '42S01'
					BEGIN
						SET @drop_temp_table_string := CONCAT("DROP TABLE IF EXISTS ",@fqtemp_table_name) ;
						PREPARE drop_temp_table_statement from @drop_temp_table_string ;
						EXECUTE drop_temp_table_statement  ;
						DEALLOCATE PREPARE drop_temp_table_statement ;

						SET @temp_table_creation_string := CONCAT("CREATE TABLE ",@fqtemp_table_name," LIKE ",@fqtname) ;
						PREPARE temp_table_creation_statement from @temp_table_creation_string ;
						EXECUTE temp_table_creation_statement ;
						DEALLOCATE PREPARE temp_table_creation_statement ;
						SET @temp_table_exists_exception := 1 ;
					END ;

					IF @fqtemp_table_name <> ""
					THEN
						SET @temp_table_creation_string := CONCAT("CREATE TABLE ",@fqtemp_table_name," LIKE ",@fqtname) ;
						PREPARE temp_table_creation_statement from @temp_table_creation_string ;
						EXECUTE temp_table_creation_statement ;
						IF 0 = @temp_table_exists_exception 
						THEN
							DEALLOCATE PREPARE temp_table_creation_statement ;
						END IF ;
					ELSE
	
						SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 2 of x30x: failure creating temp table. Value for ",@fqtemp_table_name," is empty\", status_int = 321 where id = ",@queue_id) ;
						PREPARE status_update_statement from @status_update_string ;
						EXECUTE status_update_statement ;
						DEALLOCATE PREPARE status_update_statement ;
						LEAVE dfull_event ;
					END IF ;

					IF 1 = @temp_table_error_triggered
					THEN
						LEAVE dfull_event ;
					END IF ;
				END ;

				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 3 of x30x: dropping unnecessary columns from temp table\" where id = ",@queue_id) ;
				PREPARE status_update_statement FROM @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;

				BEGIN
					DECLARE CONTINUE HANDLER FOR 1091
					BEGIN
						SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 3 of x30x: failure dropping column from temp table. Continuing onward\" where id = ",@queue_id) ;
						PREPARE status_update_statement from @status_update_string ;
						EXECUTE status_update_statement ;
						DEALLOCATE PREPARE status_update_statement ;
					END ;

					SET @alter_temp_table_string := CONCAT("ALTER TABLE ",@fqtemp_table_name," DROP COLUMN Confirmed") ;
					PREPARE alter_temp_table_statement FROM @alter_temp_table_string ;
					EXECUTE alter_temp_table_statement ;
					DEALLOCATE PREPARE alter_temp_table_statement ;
					SET @alter_temp_table_string := CONCAT("ALTER TABLE ",@fqtemp_table_name," DROP COLUMN ConfirmedTS") ;
					PREPARE alter_temp_table_statement FROM @alter_temp_table_string ;
					EXECUTE alter_temp_table_statement ;
					DEALLOCATE PREPARE alter_temp_table_statement ;
					SET @alter_temp_table_string := CONCAT("ALTER TABLE ",@fqtemp_table_name," DROP COLUMN ConfirmedIP") ;
					PREPARE alter_temp_table_statement FROM @alter_temp_table_string ;
					EXECUTE alter_temp_table_statement ;
					DEALLOCATE PREPARE alter_temp_table_statement ;
					SET @alter_temp_table_string := CONCAT("ALTER TABLE ",@fqtemp_table_name," DROP COLUMN Opener") ;
					PREPARE alter_temp_table_statement FROM @alter_temp_table_string ;
					EXECUTE alter_temp_table_statement ;
					DEALLOCATE PREPARE alter_temp_table_statement ;
					SET @alter_temp_table_string := CONCAT("ALTER TABLE ",@fqtemp_table_name," DROP COLUMN OpenerTS") ;
					PREPARE alter_temp_table_statement FROM @alter_temp_table_string ;
					EXECUTE alter_temp_table_statement ;
					DEALLOCATE PREPARE alter_temp_table_statement ;
					SET @alter_temp_table_string := CONCAT("ALTER TABLE ",@fqtemp_table_name," DROP COLUMN OpenerIP") ;
					PREPARE alter_temp_table_statement FROM @alter_temp_table_string ;
					EXECUTE alter_temp_table_statement ;
					DEALLOCATE PREPARE alter_temp_table_statement ;
					SET @alter_temp_table_string := CONCAT("ALTER TABLE ",@fqtemp_table_name," DROP COLUMN Clicker") ;
					PREPARE alter_temp_table_statement FROM @alter_temp_table_string ;
					EXECUTE alter_temp_table_statement ;
					DEALLOCATE PREPARE alter_temp_table_statement ;
					SET @alter_temp_table_string := CONCAT("ALTER TABLE ",@fqtemp_table_name," DROP COLUMN ClickerTS") ;
					PREPARE alter_temp_table_statement FROM @alter_temp_table_string ;
					EXECUTE alter_temp_table_statement ;
					DEALLOCATE PREPARE alter_temp_table_statement ;
					SET @alter_temp_table_string := CONCAT("ALTER TABLE ",@fqtemp_table_name," DROP COLUMN ClickerIP") ;
					PREPARE alter_temp_table_statement FROM @alter_temp_table_string ;
					EXECUTE alter_temp_table_statement ;
					DEALLOCATE PREPARE alter_temp_table_statement ;
					SET @alter_temp_table_string := CONCAT("ALTER TABLE ",@fqtemp_table_name," DROP COLUMN ip") ;
					PREPARE alter_temp_table_statement FROM @alter_temp_table_string ;
					EXECUTE alter_temp_table_statement ;
					DEALLOCATE PREPARE alter_temp_table_statement ;
				END ;

				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 4 of x30x: getting role_suppression, domainIncludes and last_suppressed_time settings\" where id = ",@queue_id) ;
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;

				SET @suppress_roles := 0 ;
				SET @suppress_global_individuals := 0 ;
				SET @suppress_domains := 0 ;
				SET @domain_includes := "" ;
				select sleep(1) into @dsleep ;
				SET @time_last_suppressed := "" ;
--				SET @get_settings_string := CONCAT("SELECT settings.SuppressRoles, settings.DomainIncludes, lists.TimeLastSupressed  INTO @suppress_roles, @domain_includes, @time_last_suppressed from emarketing.settings  as settings INNER JOIN emarketing.lists as lists ON settings.AccountID = lists.AccountID WHERE lists.TableID = \"",@tname,"\" and settings.AccountID = ",@AccountID) ;
                               SET @get_settings_string := CONCAT("SELECT settings.SuppressRoles, SuppressDomains, SuppressGlobalIndividuals, settings.DomainIncludes, lists.TimeLastSupressed  INTO @suppress_roles, @suppress_domains, @suppress_global_individuals, @domain_includes, @time_last_suppressed from emarketing.settings  as settings INNER JOIN emarketing.lists as lists ON settings.AccountID = lists.AccountID WHERE lists.TableID = \"",@tname,"\" and settings.AccountID = ",@AccountID) ;

				PREPARE get_settings_statement from @get_settings_string ;
				EXECUTE get_settings_statement ;
				DEALLOCATE PREPARE get_settings_statement ;
				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 5 of x30x: global and unsubscribe suppression\" where id = ",@queue_id) ;
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;
	
				SET @suppression_exception_triggered := 0 ;
				BEGIN
					DECLARE EXIT HANDLER FOR 1062
					BEGIN
						SET @prep_error := concat("duplicate entry found in suppression call",@suppression_call_string) ;
						SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \'",@prep_error,"\', status_int = 322 where id = ",@queue_id) ;
                                                PREPARE status_update_statement from @status_update_string ;
                                                EXECUTE status_update_statement ;
                                                DEALLOCATE PREPARE status_update_statement ;
        
                                                SET @suppression_exception_triggered := 1 ;
					END ;

					DECLARE EXIT HANDLER FOR 1054
                                        BEGIN   
						SET @prep_error := CONCAT("Step 5 of x30x: failure of suppression stored procedure. unsubscribe table or client table missing email_hash column Suppression call = ",@suppression_call_string);
						SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \'",@prep_error,"\', status_int = 322 where id = ",@queue_id) ;
						PREPARE status_update_statement from @status_update_string ;
						EXECUTE status_update_statement ;
						DEALLOCATE PREPARE status_update_statement ;
	
						SET @suppression_exception_triggered := 1 ;
                                        END ;

					DECLARE EXIT HANDLER FOR SQLEXCEPTION
					BEGIN
						SET @prep_error := CONCAT("Step 5 of x30x: failure of suppression stored procedure. Suppression call = ",@suppression_call_string);
						SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \'",@prep_error,"\', status_int = 322 where id = ",@queue_id) ;
						PREPARE status_update_statement from @status_update_string ;
						EXECUTE status_update_statement ;
						DEALLOCATE PREPARE status_update_statement ;
	
						SET @suppression_exception_triggered := 1 ;
					END ;

					IF @domain_includes is null
					THEN
						set @domain_includes := "" ;
					END IF ;

					IF '' = @time_last_suppressed
					THEN
						set @time_last_suppressed := "0000-00-00 00:00:00" ;
					END IF ;

--					SET @suppression_call_string := CONCAT("CALL datastore.suppression(\"",@fqtname,"\", ",@suppress_roles,", \"",@domain_includes,"\", \"",@time_last_suppressed,"\")") ;
					SET @suppression_call_string := CONCAT("CALL datastore.suppression(\"",@fqtname,"\", ",@suppress_roles,", \"",@domain_includes,"\", \"",@time_last_suppressed,"\", ",@suppress_global_individuals,",",@suppress_domains,")") ;

					PREPARE suppression_call_statement from @suppression_call_string ;
					EXECUTE suppression_call_statement ;
					DEALLOCATE PREPARE suppression_call_statement ;
	
					SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 5.5 of x30x: global and unsubscribe suppression complete\", last_suppressed_time = NOW() where id = ",@queue_id) ;
					PREPARE status_update_statement from @status_update_string ;
					EXECUTE status_update_statement ;
					DEALLOCATE PREPARE status_update_statement ;
		
					IF 1 = @suppression_exception_triggered
					THEN
						LEAVE dfull_event ;
					END IF ;
				END ;

				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 6 of x30x: getting columns to populate\" where id = ",@queue_id) ;
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;
				
				SET @populate_columns := "" ;
				SET @get_columns_string := CONCAT("SELECT GROUP_CONCAT(COLUMN_NAME SEPARATOR '` , `') INTO @populate_columns FROM information_schema.COLUMNS WHERE COLUMN_NAME NOT IN(\"Confirmed\",\"ConfirmedTS\",\"ConfirmedIP\",\"Opener\",\"OpenerTS\",\"OpenerIP\",\"Clicker\",\"ClickerTS\",\"ClickerIP\",\"ip\") AND TABLE_SCHEMA = \"d",@AccountID,"\" AND TABLE_NAME = \"",@tname,"\"") ;
				PREPARE get_columns_statement from @get_columns_string ;
				EXECUTE get_columns_statement ;
				DEALLOCATE PREPARE get_columns_statement ;

				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 7 of x30x: creating populate SQL string\" where id = ",@queue_id) ;
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;

				SET @populate_temp_table_string := CONCAT("INSERT IGNORE INTO ",@fqtemp_table_name," (`",@populate_columns,"`) SELECT `",@populate_columns,"` FROM ",@fqtname," WHERE Status < 85") ;
	
				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 7 of x30x: checking for list segment conditionals and adding to populate SQL string\" where id = ",@queue_id) ;
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;

				IF @list_segment_conditionals IS NOT NULL AND @list_segment_conditionals <> ""
				THEN
					SET @populate_temp_table_string := CONCAT(@populate_temp_table_string," AND " ,@list_segment_conditionals) ;
				END IF ;
	
				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 8 of x30x: checking for start and end indexes and adding to populate SQL string\" where id = ",@queue_id) ;
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;
	
				IF @endIndex <> 0
				THEN
-- 					SET @populate_temp_table_string := CONCAT(@populate_temp_table_string," LIMIT ",@startIndex,", ",@endIndex - @startIndex) ;
					SET @populate_temp_table_string := CONCAT(@populate_temp_table_string," LIMIT ",@endIndex) ;
				END IF ;

				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 9 of x30x: populating table\" where id = ",@queue_id) ;
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;
				
				SET @populate_exception_triggered := 0 ;
				BEGIN
					DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
					BEGIN
						SET @prep_error := CONCAT("Step 9 of x30x: failure populating fqtemp_table_name. failed statement = ",@populate_temp_table_string);
						SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"",@prep_error,"\", status_int = 323 where id = ",@queue_id) ;
						PREPARE status_update_statement from @status_update_string ;
						EXECUTE status_update_statement ;
						DEALLOCATE PREPARE status_update_statement ;
						SET @populate_exception_triggered := 1 ;
	
					END ;

					PREPARE populate_temp_table_statement FROM @populate_temp_table_string ;
					EXECUTE populate_temp_table_statement ;
					DEALLOCATE PREPARE populate_temp_table_statement ;
				END ;

				IF 1 = @populate_exception_triggered
				THEN
					LEAVE dfull_event ;
				END IF ;

				SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 10 of x30x: checking for suppression list\" where id = ", @queue_id );
				PREPARE status_update_statement from @status_update_string ;
				EXECUTE status_update_statement ;
				DEALLOCATE PREPARE status_update_statement ;

				IF @suppression_fqtname is not null AND @suppression_fqtname <> ""
				THEN
					SET @suppression_table_exception_triggered := 0 ;
					BEGIN
						DECLARE CONTINUE HANDLER FOR 1194
						BEGIN
							SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 1.2 of x30x: failure adding email_hash column. ",@suppression_fqtname," or ",@fqtemp_table_name," does not exist\", status_int = 320 where id = ",@queue_id );
							PREPARE status_update_statement from @status_update_string ;
							EXECUTE status_update_statement ;
							DEALLOCATE PREPARE status_update_statement ;
			
							SET @suppression_table_exception_triggered := 1 ;
						END ;   

						DECLARE CONTINUE HANDLER FOR 1146
						BEGIN
							SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 10.2 of x30x: failure suppressing against suppression list. ",@suppression_fqtname,"  or ",@fqtemp_table_name," is crashed or does not exist\", status_int = 320 where id = ",@queue_id );
							PREPARE status_update_statement from @status_update_string ;
							EXECUTE status_update_statement ;
							DEALLOCATE PREPARE status_update_statement ;
			
							SET @suppression_table_exception_triggered := 1 ;
						END ;   

						DECLARE EXIT HANDLER FOR SQLSTATE '42S02'
						BEGIN
							SET @prep_error := CONCAT("failure suppressing  temp table against suppression table. ",@fqtemp_table_name," does not exist" );
							SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 11 of x30x: failure suppressing temp table against suppression table. suppression table ",@fqtemp_table_name," does not exist\", status_int = 324 where id = ",@queue_id) ;
							PREPARE status_update_statement from @status_update_string ;
							EXECUTE status_update_statement ;
							DEALLOCATE PREPARE status_update_statement ;
	
							SET @suppression_table_exception_triggered := 1 ;
						END ;

						DECLARE CONTINUE HANDLER FOR SQLSTATE '42S22'
						BEGIN
							SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 12 of x30x: failure dropping column email_hash from temp table. Continuing onward\" where id = ",@queue_id) ;
							PREPARE status_update_statement from @status_update_string ;
							EXECUTE status_update_statement ;
							DEALLOCATE PREPARE status_update_statement ;
						END ;

						SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 11 of x30x: deleting entries from temp table found in suppression list\" where id = ",@queue_id) ;
						PREPARE status_update_statement from @status_update_string ;
						EXECUTE status_update_statement ;
						DEALLOCATE PREPARE status_update_statement ;

						SET @suppression_list_string := CONCAT("delete ",@fqtemp_table_name," as list from ",@fqtemp_table_name," as list inner join ",@suppression_fqtname," as suppression_table on list.email_hash = suppression_table.email_hash" );
						PREPARE suppression_list_statement from @suppression_list_string ;
						IF 0 = @suppression_table_exception_triggered
						THEN
							EXECUTE suppression_list_statement ;
							DEALLOCATE PREPARE suppression_list_statement ;
						ELSE
							LEAVE dfull_event ;
						END IF ;
	
						SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 11 of x30x: deleting entries from temp table found in suppression list\" where id = ",@queue_id) ;
						PREPARE status_update_statement from @status_update_string ;
						EXECUTE status_update_statement ;
						DEALLOCATE PREPARE status_update_statement ;

						select sleep(1) into @dsleep ;
						SET @timestamp := rand(unix_timestamp()) ;
						SET @wild_card_suppression_string := concat("SELECT email into outfile '/tmp/d",@AccountID,"_",@timestamp,"wild.txt' FIELDS TERMINATED by ';' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED by '' from ",@suppression_fqtname," where email like \"%\%%\" ") ;
						PREPARE wild_card_suppression_statement from @wild_card_suppression_string ;
						EXECUTE wild_card_suppression_statement ;
						DEALLOCATE PREPARE wild_card_suppression_statement ;

						SET @wild_card_emails := "" ;

						set @d_wildcards_string := concat("set @wild_card_emails := load_file('/tmp/d",@AccountID,"_",@timestamp,"wild.txt')" );
						PREPARE wildcards_statement from @d_wildcards_string ;
						EXECUTE wildcards_statement ;
						DEALLOCATE PREPARE wildcards_statement ;

						IF "" <> @wild_card_emails
						THEN
--							get rid of %&#37\; winblows pasted in crap
							SET @wild_card_emails := REPLACE(@wild_card_emails, '%&#37\\;','%') ;
--							take the trailing ; off the @wild_card_emails string
							SET @wild_card_emails := SUBSTR(@wild_card_emails, 1, length(@wild_card_emails)-1) ;
							SET @wild_card_suppression_string2 := CONCAT("delete from ",@fqtemp_table_name, " where email like ", REPLACE(@wild_card_emails, ";", " or email like "),  @domain_include_string2 ) ;
							PREPARE wild_card_suppression_statement2 from @wild_card_suppression_string2 ;
							EXECUTE wild_card_suppression_statement2 ;
							DEALLOCATE PREPARE wild_card_suppression_statement2 ;
						END IF ;
	
						SET @status_update_string := CONCAT("UPDATE emarketing.prepare_campaign set message = \"Step 12 of x30x: dropping email_hash column from temp table\" where id = ",@queue_id) ;
						PREPARE status_update_statement from @status_update_string ;
						EXECUTE status_update_statement ;
						DEALLOCATE PREPARE status_update_statement ;

						SET @alter_temp_table_string := CONCAT("ALTER table ",@fqtemp_table_name," drop column email_hash ") ;
						PREPARE alter_temp_table_statement from @alter_temp_table_string ;
						EXECUTE alter_temp_table_statement ;
						DEALLOCATE PREPARE alter_temp_table_statement ;
					END ;
					IF 1 = @suppression_table_exception_triggered 
					THEN
						LEAVE dfull_event ;
					END IF ;
				END IF;

	
				IF @prep_error = ""
				THEN
					SET @status_update_string := CONCAT("update emarketing.prepare_campaign set status_int = 1100 where  id = ",@queue_id) ;
					PREPARE status_update_statement from @status_update_string ;
					EXECUTE status_update_statement ;
					DEALLOCATE PREPARE status_update_statement ;
				END IF ;
			END IF ;

			IF @queue_id IS NULL
			THEN
				SET done := 1 ;
			END IF ;
		END ;
	UNTIL 1 = done END REPEAT ;
        CLOSE cur1 ;
	END ;
END ;

~

delimiter ;



