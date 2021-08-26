-- create database Danny's Diner

CREATE DATABASE Dannys_Diner;

-- create table

USE Dannys_Diner
Go

CREATE TABLE sales
(
customer_id varchar(1),
order_date DATE,
product_id int
);

CREATE TABLE members
(
customers_id varchar(1),
join_date DATE
);

CREATE TABLE menu
(
product_id int,
product_name varchar(5),
price int
);

Go

-- Inserting Data in the tables

INSERT INTO sales VALUES
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);


INSERT INTO menu VALUES
(1, 'sushi', 10),
(2, 'curry', 15),
(3, 'ramen', 12);


INSERT INTO members VALUES
('A', '2021-01-07'),
('B', '2021-01-09');


--Looking at the Tables formed

SELECT * FROM Dannys_Diner..sales;

SELECT * FROM Dannys_Diner..menu;

SELECT * FROM Dannys_Diner..members;

-- CASE STUDY QUESTION 01
-- What is the total amount each customer spent at the restaurant?

/*
In this question I used a aggregate function to find the total amount spent by all customer.
*/

Select S.customer_id , sum(P.price) as amount_spent 
from Dannys_Diner..sales S
left join Dannys_Diner..menu P 
on S.product_id = P.product_id
Group by S.customer_id
Order by 2 desc;

/* Solution
customer_id		amount_spent
	A			76
	B			74
	C			36
The solution shows that customer A spent the most $76 during his visit to Danny's Diner.
*/


-- CASE STUDY QUESTION 02
-- How many days has each customer visited the restaurant?

/*I used count function to find the distinct number of the days the customer
visited Danny's Diner. I assumed the customers ordered multiple items in case the 
order date is same.*/


Select customer_id, count(distinct order_date) as days_visited
from Dannys_Diner..sales
group by customer_id
order by 2 desc; 

/* Solution
customer_id    days_visited
B			6
A			4
C			2
*/


-- CASE STUDY QUESTION 03
-- What was the first item from the menu purchased by each customer?

/*
In question 03, I used row number function to partition the customer id according to
order date. So each item is ranked according to the row number. 
Then I used CTE to select only the item that ranked first in the list.
*/


With first_order as(
Select S.customer_id as cus_id, P.product_name as first_item_ordered, Row_number() over (partition by S.customer_id Order by S.order_date) as item_ordered
from Dannys_Diner..sales S
join Dannys_Diner..menu P
on S.product_id = P.product_id)

Select cus_id, first_item_ordered
FROM first_order
Where item_ordered = 1;


/* Solution
cus_id	first_item_ordered
A		sushi
B		curry
C		ramen
*/


-- CASE STUDY QUESTION 04
-- What is the most purchased item on the menu and how many times was it purchased by all customers?

/*I used aggregate function to count each items ordered by each customer.*/

Select Top(1) 
P.product_name,Count(P.product_id) as no_of_times_ordered
from Dannys_Diner..sales S
join Dannys_Diner..menu P
on S.product_id = P.product_id
Group by P.product_name
order by 2 desc;



/* Solution
product_name	no_of_times_ordered
  ramen				8
Seems that, Ramen is the most purchased item in the menu. It was purchased 8 times.
*/


-- CASE STUDY QUESTION 05
-- Which item was the most popular for each customer?

--Steps-
/*Create a fav_item_cte and use DENSE_RANK to rank the order_count for each product by descending order for each customer.
Generate results where product rank = 1 only as the most popular product for each customer.*/


WITH fav_item_cte AS
(
Select S.customer_id, P.product_name, count(P.product_id) as order_count, Dense_Rank() over (partition by S.customer_id order by count(P.product_id) desc) as rank
from Dannys_Diner..sales S
join Dannys_Diner..menu P
on S.product_id = P.product_id
Group by S.customer_id, P.product_name
)
SELECT customer_id, product_name, order_count
from fav_item_cte
Where rank = 1;

/*Solution
customer_id	product_name	order_count
A			ramen				3
B			sushi				2
B			curry				2
B			ramen				2
C			ramen				3

Customer A and C's favourite item is ramen.
Customer B enjoys all items on the menu. He/she is a true foodie, sounds like me!*/



-- CASE STUDY QUESTION 06
-- Which item was purchased first by the customer after they became a member?

/*Steps - 
Create first_purchased_cte by using windows function and partitioning customer_id by ascending order_date. Then, filter order_date to be on or after join_date.
Then, filter table by rank = 1 to show 1st item purchased by each customer.*/


With first_purchased_cte AS
(
Select S.customer_id, S.order_date, S.product_id, P.product_name, M.join_date, Dense_rank() over (partition by customer_id order by order_date) as rank
From Dannys_Diner..sales S
join Dannys_Diner..menu P on S.product_id = P.product_id
join Dannys_Diner..members M  ON S.customer_id = M.customers_id
Where S.order_date >= M.join_date
)
Select customer_id, order_date, product_name 
from first_purchased_cte 
where rank=1; 

--Solutions
/*customer_id	order_date	product_name
A			2021-01-07		curry
B			2021-01-11		sushi*/


-- CASE STUDY QUESTION 07
-- Which item was purchased just before the customer became a member?

/*Steps - 
Create first_purchased_cte by using windows function and partitioning customer_id by descending order_date. Then, filter order_date to be on or after join_date.
Then, filter table by rank = 1 to show 1st item purchased by each customer.*/

