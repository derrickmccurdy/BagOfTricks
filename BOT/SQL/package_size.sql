function GetEmailMarketingPriceByPackageSize($packageSize)
{
        switch ($packageSize)
        {
                case 1000:
                                return 15;
                        break;
                case 5000:
                                return 25;
                        break;
                case 10000:
                                return 40;
                        break;
                case 50000:
                                return 60; 
                        break;
                case 100000:
                                return 100;
                        break;
                case 500000:
                                return 200; 
                        break;
                case 1000000:   
                                return 400;
                        break;
                case 10000000:
                                return 600;
                        break;
                case 30000000:  
                                return 800;
                        break;
                case 50000000:  
                                return 1100;
                        break;
                case 100000000:
                                return 1500;
                        break;
                case 150000000:
                                return 2000;
                        break;
                case 200000000:
                                return 2500;
                        break;
                case 500000000:
                                return 5000;
                        break;
                // muahahah 1 one billion emails
                case 1000000000:
                                return 10000;
                        break;
                default:
                                return 0;
                break;

        }
}
drop table if exists system.email_package_sizes ;
create table system.email_package_sizes (
package_size int(10) not null default 0 primary key, 
package_price float(6,2) ) ;

insert into system.email_package_sizes (package_size, package_price) values(1000, 15.00),(5000, 25.00),(10000, 40),(50000, 60),(100000, 100),(500000, 200),(1000000, 400),(10000000, 600),(30000000, 800),(50000000, 1100),(100000000, 1500),(150000000,2000),(200000000,2500),(500000000, 5000),(1000000000, 10000) ;
