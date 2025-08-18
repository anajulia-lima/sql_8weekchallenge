-- 1. What is the total amount each customer spent at the restaurant?
SELECT sales.customer_id, SUM(menu.price)
FROM sales
JOIN menu ON menu.product_id = sales.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id