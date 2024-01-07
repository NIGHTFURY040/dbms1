drop database if exists enrollment1;
create database enrollment1;
use enrollment1;

create table Student(
	regno varchar(13) primary key,
	name varchar(25) not null,
	major varchar(25) not null,
	bdate date not null
);

create table Course(
	course int primary key,
	cname varchar(30) not null,
	dept varchar(100) not null
);

create table Enroll(
	regno varchar(13),
	course int,
	sem int not null,
	marks int not null,
	foreign key(regno) references Student(regno) on delete cascade,
	foreign key(course) references Course(course) on delete cascade
);

create table TextBook(
	bookIsbn int not null,
	book_title varchar(40) not null,
	publisher varchar(25) not null,
	author varchar(25) not null,
	primary key(bookIsbn)
);

create table BookAdoption(
	course int not null,
	sem int not null,
	bookIsbn int not null,
	foreign key(bookIsbn) references TextBook(bookIsbn) on delete cascade,
	foreign key(course) references Course(course) on delete cascade
);

INSERT INTO Student VALUES
("01JC1", "Student_1", "CS", "2001-05-15"),
("01JC2", "Student_2", "Botany", "2002-06-10"),
("01JC3", "Student_3", "Philosophy", "2000-04-04"),
("01JC4", "Student_4", "History", "2003-10-12"),
("01JC5", "Student_5", "Computer Economics", "2001-10-10");

INSERT INTO Course VALUES
(01, "DBMS", "CS"),
(02, "Botany", "Bio"),
(03, "Philosophy", "Philosphy"),
(04, "History", "Social Science"),
(05, "Computer Networks", "CS");

INSERT INTO Enroll VALUES
("01JC1", 01, 5, 85),
("01JC2", 02, 6, 87),
("01JC3", 03, 3, 95),
("01JC4", 04, 3, 80),
("01JC5", 05, 5, 75);

INSERT INTO TextBook VALUES
(11, "Operating Systems", "Pearson", "Kannan Kumar"),
(22, "Songs of Shakesphere", "Oxford", "Shakesphere"),
(33, "DVG kavithe", "DV Classics", "DVG"),
(44, "History of the world", "The Times", "Kuvempu"),
(55, "Economics", "Pearson", "David Warner");

INSERT INTO BookAdoption VALUES
(01, 5, 11),
(02, 6, 22),
(03, 3, 33),
(04, 3, 44),
(01, 6, 55);

select * from Student;
select * from Course;
select * from Enroll;
select * from BookAdoption;
select * from TextBook;


-- Demonstrate how you add a new text book to the database and make this book be adopted by some department.
insert into TextBook values
(66, "Intro to DB", "Pearson", "Chandan");

insert into BookAdoption values
(01, 5, 66);

delete from TextBook where bookIsbn = 66;

-- Produce a list of text books (include Course #, Book-ISBN, Book-title) in the alphabetical order for courses offered by the ‘CS’ department that use more than two books.
SELECT c.course,t.bookIsbn,t.book_title
     FROM Course c,BookAdoption ba,TextBook t
     WHERE c.course=ba.course
     AND ba.bookIsbn=t.bookIsbn
     AND c.dept='CS'
     AND 2<(
     SELECT COUNT(bookIsbn)
     FROM BookAdoption b
     WHERE c.course=b.course)
     ORDER BY t.book_title;


-- List any department that has all its adopted books published by a specific publisher.
SELECT DISTINCT c.dept
     FROM Course c
     WHERE c.dept IN
     ( SELECT c.dept
     FROM Course c,BookAdoption b,TextBook t
     WHERE c.course=b.course
     AND t.bookIsbn=b.bookIsbn
     AND t.publisher='PEARSON'); -- below was own(not necessary)
--      AND c.dept NOT IN
--      ( SELECT c.dept
--      FROM Course c, BookAdoption b, TextBook t
--      WHERE c.course=b.course
--      AND t.bookIsbn=b.bookIsbn
--      AND t.publisher!='PEARSON'); 


-- List the students who have scored maximum marks in ‘DBMS’ course.

select name from Student s, Enroll e, Course c
where s.regno=e.regno and e.course=c.course and c.cname="DBMS" and e.marks in (select max(marks) from Enroll e1, Course c1 where c1.cname="DBMS" and c1.course=e1.course);


-- Create a view to display all the courses opted by a student along with marks obtained.
create view CoursesOptedByStudent as
select c.cname, e.marks from Course c, Enroll e
where e.course=c.course and e.regno="01JC1";

select * from CoursesOptedByStudent;


-- Create a trigger that prevents a student from enrolling in a course if the marks pre_requisit is less than the given threshold 
DELIMITER //
create  trigger PreventEnrollment
before insert on Enroll
for each row
BEGIN
	IF (new.marks<40) THEN
		signal sqlstate '45000' set message_text='Marks below threshold';
	END IF;
END;//

DELIMITER ;

INSERT INTO Enroll VALUES
("01JC1", 002, 5, 5); -- Gives error since marks is less than 40
