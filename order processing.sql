drop database if exists order_processing1;
create database order_processing1;
use order_processing1;

create table if not exists Customers (
	cust_id int primary key,
	cname varchar(35) not null,
	city varchar(35) not null
);

create table if not exists Orders (
	order_id int primary key,
	odate date not null,
	cust_id int,
	order_amt int not null,
	foreign key (cust_id) references Customers(cust_id) on delete cascade
);

create table if not exists Items (
	item_id  int primary key,
	unitprice int not null
);

create table if not exists OrderItems (
	order_id int not null,
	item_id int not null,
	qty int not null,
	foreign key (order_id) references Orders(order_id) on delete cascade,
	foreign key (item_id) references Items(item_id) on delete cascade
);

create table if not exists Warehouses (
	warehouse_id int primary key,
	city varchar(35) not null
);

create table if not exists Shipments (
	order_id int not null,
	warehouse_id int not null,
	ship_date date not null,
	foreign key (order_id) references Orders(order_id) on delete cascade,
	foreign key (warehouse_id) references Warehouses(warehouse_id) on delete cascade
);

INSERT INTO Customers VALUES
(1, "Customer_1", "Mysuru"),
(2, "Customer_2", "Bengaluru"),
(3, "Kumar", "Mumbai"),
(4, "Customer_4", "Dehli"),
(5, "Customer_5", "Bengaluru");

INSERT INTO Orders VALUES
(01, "2020-01-14", 1, 2000),
(02, "2021-04-13", 2, 500),
(03, "2019-10-02", 3, 2500),
(04, "2019-05-12", 5, 1000),
(05, "2020-12-23", 4, 1200);

INSERT INTO Items VALUES
(001, 400),
(002, 200),
(003, 1000),
(004, 100),
(005, 500);

INSERT INTO Warehouses VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");

INSERT INTO OrderItems VALUES 
(01, 001, 5),
(02, 005, 1),
(03, 005, 5),
(04, 003, 1),
(05, 004, 12);

INSERT INTO Shipments VALUES
(01, 0002, "2020-01-16"),
(02, 0001, "2021-04-14"),
(03, 0004, "2019-10-07"),
(04, 0003, "2019-05-16"),
(05, 0005, "2020-12-23");


SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Items;
SELECT * FROM Shipments;
SELECT * FROM Warehouses;


-- List the Order# and Ship_date for all orders shipped from Warehouse# "0002".
select order_id,ship_date from Shipments where warehouse_id=0002;

-- List the Warehouse information from which the Customer named "Kumar" was supplied his orders. Produce a listing of Order#, Warehouse#
select order_id,warehouse_id from Warehouses natural join Shipments where order_id in (select order_id from Orders where cust_id in (Select cust_id from Customers where cname like "%Kumar%"));
-- own query
select s.order_id,s.warehouse_id from Shipments s,Orders o, Customers c where s.order_id=o.order_id and o.cust_id=c.cust_id and c.cname="Kumar";

-- Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total number of orders by the customer and the last column is the average order amount for that customer. (Use aggregate functions) 
select cname, COUNT(*) as no_of_orders, AVG(order_amt) as avg_order_amt
from Customers c, Orders o
where c.cust_id=o.cust_id 
group by cname;

-- Delete all orders for customer named "Kumar".
delete from Orders where cust_id = (select cust_id from Customers where cname like "%Kumar%");
insert into Orders values(03, "2019-10-02", 3, 2500);
insert into orderitems values(03, 005, 5);
insert into Shipments values(03, 0004, "2019-10-07");

-- Find the item with the maximum unit price.
select max(unitprice) from Items; -- or the following
select Item_id,unitprice from Items where unitprice in (select max(unitprice) from Items);

-- Create a view to display orderID and shipment date of all orders shipped from a warehouse 5.

create view ShipmentDatesFromWarehouse5 as
select order_id, ship_date
from Shipments
where warehouse_id=5;

select * from ShipmentDatesFromWarehouse5;


-- A tigger that updates order_amount based on quantity and unit price of order_item

DELIMITER //
create trigger UpdateOrderAmt
after insert on OrderItems
for each row
BEGIN
	update Orders set order_amt=(new.qty*(select distinct unitprice from Items NATURAL JOIN OrderItems where item_id=new.item_id)) where Orders.order_id=new.order_id;
END; //
DELIMITER ;

INSERT INTO Orders VALUES
(06, "2020-12-23", 4, 1200);
INSERT INTO OrderItems VALUES 
(06, 001, 5); -- This will automatically update the Orders Table also
-- own
insert into orders values(07,"2021-10-10",3,35); -- own below is to delete so as to show
INSERT INTO OrderItems VALUES 
(07, 001, 5); -- (400*5=2000) This will automatically update the Orders Table also

select * from Orders;

delete from orders where odate="2021-10-10";


