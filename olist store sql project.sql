create database olist_store_analysis;
use olist_store_analysis;

-- KPI 1 - Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics.

select * from `olist_orders_dataset cleaned`;
select * from `olist_order_payments_dataset cleaned`;



SELECT
kpi1.day_end ,
concat(round(kpi1.total_payments / (select sum(payment_value) from `olist_order_payments_dataset cleaned`) *100,2)
, '%') as percentage_values
from
( select ord.day_end , sum(pmt.payment_value) as total_payments
from `olist_order_payments_dataset cleaned` as pmt
join
(Select distinct order_id,
case
when weekday(order_purchase_timestamp) in (5,6) then 'Weekend'
else 'Weekdays'
end as Day_end
from `olist_orders_dataset cleaned`) as ord
on ord.order_id = pmt.order_id
group by ord.day_end) as kpi1;


--  KPI 2- Number of Orders with review score 5 and payment type as credit card.

SELECT pmt.payment_type, COUNT(pmt.order_id) AS Total_Orders
FROM `olist_order_payments_dataset cleaned` AS pmt
JOIN (
    SELECT DISTINCT ord.order_id, rw.review_score
    FROM `olist_orders_dataset cleaned`AS ord
    JOIN `olist_order_reviews_dataset cleaned` AS rw ON ord.order_id = rw.order_id
    WHERE rw.review_score = 5
) AS mS ON pmt.order_id = mS.order_id
GROUP BY pmt.payment_type
ORDER BY Total_Orders DESC;

-- KPI 3 - Average number of days taken for Order_delivered_Customer_Date for pet shop

Select prod.product_category_name,
round(avg(datediff(ord.order_delivered_customer_date,ord.order_purchase_timestamp)),0)
AS av_delivery_date
from `olist_orders_dataset cleaned` as ord join
(Select product_id,order_id,product_category_name from
olist_products_dataset join `olist_order_items_dataset cleaned` using (product_id)) as prod
on ord.order_id=prod.order_id where prod.product_category_name="pet_shop" group by prod.product_category_name;

--  KPI 4 - Average price and payment values from customers of sao paulo
-- For Average Price

SELECT cust.customer_city, round(AVG(pmt_price.price),0) AS avg_price 
FROM  `olist_customers_dataset cleaned`AS cust 
JOIN (SELECT pymnt.customer_id, pymnt.payment_value, item.price FROM `olist_order_items_dataset cleaned`AS item JOIN 
(SELECT ord.order_id, ord.customer_id, pmt.payment_value FROM `olist_orders_dataset cleaned` AS ord 
JOIN `olist_order_payments_dataset cleaned` AS pmt ON ord.order_id=pmt.order_id) AS pymnt 
ON item.order_id=pymnt.order_id) AS pmt_price ON cust.customer_id=pmt_price.customer_id 
 WHERE cust.customer_city="sao paulo";
 
 -- For Average payment
 
SELECT cust.customer_city, round(AVG(pmt.payment_value),0) AS avg_payment_value
FROM `olist_customers_dataset cleaned`cust INNER JOIN `olist_orders_dataset cleaned` ord
ON cust.customer_id=ord.customer_id INNER JOIN
`olist_order_payments_dataset cleaned` AS pmt ON ord.order_id=pmt.order_id
WHERE customer_city="sao paulo";
 
 
 --  KPI 5
-- Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores

Select rw.review_score, round(avg (datediff (ord.order_delivered_customer_date, ord.order_purchase_timestamp)), 0) as avg_shipping_days
from `olist_orders_dataset cleaned` as ord join `olist_order_reviews_dataset cleaned` rw on rw.order_id=ord.order_id
Group by rw.review_score
Order by rw.review_score;