-- Final Project SQL

-- Data Preparation,
-- Changing id column in all table.
Alter Table order_detail
rename column id to order_id;

Alter Table sku_detail
rename column id to sku_id;

Alter Table payment_detail
rename column payment_method_id to payment_id;

-- Check Duplicate
SELECT order_id, customer_id, sku_id, COUNT(*) AS duplicate_count
FROM order_detail
GROUP BY order_id, customer_id, sku_id
HAVING COUNT(*) > 1; 
--Notes, order_id have many duplicate but it come from another sku_id in same transaction

/* After I examined the data, I have a suspicion that the data provided is not Raw Data,
but rather data with Null Values that have been changed to a default value of 0. */

-- Question Number 1
select
	date_part('month', order_date) as month,
	sum(after_discount) as total_after_discount
from
	order_detail
where
	is_valid = 1 and order_date between '2021-01-01' and '2021-12-31'
group by
	month
order by
	total_after_discount DESC;

-- Question Number 2
select
	sd.category, sum(od.after_discount) as total_transaction
from
	order_detail as od
left join
	sku_detail as sd on od.sku_id = sd.sku_id
where
	od.is_valid = 1 and od.order_date between '2022-01-01' and '2022-12-31'
group by
	sd.category
order by
	total_transaction desc;

-- Question Number 3
select
	sd.category,
	sum(od.after_discount) filter (where date_part('year', od.order_date) = 2021) as Total_Transaction_2021,
	sum(od.after_discount) filter (where date_part('year', od.order_date) = 2022) as Total_Transaction_2022,
	(sum(od.after_discount) filter (where date_part('year', od.order_date) = 2022)-
	 sum(od.after_discount) filter (where date_part('year', od.order_date) = 2021)) as transaction_diff
from
	order_detail as od
left join
	sku_detail as sd on od.sku_id = sd.sku_id
where
	is_valid = 1
group by
	sd.category
order by
	transaction_diff asc;
/* Mobile & Tablets sales increased the most
Others Category and Books sales decreased the most */

--  Question Number 4
select
	pd.payment_method, count(distinct od.order_id) as Total_Order
from 
	order_detail as od
left join
	payment_detail as pd on od.payment_id = pd.payment_id
where
	order_date between '2022-01-01' and '2022-12-31' and is_valid = 1
group by
	pd.payment_method
order by
	Total_Order desc
Limit 5;

-- Question Number 5
SELECT
    CASE
        WHEN sd.sku_name ~ 'Apple' THEN 'Apple'
        WHEN sd.sku_name ~ 'Samsung' THEN 'Samsung'
        WHEN sd.sku_name ~ 'Sony' THEN 'Sony'
        WHEN sd.sku_name ~ 'Huawei' THEN 'Huawei'
        WHEN sd.sku_name ~ 'Lenovo' THEN 'Lenovo'
    END AS brand,
    SUM(od.after_discount) AS Total_Transaction
FROM
    sku_detail AS sd
LEFT JOIN
    order_detail AS od ON sd.sku_id = od.sku_id AND od.is_valid = 1
where
	CASE
        WHEN sd.sku_name ~ 'Apple' THEN 'Apple'
        WHEN sd.sku_name ~ 'Samsung' THEN 'Samsung'
        WHEN sd.sku_name ~ 'Sony' THEN 'Sony'
        WHEN sd.sku_name ~ 'Huawei' THEN 'Huawei'
        WHEN sd.sku_name ~ 'Lenovo' THEN 'Lenovo'
    END IS NOT NULL
GROUP BY
    brand
ORDER BY
    Total_Transaction DESC;

-- Checking the Data
select * from order_detail;
select * from payment_detail;
select * from sku_detail;