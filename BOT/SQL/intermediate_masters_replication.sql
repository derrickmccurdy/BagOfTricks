rsync -avz --progress -e ssh /var/lib/mysql/datastore/masterimportarchive.* app:/var/lib/mysql/datastore/
rsync -avz --progress -e ssh /var/lib/mysql/datastore/tblbounces.* app:/var/lib/mysql/datastore/
rsync -avz --progress -e ssh /var/lib/mysql/datastore/tbldirect_optin.* app:/var/lib/mysql/datastore/
rsync -avz --progress -e ssh /var/lib/mysql/datastore/tblmaster.* app:/var/lib/mysql/datastore/
rsync -avz --progress -e ssh /var/lib/mysql/datastore/tblsuppressiontimes.* app:/var/lib/mysql/datastore/
rsync -avz --progress -e ssh /var/lib/mysql/premium/bounces.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/bounces_operate.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/channels.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/holding_record_reports.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/importarchive.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/industry.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/interest.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/out_report.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/premium_email.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/premium_email_holding.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/premium_test.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/premium_tmp.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/record_reports.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/suppressed.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/suppressed_domains.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/suppressed_full.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/suppressed_operate.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/premium/suppressed_roles.* app:/var/lib/mysql/premium/
rsync -avz --progress -e ssh /var/lib/mysql/system/tblglobal_domains.* app:/var/lib/mysql/system/
rsync -avz --progress -e ssh /var/lib/mysql/system/tblglobal_individual.* app:/var/lib/mysql/system/
rsync -avz --progress -e ssh /var/lib/mysql/system/tblglobal_role.* app:/var/lib/mysql/system/
rsync -avz --progress -e ssh /var/lib/mysql/system/tblglobal_sms.* app:/var/lib/mysql/system/
rsync -avz --progress -e ssh /var/lib/mysql/system/tblglobal_sms_role.* app:/var/lib/mysql/system/
rsync -avz --progress -e ssh /var/lib/mysql/template/base_table.* app:/var/lib/mysql/template/
rsync -avz --progress -e ssh /var/lib/mysql/template/unsubscribe.* app:/var/lib/mysql/template/
