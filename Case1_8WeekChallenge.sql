-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    sales.customer_id, 
    SUM(menu.price)
FROM sales
JOIN menu ON menu.product_id = sales.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id ASC

-- 2. How many days has each customer visited the restaurant?
SELECT 
    customer_id, 
    COUNT(DISTINCT(order_date)) AS visits
FROM sales
GROUP BY sales.customer_id

-- 3. What was the first item from the menu purchased by each customer?
WITH ordem_vendas AS (
  SELECT 
	s.customer_id,
    s.order_date,
	me.product_name,
	RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) as rnk
FROM sales s
INNER JOIN menu me ON me.product_id = s.product_id
)

	SELECT
    	customer_id,
        product_name
    FROM ordem_vendas
    WHERE rnk = 1
    GROUP BY customer_id, product_name

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?


SELECT me.product_name, COUNT(me.product_name) AS quantity
FROM menu me
INNER JOIN sales s ON s.product_id = me.product_id
GROUP BY me.product_name
ORDER BY quantity DESC LIMIT 1

-- 5. Which item was the most popular for each customer?

WITH itens AS (
  SELECT 
      s.customer_id,
      m.product_name,
      COUNT(m.product_id) as orders,
  	  RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) as maiores_pedidos
FROM sales s
INNER JOIN menu m 
  ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
) 

SELECT
	customer_id,
    product_name,
    orders
FROM itens
WHERE maiores_pedidos = 1


-- 6. Which item was purchased first by the customer after they became a member?
WITH after_members AS (
  SELECT
    m.customer_id, 
    s.product_id,
    ROW_NUMBER() OVER (
      PARTITION BY m.customer_id
      ORDER BY s.order_date) AS rnk
  FROM members m
  INNER JOIN sales s
    ON m.customer_id = s.customer_id
  WHERE s.order_date > m.join_date
)

SELECT 
  customer_id, 
  product_name 
FROM after_members a
INNER JOIN menu m
  ON a.product_id = m.product_id
WHERE rnk = 1
ORDER BY customer_id ASC;
