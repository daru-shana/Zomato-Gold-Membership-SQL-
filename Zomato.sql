use Zomato;

drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

select *from goldusers_signup;

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

select *from users;

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

select *from sales;

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- 1. total amount each coustomer spent on zomato

select a.userid, sum(b.price) as total 
from sales a inner join product b
on a.product_id = b.product_id
group by a.userid;

-- 2. howmany days did these coustomers visited zomato

select userid, count(distinct created_date) as distinct_days 
from sales 
group by userid;

-- 3. what is the first product purchased by each customer

select * 
from ( select *, rank() over(partition by userid order by created_date) rnk from sales ) a where rnk = 1;

-- 4. what is the most purchased item on the menu and how many times wasit purchased by all customers.

select userid, count(product_id) cnt from sales where product_id = 
(select top 1 product_id
from sales 
group by product_id 
order by count(product_id) desc)
group by userid
 
 -------------------------------------------------
create table a(a integer, b integer);
insert into a(a,b)
values
(0,1),
(1,2)

create table b(b integer, c integer);
insert into b(b,c)
values
(0,1),
(1,2)

select * from a;
select * from b;

select * from a a inner join b b on a.a = b.b;

drop table a;
drop table b;

create table c(a integer);
insert into c(a)
values
(0),
(1),
(2),
(3)

create table d(b integer);
insert into d(b)
values
(0),
(1),
(2),
(3)

select a.a, b.b from c a inner join d b on a.a = b.b

-----------------------------------------------------------------

-- 5. which item was the most popular for each customer

select *, rank() over(partition by userid order by cnt desc) rnk from 
(select userid, product_id, count(product_id) cnt from sales group by userid, product_id) a 

select * from
(select *, rank() over(partition by userid order by cnt desc) rnk from 
(select userid, product_id, count(product_id) cnt from sales group by userid, product_id) a ) b
where rnk =1

-- 6. which item as purchased first by the customer after they become a gold member

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

select * from
(select *,rank() over(partition by userid order by created_date asc) ranke from
(select a.userid , a.created_date, a.product_id, b.gold_signup_date 
from sales a, goldusers_signup b
where created_date > gold_signup_date and a.userid = b.userid) a) b 
where ranke = 1;

-- 7. which item as purchased first by the customer just before they become a gold member

select * from
(select *,rank() over(partition by userid order by created_date desc) ranke from
(select a.userid , a.created_date, a.product_id, b.gold_signup_date 
from sales a, goldusers_signup b
where created_date < gold_signup_date and a.userid = b.userid) a) b 
where ranke = 1;

-- 8. what is the total orders and amount spent for each member before they become a gold member.
---------------------------------working
select c.userid,count(c.product_id), sum(d.price) from
(select *,rank() over(partition by userid order by created_date desc) ranke from
(select a.userid , a.created_date, a.product_id, b.gold_signup_date 
from sales a, goldusers_signup b
where created_date < gold_signup_date and a.userid = b.userid) c) , product d
where c.userid = d.userid;

select a.userid, count(a.product_id) county, sum(c.price) total_amunt
from sales a, goldusers_signup b , product c
where created_date < gold_signup_date and a.userid = b.userid
group by a.userid
------------------------------------------ working
select e.userid, sum(e.price) from
(select c.* , d.price from 
(select a.userid , a.created_date, a.product_id, b.gold_signup_date 
from sales a, goldusers_signup b
where created_date < gold_signup_date and a.userid = b.userid) c, product d
where c.product_id = d.product_id) e
group by e.userid;

-- 9. if buying each product gerenrates points for eg 5rs = 2 zomato points(zp)  and
--each product has different purchasing points for 
--eg: for p1 5rs=1 z p zp, for p2 2rs = 1 zp and for p3 7rs =1 zp

-- 9a. calculate points collected by each customers 
---------------------------------------------
select d.*,(d.amount/ d.points)as points_for_each_product_id from
(select c.*, case when product_id = 1 then 5
				 when product_id = 2 then 2
				 when product_id = 3 then 7 
				 else 0 
				 end
				 as points 
from (select a.userid ,a.product_id, sum(b.price) as amount
from sales a , product b 
where a.product_id = b.product_id
group by a.userid, a.product_id) c) d
----------------------------------
select userid, sum(points_for_each_product_id) as points_for_each_customer from 
(select d.*,(d.amount/ d.points)as points_for_each_product_id from
(select c.*, case when product_id = 1 then 5
				 when product_id = 2 then 2
				 when product_id = 3 then 7 
				 else 0 
				 end
				 as points 
from (select a.userid ,a.product_id, sum(b.price) as amount
from sales a , product b 
where a.product_id = b.product_id
group by a.userid, a.product_id) c) d)e
group by userid;

-- 9b. and for which product most points have been gicen till now

select g.* distinct amount from
(select e.* , rank() over(partition by product_id order by points_for_each_product_id desc) 
as ranke from
(select d.*,(d.amount/ d.points)as points_for_each_product_id from
(select c.*, case when product_id = 1 then 5
				 when product_id = 2 then 2
				 when product_id = 3 then 7 
				 else 0 
				 end
				 as points 
from (select a.userid ,a.product_id, sum(b.price) as amount
from sales a inner join product b 
on a.product_id = b.product_id
group by a.userid, a.product_id) c) d)e)f
where ranke = 1)g 


