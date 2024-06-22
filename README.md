# Problem Statement  
The objective of this analysis is to evaluate a year's worth of sales data from a fictitious pizza place to identify opportunities to drive more sales and improve operational efficiency. The analysis will focus on understanding sales patterns, customer preferences, and operational bottlenecks.



## 1. ASK  
Stakeholder: Maven (Manager)  

### Questions:  
- How many customers do we have each day? Are there any peak hours?
- How many pizzas are typically in an order? Do we have any bestsellers?
- How much money did we make this year? Can we indentify any seasonality in the sales?
- Are there any pizzas we should take of the menu, or any promotions we could leverage?



## 2. PREPARE  
### Data Storage:  
The public dataset is completely available on the Maven Analytics website platform where it stores and consolidates all available datasets for analysis in the Data Playground. The specific individual datasets at hand can be obtained at this link below: https://www.mavenanalytics.io/blog/maven-pizza-challenge

### Data Organized:  
This Pizza Restaurant Sales dataset uploaded by Shi Long Zhuang was downloaded from Kaggle.  
This dataset contains 4 file. It is saved on the computer in the Pizza Sales folder.



## 3. PROCESS
### Tools Used:  
- MySQL
- MS-Word

### Data Used:
order_details, orders, pizza_types, pizzas

### About Data:  
This dataset contains a year's worth of sales data from a fictitious pizza place, including details on orders, pizzas, and their types. The dataset is structured across several tables, each with specific fields that describe various aspects of the sales transactions.

## Table Descriptions

#### Orders Table
| Field    | Description                                                       |
|----------|-------------------------------------------------------------------|
| order_id | Unique identifier for each order placed                           |
| date     | Date the order was placed (entered into the system prior to cooking & serving) |
| time     | Time the order was placed (entered into the system prior to cooking & serving) |

#### Order Details Table
| Field             | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| order_details_id  | Unique identifier for each pizza placed within each order                   |
| order_id          | Foreign key that ties the details in each order to the order itself         |
| pizza_id          | Foreign key that ties the pizza ordered to its details, like size and price |
| quantity          | Quantity ordered for each pizza of the same type and size                   |

#### Pizzas Table
| Field         | Description                             |
|---------------|-----------------------------------------|
| pizza_id      | Unique identifier for each pizza        |
| pizza_type_id | Foreign key that ties each pizza to its broader pizza type |
| size          | Size of the pizza (Small, Medium, Large, X Large, or XX Large) |
| price         | Price of the pizza in USD               |

#### Pizza Types Table
| Field         | Description                                                         |
|---------------|---------------------------------------------------------------------|
| pizza_type_id | Unique identifier for each pizza type                               |
| name          | Name of the pizza as shown in the menu                              |
| category      | Category that the pizza falls under in the menu (Classic, Chicken, Supreme, or Veggie) |
| ingredients   | Comma-delimited ingredients used in the pizza as shown in the menu (they all include Mozzarella Cheese, even if not specified; and they all include Tomato Sauce, unless another sauce is specified) |

## Summary of Data Relationships

- **Orders** table contains high-level details of each order.
- **Order Details** table provides specific information about each pizza included in an order.
- **Pizzas** table lists individual pizzas with details about their size and price.
- **Pizza Types** table categorizes pizzas and lists their ingredients.

### Data Cleaning & Transformation
- Duplicates were checked with the Remove Duplicates function.
- Gaps were checked with the TRIM function.
- Pizza sizes represented as S, M, L, X, XL, XXL in the pizza_size column were changed to Small, Medium, Large, XLarge, XXLarge with the Find & Replace function.
- Blank and NULL checked for all columns with filter function.
- Saved as a pizza_sales.csv



## 4. ANALYZE  
Data Analyzing  
Microsoft SQL was used to analyze data.  

-- KPI’s REQUIREMENT --  
#1 Retrieve the total number of orders placed.  
SELECT COUNT(*) AS total_orders  
FROM orders;  
    
#2 Calculate the total revenue generated from pizza sales.  
SELECT ROUND(SUM(price * quantity), 2) AS rev  
FROM order_details o  
JOIN pizzas p   
ON o.pizza_id = p.pizza_id;  

#3 Identify the highest-priced pizza.  
SELECT name, price  
FROM pizzas p  
JOIN pizza_types t  
ON p.pizza_type_id=t.pizza_type_id  
ORDER BY price DESC  
LIMIT 1;  

#4 Identify the most common pizza size ordered.  
SELECT size, COUNT(*) AS cnt  
FROM order_details o  
JOIN pizzas p  
ON o.pizza_id=p.pizza_id  
GROUP BY size  
ORDER BY cnt DESC;  

