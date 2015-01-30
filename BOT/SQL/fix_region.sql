-- need to make sure that varchar columns are the same length.
UPDATE LOW_PRIORITY datastore.tblmastertest dt INNER JOIN  census_data.zip_codes cd ON dt.zipcode = cd.code  SET dt.region = cd.state, dt.country_short = "us" where dt.region = "" AND dt.zipcode = cd.code AND dt.id < 3000000 ;


