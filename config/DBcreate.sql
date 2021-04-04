create database if not exists ognrange;
use ognrange;
source OGNrange.sql ;
create user ognrange@localhost identified by 'aksdkqre912eqwkadkad';
grant select on ognrange.* to ognrange@localhost ;
create user ognwriter@localhost identified by 'aksdkqre912eqwkadkad';
grant select, update, insert, create temporary tables, drop on ognrange.* to ognwriter@localhost ;
flush privileges;