#5 List the top 5 most ordered pizza types along with their quantities.  
WITH cte1 AS(  
SELECT pt.name, SUM(o.quantity) AS qty  
FROM pizza_types pt  
JOIN pizzas p  
ON pt.pizza_type_id=p.pizza_type_id  
JOIN order_details o  
ON p.pizza_id=o.pizza_id  
GROUP by pt.name)  
SELECT * FROM cte1  
ORDER BY qty DESC  
LIMIT 5;  

#6 Join the necessary tables to find the total quantity of each pizza category ordered  
SELECT pt.category, SUM(o.quantity) AS qty  
FROM pizza_types pt  
JOIN pizzas p  
ON pt.pizza_type_id=p.pizza_type_id  
JOIN order_details o  
ON p.pizza_id=o.pizza_id  
GROUP BY category  
ORDER BY qty DESC;  

#7 Determine the distribution of orders by hour of the day.  
SELECT HOUR(order_time) AS hrs, COUNT(order_id) AS order_cnt  
FROM orders  
GROUP BY hrs  
ORDER BY order_cnt DESC;  

#8 Join relevant tables to find the category-wise distribution of pizzas.  
SELECT category, COUNT(*) AS pizza_type  
FROM pizza_types  
GROUP BY category;  

#9 Group the orders by date and calculate the average number of pizzas ordered per day.  
WITH cte1 AS(  
SELECT DATE(order_date) AS order_date, SUM(od.quantity) AS pizza  
FROM orders o  
JOIN order_details od  
ON o.order_id=od.order_id  
GROUP BY order_date)  
SELECT ROUND(AVG(pizza)) AS avg_pizza_order_per_day  
FROM cte1;  

#10 Determine the top 3 most ordered pizza types based on revenue.  
SELECT pt.name, SUM((p.price*od.quantity)) AS rev  
FROM pizza_types pt  
JOIN pizzas p  
ON pt.pizza_type_id=p.pizza_type_id  
JOIN order_details od  
ON p.pizza_id=od.pizza_id  
GROUP BY pt.name  
ORDER BY rev DESC  
LIMIT 3;  

#11 Calculate the percentage contribution of each pizza type to total revenue.  
WITH cte1 AS(  
SELECT pt.category, ROUND(SUM(p.price* o.quantity)) AS rev  
FROM pizza_types pt  
JOIN pizzas p  
ON pt.pizza_type_id=p.pizza_type_id  
JOIN order_details o  
ON o.pizza_id=p.pizza_id  
GROUP BY pt.category),  
cte2 AS(  
SELECT category, rev*100/SUM(rev) OVER() AS pct_decimal  
FROM cte1)  
SELECT category, ROUND(pct_decimal,2) AS pct  
FROM cte2;  

#12 Analyze the cumulative revenue generated over time.  
WITH cte1 AS(  
SELECT DATE(o.order_date) AS o_date, ROUND(SUM(od.quantity*p.price),2) AS rev  
FROM orders o  
JOIN order_details od  
ON o.order_id=od.order_id  
JOIN pizzas p  
ON od.pizza_id=p.pizza_id  
GROUP BY o_date)  
SELECT o_date AS order_date, SUM(rev) OVER(ORDER BY o_date) AS cummulative_rev  
FROM cte1;  

#13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.  
WITH cte1 AS(  
SELECT pt.category, pt.name, SUM(p.price*o.quantity) AS rev  
FROM pizza_types pt  
JOIN pizzas p  
ON pt.pizza_type_id=p.pizza_type_id  
JOIN order_details o  
ON o.pizza_id=p.pizza_id  
GROUP BY pt.category, pt.name  
),  
cte2 AS(  
SELECT *, RANK() OVER(PARTITION BY category ORDER BY rev DESC) AS rn  
FROM cte1)  
SELECT * FROM cte2  
WHERE rn<=3;  



## 5. SHARE
![Screenshot (132)](https://github.com/iankitnegi/SQL_Pizza_Sales_Project/assets/132642567/e4057bd4-66fb-4e56-b02f-f1fedecc9c70)
![Screenshot (133)](https://github.com/iankitnegi/SQL_Pizza_Sales_Project/assets/132642567/8dded99a-74f7-4c3f-8ab5-5e2d5ccc4f16)



## 6. ACT  
### Insights:
- Top-selling Pizzas: Classic Deluxe and Barbecue Chicken Pizza dominated the charts!
- Peak Hours: Evenings from 12:00-19:00 has the highest sales volumes.
- Customer Behavior: Large pizzas were more popular among group orders.

### Recommendations:
- Sales can be increased with a campaign on Sundays and Mondays, when pizza sales are lowest.
- Supreme and Veggie categories are the pizza categories with the worst sales, and XLarge and XXLarge sizes are the least sold pizza sizes. These categories and sizes can be evaluated in campaigns.  

Thank you for reading and evaluating my repo :)    
[LinkedIn](https://www.linkedin.com/posts/iankitnegi_sales-report-activity-7198593703102353408-GrAW?utm_source=share&utm_medium=member_desktop)    
