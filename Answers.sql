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
SELECT pt.category, ROUND(SUM(p.price*o.quantity)) AS rev
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

