
pg15
yum install epel-release.noarch -y
yum install libzstd.x86_64 -y
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum install -y postgresql15-server
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15

su - postgres
psql

create database mydb;
create user myuser with encrypted password 'mypass';
grant all privileges on database mydb to myuser;
grant all on schema public to myuser;

PGPASSWORD='mypass' psql -h 127.0.0.1 -p 5432 -U myuser -d mydb
psql "postgresql://myuser:mypass@127.0.0.1:5432/mydb"

less $PGDATA/pg_hba.conf

/usr/pgsql-15/bin/pg_ctl reload

\set HISTCONTROL ignoredups
\set COMP_KEYWORD_CASE upper


create table tbl02(id int,data1 varchar(300));
insert into tbl02 values(9000,9000);
select * from tbl01 t1, tbl02 t2 where t1.id=t2.id and t1.id=9000;
