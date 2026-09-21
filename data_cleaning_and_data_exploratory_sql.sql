-- CREATING THE DATABASE
CREATE DATABASE sales_transaction_powerbi;

USE sales_transaction_powerbi;

-- CREATING THE TABLE COLUMNS. "DATA TABLE IMPORT WIZARD" WAS TAKING LONG TO IMPORT THE DATA SO I HAD TO USE THE LOAD FILE QUERY WHICH IMPORTED THE 10,000 rows IN LESS THAN 3 SECONDS.
CREATE TABLE power_bi_sales (
order_id INT,
order_date DATE,
customer_name VARCHAR(100),
gender VARCHAR(10),
age INT,
city VARCHAR(100),
state VARCHAR(100),
region VARCHAR(100),
product VARCHAR(100),
category VARCHAR(100),
quantity INT,
unit_price DOUBLE,
`discount%` INT,
sales DOUBLE,
cost DOUBLE,
profit DOUBLE,
sales_person VARCHAR(100),
payment_mode VARCHAR(100),
customer_type VARCHAR(100),
rating INT
)
;

SET GLOBAL local_infile =1;
-- fast import
LOAD DATA LOCAL INFILE "D:/My Data Analysis Journey/PowerBI_Sales_Dataset_10000.csv"
INTO TABLE power_bi_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM power_bi_sales;

-- DATA CLEANING
-- TRIMMING DATA

UPDATE power_bi_sales
SET order_id=trim(order_id), 
order_date=trim(order_date), 
customer_name=trim(customer_name), 
gender=trim(gender), 
age=trim(age), 
city=trim(city), 
state=trim(state), 
region=trim(region), 
product=trim(product), 
category=trim(category), 
quantity=trim(quantity), 
unit_price=trim(unit_price), 
`discount%`=trim(`discount%`), 
sales=trim(sales), 
cost=trim(cost), 
profit=trim(profit), 
sales_person=trim(sales_person), 
payment_mode=trim(payment_mode), 
customer_type=trim(customer_type), 
rating=trim(rating);

-- FINDING NULLS OR BLANK RECORDS
-- I'M USING THE QUERY BELOW. I REPLACES THE COLUMN NAME EVERYTIME I WANT TO CHECK A NEW COLIMN. i checked for all 20 columns
SELECT rating
FROM power_bi_sales
WHERE rating is null ;

SELECT rating
FROM power_bi_sales
WHERE rating = '';

-- Investigating Inconsistent columns. Colimns i focused on: customer_name, gender, age, city, state, region, product, category, sales_person, payment_mode, customer_type, rating
SELECT DISTINCT state
FROM power_bi_sales;

-- Investigating duplicates using CTE and Window Functions
-- I checked for exact duplicate records based on the complete set of attributes.

WITH duplicate_cte AS 
(
SELECT *,
row_number() over(partition by order_id, order_date, customer_name, gender, age, city, state, region, product, category, quantity, unit_price, `discount%`, sales, cost, profit, sales_person, payment_mode, customer_type, rating) AS head_count
FROM power_bi_sales
)
SELECT order_id
FROM duplicate_cte
WHERE head_count>1;

-- Creating new tables
-- Creating a customer_id

CREATE TABLE power_bi_sales2 LIKE power_bi_sales;

SELECT *
FROM power_bi_sales2;

-- Because the source dataset did not contain a customer ID, I generated a surrogate identifier using the available customer attributes. 

INSERT INTO power_bi_sales2
SELECT *, 
	dense_rank() over(order by customer_name,gender,age) AS customer_id
FROM power_bi_sales;

-- Creating a Product_id for all the similar pruducts
CREATE TABLE power_bi_sales3 LIKE power_bi_sales2;

SELECT *
FROM power_bi_sales3;

ALTER TABLE power_bi_sales3
ADD COLUMN product_id INT;

INSERT INTO power_bi_sales3 (
order_id, order_date, customer_name, 
gender, age, city, state, region, product, category, quantity, unit_price, `discount%`, sales, cost, 
profit, sales_person, payment_mode, customer_type, rating, customer_id,product_id)
SELECT order_id, 
order_date, 
customer_name, 
gender, 
age, 
city, 
state, 
region, 
product, 
category, 
quantity, 
unit_price, 
`discount%`, 
sales, 
cost, 
profit, 
sales_person, 
payment_mode, 
customer_type, 
rating, 
customer_id, 
dense_rank() over(order by product) AS product_id
FROM power_bi_sales2;
 
-- CREATING A CUSTOMER DETAILS THAT ILL INLCUDE ALL CUSTOMER'S PERSONAL DETAILS
CREATE TABLE dim_customer (
customer_id INT,
customer_name VARCHAR(100),
gender VARCHAR(100),
age INT);

INSERT INTO dim_customer
SELECT distinct customer_id,customer_name,gender,age
FROM power_bi_sales3;

-- Creating a dimensional table for products

CREATE TABLE dim_product (
product_id INT,
producr VARCHAR(100),
category VARCHAR(100));

INSERT INTO dim_product
SELECT DISTINCT product_id,product,category
FROM power_bi_sales3;

-- Creating Fact sales that will contain all transactions and their attributes
CREATE TABLE fact_sales (
order_id INT,  
order_date DATE,
customer_id INT,   
product_id INT, 
quantity INT, 
unit_price DOUBLE, 
`discount%` INT, 
sales DOUBLE, 
cost DOUBLE, 
profit DOUBLE, 
sales_person VARCHAR(100), 
payment_mode VARCHAR(100), 
customer_type VARCHAR(100), 
city VARCHAR(100), 
state VARCHAR(100), 
region VARCHAR(100),
rating INT);

