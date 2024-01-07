drop database if exists sailors1;
create database sailors1;
use sailors1;

create table if not exists Sailors(
	sid int primary key,
	sname varchar(35) not null,
	rating float not null,
	age int not null
);

create table if not exists Boat(
	bid int primary key,
	bname varchar(35) not null,
	color varchar(25) not null
);

create table if not exists reserves(
	sid int not null,
	bid int not null,
	sdate date not null,
	foreign key (sid) references Sailors(sid) on delete cascade,
	foreign key (bid) references Boat(bid) on delete cascade
);

insert into Sailors values
(1,"Albert", 5.0, 40),
(2, "Nakul", 5.0, 49),
(3, "Darshan", 9, 18),
(4, "A Gowda", 2, 68),
(5, "Arm mint", 7, 19);


insert into Boat values
(11,"Boat_1", "Green"),
(22,"Boat_2", "Red"),
(33,"Boat_3", "Blue"),
(44,"1storm", "Pink"),
(55,"Boat_4", "Yellow");
insert into Boat values
(103,"2storm", "Black");


insert into reserves values
(1,33,"2023-01-01"),
(1,22,"2023-02-01"),
(1,44,"2023-01-01"),
(1,103,"2023-01-01"),
(1,55,"2022-01-01"),
(2,11,"2023-02-05"),
(3,22,"2023-03-06"),
(5,33,"2023-03-06"),
(5,103,"2023-02-01"),
(1,11,"2023-03-06");
insert into reserves values
(1,103,"2023-01-01"),
(5,103,"2023-02-01");

select * from Sailors;
select * from Boat;
select * from reserves;

-- Find the colours of the boats reserved by Albert
select color 
from Sailors s, Boat b, reserves r 
where s.sid=r.sid and b.bid=r.bid and s.sname="Albert";

-- Find all the sailor sids who have rating atleast 8 or reserved boat 103

(select sid
from Sailors
where Sailors.rating>=8)
UNION
(select sid
from reserves
where reserves.bid=103);


-- Find the names of the sailor who have not reserved a boat whose name contains the string "storm". Order the name in the ascending order
#own query-->
select s.sname
from Sailors s
where s.sid not in
(select s1.sid
from Sailors s1,Reserves r,Boat b 
where s1.sid=r.sid and r.bid=b.bid and b.bname like "%storm%")
order by s.sname;

-- Find the name of the sailors who have reserved all boats

select s.sname from Sailors s where not exists
	(select * from Boat b where not exists
		(select * from reserves r where r.sid=s.sid and b.bid=r.bid));
      

-- Find the name and age of the oldest sailor

select sname, age
from Sailors where age in (select max(age) from Sailors);

-- For each boat which was reserved by atleast 2 sailors with age >= 40, find the bid and average age of such sailors

select b.bid, avg(s.age) as average_age
from Sailors s, Boat b, reserves r
where r.sid=s.sid and r.bid=b.bid and s.age>=40
group by bid
having 2<=count(distinct r.sid);


-- Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.

create view ReservedBoatsWithRatedSailor as
select distinct bname, color
from Sailors s, Boat b, reserves r
where s.sid=r.sid and b.bid=r.bid and s.rating=5;

select * from ReservedBoatsWithRatedSailor;


-- Trigger that prevents boats from being deleted if they have active reservation

DELIMITER //
create trigger CheckAndDelete
before delete on Boat
for each row
BEGIN
	IF EXISTS (select * from reserves where reserves.bid=old.bid) THEN
		SIGNAL SQLSTATE '45000' SET message_text='Boat is reserved and hence cannot be deleted';
	END IF;
END;//

DELIMITER ;

delete from Boat where bid=103; -- This gives error since boat 103 is reserved

