DROP DATABASE IF EXISTS insurance1;
CREATE DATABASE insurance1;
USE insurance1;

CREATE TABLE IF NOT EXISTS person (
driver_id VARCHAR(255) NOT NULL,
driver_name TEXT NOT NULL,
address TEXT NOT NULL,
PRIMARY KEY (driver_id)
);

CREATE TABLE IF NOT EXISTS car (
reg_no VARCHAR(255) NOT NULL,
model TEXT NOT NULL,
c_year INTEGER,
PRIMARY KEY (reg_no)
);

CREATE TABLE IF NOT EXISTS accident (
report_no INTEGER NOT NULL,
accident_date DATE,
location TEXT,
PRIMARY KEY (report_no)
);

CREATE TABLE IF NOT EXISTS owns (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS participated (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
report_no INTEGER NOT NULL,
damage_amount FLOAT NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
FOREIGN KEY (report_no) REFERENCES accident(report_no)
);

INSERT INTO person VALUES
("D1", "Driver_1", "Kuvempunagar, Mysuru"),
("D2", "Smith", "JP Nagar, Mysuru"),
("D3", "Driver_3", "Udaygiri, Mysuru"),
("D4", "Driver_4", "Rajivnagar, Mysuru"),
("D5", "Driver_5", "Vijayanagar, Mysore");

INSERT INTO car VALUES
("KA-21-AB-1234", "Swift", 2020),
("KA-21-AC-1234", "Mazda", 2017),
("KA-21-AD-1234", "Alto", 2015),
("KA-21-AE-1234", "Triber", 2019),
("KA-09-MA-1234", "Tiago", 2018);

INSERT INTO accident VALUES
(1, "2020-04-05", "Nazarbad, Mysuru"),
(2, "2019-12-16", "Gokulam, Mysuru"),
(3, "2020-05-14", "Vijaynagar, Mysuru"),
(4, "2019-08-30", "Kuvempunagar, Mysuru"),
(5, "2021-01-21", "JSS Layout, Mysuru"),
(6, "2021-01-25", "Teachers Layout, Mysuru");

INSERT INTO owns VALUES
("D1", "KA-21-AB-1234"),
("D2", "KA-21-AC-1234"),
("D3", "KA-21-AD-1234"),
("D4", "KA-21-AE-1234"),
("D2", "KA-09-MA-1234");

INSERT INTO participated VALUES
("D1", "KA-21-AB-1234", 1, 20000),
("D2", "KA-21-AC-1234", 2, 49500),
("D3", "KA-21-AD-1234", 3, 15000),
("D4", "KA-21-AE-1234", 4, 5000),
("D2", "KA-09-MA-1234", 5, 25000);

-- Find the total number of people who owned a car that were involved in accidents in 2021

select COUNT(driver_id) as numofpeople
from participated p, accident a
where p.report_no=a.report_no and a.accident_date like "2021%";

-- Find the number of accident in which cars belonging to smith were involved

select COUNT(distinct a.report_no) as cnt
from accident a
where exists 
(select * from person p, participated ptd where p.driver_id=ptd.driver_id and p.driver_name="Smith" and a.report_no=ptd.report_no);

-- Add a new accident to the database

insert into accident values
(7, "2024-04-05", "Mandya");
delete from accident where location="Mandya";

insert into participated values
("D2", "KA-21-AE-1234", 7, 50000);


-- Delete the Mazda belonging to Smith

delete from car
where model="Mazda" and reg_no in
(select car.reg_no from person p, owns o where p.driver_id=o.driver_id and o.reg_no=car.reg_no and p.driver_name="Smith");

-- insert for the above query
INSERT INTO car VALUES
("KA-21-AC-1234", "Mazda", 2017);
INSERT INTO owns VALUES
("D2", "KA-21-AC-1234");
INSERT INTO participated VALUES
("D2", "KA-21-AC-1234", 2, 49500);

-- Update the damage amount for the car with reg_no of KA-09-MA-1234 in the accident with report_no 5

update participated set damage_amount=10000 where report_no=5 and reg_no="KA-09-MA-1234";
-- reverse of above
update participated set damage_amount=25000 where report_no=5 and reg_no="KA-09-MA-1234";


-- View that shows models and years of car that are involved in accident

create view CarsInAccident as
select distinct model, c_year
from car c, participated p
where c.reg_no=p.reg_no;

select * from CarsInAccident;


-- A trigger that prevents a driver from participating in more than 3 accidents in a given year.

DELIMITER //
create trigger PreventParticipation
before insert on participated
for each row
BEGIN
	IF 3<=(select count(*) from participated where driver_id=new.driver_id) THEN
		signal sqlstate '45000' set message_text='Driver has already participated in 3 accidents';
	END IF;
END;//
DELIMITER ;

INSERT INTO participated VALUES
("D2", "KA-21-AB-1234", 6, 290000);
INSERT INTO participated VALUES
("D2", "KA-21-AC-1234", 6, 280000);
delete from participated where reg_no="KA-21-AB-1234";