INSERT INTO fact_sales
SELECT order_id,  
order_date,
customer_id ,   
product_id , 
quantity , 
unit_price , 
`discount%` , 
sales , 
cost , 
profit , 
sales_person, 
payment_mode , 
customer_type , 
city , 
state , 
region ,
rating 
FROM power_bi_sales3;

ALTER TABLE dim_product
RENAME column producr to product;

-- Exploatory Aalysis
-- Pre-visualization queries: Answering key questios here to verify Power BI logic later.

SELECT *
FROM fact_sales;

SELECT *
FROM dim_customer;

SELECT *
FROM dim_product;

-- Question: How many records or sales were recorded?
SELECT 
	count(order_id)
FROM fact_sales;

-- Question: How many unique customers do you have?
SELECT 
	count(customer_id) as number_of_unique_customers
FROM dim_customer;

-- Question: How many products are there?
SELECT
	count(product_id) as number_of_products
FROM dim_product;

-- Question: Does one product belong to one category?
SELECT
	product,
    count(distinct category) as category_count
FROM dim_product
GROUP BY product;

-- Question: Ratio of male to female customers?
SELECT 
	gender,
    count(customer_id),(count(customer_id)/sum(count(customer_id)) over())*100 as percentage
FROM dim_customer
GROUP BY gender;

-- Question: What city,state or region had the most total sales?
SELECT 
	city, sum(sales) AS city_sales
FROM fact_sales
GROUP BY city
ORDER BY city_sales DESC
LIMIT 5;

SELECT 
	state, sum(sales) AS state_sales
FROM fact_sales
GROUP BY state
ORDER BY state_sales DESC
LIMIT 5;

SELECT 
	region, sum(sales) AS region_sales
FROM fact_sales
GROUP BY region
ORDER BY region_sales DESC
LIMIT 5;

-- Question: Age group with the highest sales
WITH calculating_age_group AS (
	SELECT cus.age,sal.sales,
		CASE
			WHEN cus.age between 18 and 25 THEN "18-25"
			WHEN cus.age between 26 and 35 THEN "26-35"
			WHEN cus.age between 36 and 45 THEN "36-45"
			WHEN cus.age between 46 and 60 THEN "46-60"
			ELSE "60+"
	END AS age_group
FROM dim_customer cus
JOIN fact_sales sal
ON cus.customer_id=sal.customer_id
)
SELECT age_group,sum(sales) as total_sales 
FROM calculating_age_group
GROUP BY age_group ;

-- Question: Age group with the highest sales
WITH calculating_age_group AS (
	SELECT cus.age,sal.profit,
		CASE
			WHEN cus.age between 18 and 25 THEN "18-25"
			WHEN cus.age between 26 and 35 THEN "26-35"
			WHEN cus.age between 36 and 45 THEN "36-45"
			WHEN cus.age between 46 and 60 THEN "46-60"
			ELSE "60+"
	END AS age_group
FROM dim_customer cus
JOIN fact_sales sal
ON cus.customer_id=sal.customer_id
)
SELECT age_group,sum(profit) as total_profit
FROM calculating_age_group
GROUP BY age_group ;


-- Which product had the highest sales?
SELECT p.product,count(s.order_id) AS order_count
FROM dim_product p
JOIN fact_sales s
	ON p.product_id=s.product_id
GROUP BY p.product
ORDER BY order_count DESC;

-- Which product generated the highest sales?
SELECT p.product,sum(s.sales) AS total_sales
FROM dim_product p
JOIN fact_sales s
	ON p.product_id=s.product_id
GROUP BY p.product
ORDER BY total_sales DESC;

-- Which product generated the highest profit?
SELECT p.product,sum(s.profit) AS total_profit
FROM dim_product p
JOIN fact_sales s
	ON p.product_id=s.product_id
GROUP BY p.product
ORDER BY total_profit DESC;	

-- Question: Sales person of the year, how many orders they had, profit they generated and how many products they sold
SELECT sales_person,
	count(order_id) AS orders_they_were_in_charge_of,
	RANK() OVER(ORDER BY count(order_id) DESC) AS `rank`,
	sum(profit) AS profit_they_generated,
	RANK() OVER(ORDER BY sum(profit) DESC) AS `rank`,
	sum(quantity) AS quantities_they_sold,
	RANK() OVER(ORDER BY sum(quantity) DESC) AS `rank`
FROM fact_sales
GROUP BY 
	sales_person;

-- Question: Which salesperson had the biggest ptofit margin?
SELECT sales_person,
	sum(sales) AS total_sales,
	sum(profit) AS total_profit,
	sum(profit)/sum(sales)*100 AS profit_margin
FROM fact_sales
GROUP BY 
	sales_person
ORDER BY 
	profit_margin DESC ;

-- Question: Whats the profit margin?

SELECT
	sum(profit)/sum(sales)*100 AS profit_margin
FROM fact_sales;

SELECT 
	p.product,
    sum(s.sales) AS total_sales,
    sum(s.profit) AS total_profit,
    sum(s.profit)/sum(s.sales)*100 AS profit_margin
FROM fact_sales AS s
JOIN dim_product AS p
	ON s.product_id=p.product_id
GROUP BY p.product
ORDER BY profit_margin DESC;

-- Final Data Validation
-- Date range
SELECT 
	MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM fact_sales;

-- Sales
SELECT
	SUM(sales) AS total_sales
FROM fact_sales;

-- Cost
SELECT 
	SUM(cost) AS total_cost
FROM fact_sales;

-- Profit
SELECT
	SUM(profit) AS total_profit
FROM fact_sales;

-- Quantity
SELECT
	SUM(quantity) AS total_quantity
FROM fact_sales;