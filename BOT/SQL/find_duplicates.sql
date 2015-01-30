select count(email), max(email) from t6730_48ee4ebd4a2ee group by email having count(email)>1 ;



select count(email), email from t6730_48ee4ebd4a2ee group by email having count(email)>1 ;
