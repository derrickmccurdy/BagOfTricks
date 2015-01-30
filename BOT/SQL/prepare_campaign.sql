use emarketing ;

CREATE TABLE `prepare_campaign` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `AccountID` int(10) NOT NULL,
  `campaign_id` int(10) NOT NULL,
  `fqtname` varchar(50) NOT NULL,
  `suppression_fqtname` varchar(50) DEFAULT NULL,
  `fqtemp_table_name` varchar(50) NOT NULL,
  `startIndex` int(10) NOT NULL,
  `endIndex` int(10) NOT NULL,
  `list_segment_conditionals` varchar(254) DEFAULT NULL,
  `queue_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status_int` int(4) NOT NULL DEFAULT '0',
  `message` text,
  `last_suppressed_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `iteration_id` bigint(17) unsigned zerofill NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campaign_id` (`campaign_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3999 DEFAULT CHARSET=latin1
;
