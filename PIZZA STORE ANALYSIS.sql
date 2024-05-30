create database Pizzahut_Database;
use pizzahut_database;
select * from pizzas;
select * from orders;
select * from pizza_types;
select * from order_details;

#Basic:
#Retrieve the total number of orders placed.
select count(order_id) "total orders" from order_details;

#Calculate the total revenue generated from pizza sales.
select round(sum(price*quantity),2) as total_revenue 
from pizzas
inner join order_details
using(pizza_id);

#Identify the highest-priced pizza.
select name,price from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type_id
order by price desc
limit 1;

#Identify the most common pizza size ordered.
select size ,sum(quantity) as total_quantity from order_details
join pizzas using(pizza_id)
group by size
order by sum(quantity) desc;

#List the top 5 most ordered pizza types along with their quantities.
SELECT 
    name, SUM(quantity) AS total_orders
FROM
    order_details
        JOIN
    pizzas USING (pizza_id)
        JOIN
    pizza_types USING (pizza_type_id)
GROUP BY name
ORDER BY SUM(quantity) DESC
LIMIT 5;

#Intermediate:
#find out the total quantity of each pizza category ordered.
SELECT 
    category, SUM(quantity) AS total_orders
FROM
    order_details
        JOIN
    pizzas USING (pizza_id)
        JOIN
    pizza_types USING (pizza_type_id)
GROUP BY category
ORDER BY SUM(quantity) DESC;

#Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time) AS hours, COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY hours;

#find out the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS total_pizzas
FROM
    pizza_types
GROUP BY category;

#Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total_orders), 2) AS avg_day_quantity
FROM
    (SELECT 
        date, SUM(quantity) AS total_orders
    FROM
        order_details
    JOIN orders USING (order_id)
    GROUP BY date) AS total_quantity;

SELECT 
    name, ROUND(SUM(quantity * price), 2) AS revenue
FROM
    order_details
        JOIN
    pizzas USING (pizza_id)
        JOIN
    pizza_types USING (pizza_type_id)
GROUP BY name
ORDER BY ROUND(SUM(quantity * price), 2) DESC
LIMIT 3;

SELECT 
    pizza_types.category,
    CONCAT(ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                            ROUND(SUM(price * quantity), 2) AS total_revenue
                        FROM
                            pizzas
                                INNER JOIN
                            order_details USING (pizza_id))) * 100,
                    2),
            ' ',
            '%') AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

#Analyze the cumulative revenue generated over time.
select date,sum(revenue) over(order by date)as cumulative_revenue
from
(select date,
sum(quantity* price) as revenue
from order_details 
join pizzas using(pizza_id)
join orders using(order_id)
group by date) as sales;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from (select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as info1)info2
where rn <=3;