With first_purchased_cte AS
(
Select S.customer_id, S.order_date, S.product_id, P.product_name, M.join_date, Dense_rank() over (partition by customer_id order by order_date desc) as rank
From Dannys_Diner..sales S
join Dannys_Diner..menu P on S.product_id = P.product_id
join Dannys_Diner..members M  ON S.customer_id = M.customers_id
Where S.order_date < M.join_date
)
Select customer_id, order_date, product_name 
from first_purchased_cte 
where rank=1; 

/*Solutions- 
customer_id	order_date	product_name
A		   2021-01-01		sushi
A		   2021-01-01		curry
B		   2021-01-04		sushi*/



-- CASE STUDY QUESTION 08
-- What is the total items and amount spent for each member before they became a member?

WITH before_member AS
(
Select S.customer_id, S.order_date, S.product_id, P.product_name, M.join_date, P.price
From Dannys_Diner..sales S
join Dannys_Diner..menu P on S.product_id = P.product_id
join Dannys_Diner..members M  ON S.customer_id = M.customers_id
Where S.order_date < M.join_date
)
Select customer_id, count(distinct product_id) as unique_menu_item, sum(price) as total_sales
from before_member 
Group by customer_id


/*Solution - 
customer_id	unique_menu_item	total_sales
A				2					25
B				2					40
*/

--Before becoming members,

--Customer A spent $ 25 on 2 items.
--Customer B spent $40 on 2 items



-- CASE STUDY QUESTION 09
/*If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how 
many points would each customer have?*/

WITH price_points_cte AS 
(
Select *, 
	Case 
	 When product_id = 1 Then price*20
	 Else price*10
	End AS points 
From Dannys_Diner..menu
)
Select S.customer_id, Sum(P.points) as Total_points
from price_points_cte P
join Dannys_Diner..sales S
on P.product_id = S.product_id
Group by S.customer_id;

/*Solution - 
customer_id	 Total_points
A				860
B				940
C				360*/



-- CASE STUDY QUESTION 10
/*In the first week after a customer joins the program (including their join date) 
they earn 2x points on all items, not just sushi - how many points do customer A
and B have at the end of January?*/


WITH dates_cte AS 
(
   SELECT *, 
      DATEADD(DAY, 6, join_date) AS valid_date, 
      EOMONTH('2021-01-31') AS last_date
   FROM Dannys_Diner..members AS m
)

SELECT d.customers_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price,
   SUM(CASE
      WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
      WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
      ELSE 10 * m.price
      END) AS points
FROM dates_cte AS d
JOIN Dannys_Diner..sales AS s
   ON d.customers_id = s.customer_id
JOIN Dannys_Diner..menu AS m
   ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customers_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price




--Final Solution - 

WITH dates_cte AS 
(
   SELECT *, 
      DATEADD(DAY, 6, join_date) AS valid_date, 
      EOMONTH('2021-01-31') AS last_date
   FROM Dannys_Diner..members AS m
)

SELECT d.customers_id,
   SUM(CASE
      WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
      WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
      ELSE 10 * m.price
      END) AS points
FROM dates_cte AS d
JOIN Dannys_Diner..sales AS s
   ON d.customers_id = s.customer_id
JOIN Dannys_Diner..menu AS m
   ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customers_id


/*Total points for Customer A is 1,370.
Total points for Customer B is 820.*/



--BONUS QUESTIONS
--Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

SELECT s.customer_id, s.order_date, m.product_name, m.price, 
	CASE
		WHEN mm.join_date > s.order_date THEN 'N'
		WHEN mm.join_date <= s.order_date THEN 'Y'
		ELSE 'N'
		END AS member
FROM Dannys_Diner..sales AS s 
LEFT JOIN Dannys_Diner..menu AS m
	ON s.product_id = m.product_id
LEFT JOIN Dannys_Diner..members as mm
	ON s.customer_id = mm.customers_id;


--Rank All The Things - Danny also requires further information about the ranking of customer products, but
--he purposely does not need the ranking for non-member purchases so he expects null ranking values for the
--records when customers are not yet part of the loyalty program.

WITH summary_cte AS
(
SELECT s.customer_id, s.order_date, m.product_name, m.price, 
	CASE
		WHEN mm.join_date > s.order_date THEN 'N'
		WHEN mm.join_date <= s.order_date THEN 'Y'
		ELSE 'N'
		END AS member
FROM Dannys_Diner..sales AS s 
LEFT JOIN Dannys_Diner..menu AS m
	ON s.product_id = m.product_id
LEFT JOIN Dannys_Diner..members as mm
	ON s.customer_id = mm.customers_id
)

SELECT *, CASE
	WHEN member = 'N' THEN NULL 
	ELSE 
		RANK() OVER (PARTITION BY customer_id, member
		ORDER BY order_date) END AS ranking
	FROM summary_cte;


/*OUTPUT

customer_id	order_date	product_name	price	member	ranking
A			2021-01-01		sushi		10			N	NULL
A			2021-01-01		curry		15			N	NULL
A			2021-01-07		curry		15			Y	1
A			2021-01-10		ramen		12			Y	2
A			2021-01-11		ramen		12			Y	3
A			2021-01-11		ramen		12			Y	3
B			2021-01-01		curry		15			N	NULL
B			2021-01-02		curry		15			N	NULL
B			2021-01-04		sushi		10			N	NULL
B			2021-01-11		sushi		10			Y	1
B			2021-01-16		ramen		12			Y	2
B			2021-02-01		ramen		12			Y	3
C			2021-01-01		ramen		12			N	NULL
C			2021-01-01		ramen		12			N	NULL
C			2021-01-07		ramen		12			N	NULL*/



--THANK YOU 