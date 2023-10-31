--1. Questão: Crie uma VIEW que liste os nomes e e-mails de todos os clientes cadastrados.
CREATE OR REPLACE VIEW vw_customers_names_emails
(client, email) AS
SELECT c.name, c.email
FROM customers AS c
		WHERE c.id <100
		ORDER BY c.name ASC;
		
/* SELECT table_name
*FROM information_schema.tables
		WHERE table_schema = 'views_exercises';*/

ALTER VIEW vw_customers_names_emails rename TO vw_customers_personaldata;

SELECT *FROM vw_customers_personaldata;

-- 2. Questão: crie uma VIEW que exiba o nome dos produtos que estão atualmente em estoque.

	-- Obs: É impossível criar uma consulta que mostre a quantidade de produtos no estoque, pois
	-- não há um limite de quantidade de produtos nesse banco de dados, seria possivel um cliente
	-- em um pedido comprar uma quantidade de 99999999 do mesmo produto de uma vez, por exemplo.

INSERT INTO customers (id, name, email) VALUES 
(5001, 'Guilherme Braga', 'guii@gmail.com');

INSERT INTO order_items (order_id, product_id, quantity) VALUES 
(5001, 1, 99999999);

INSERT INTO orders (id, customer_id, order_date) VALUES 
(5001, 5001, '2023-08-28'); 

	-- ^ Exemplo de um cliente comprando uma quantidade gigante do produto, por não possuir limitação

-- Por isso eu criarei uma VIEW que exibe todos os produtos do estoque

CREATE VIEW vw_products_stock
(product) AS
SELECT p.name 
FROM products AS p;

SELECT *FROM vw_products_stock;

--3. Questão: Crie uma VIEW que mostre o total gasto por cada cliente em suas compras.
CREATE VIEW vw_customers_totalspent
(client, total_spent) AS
SELECT c.name, SUM (price*quantity) AS total_spent
FROM customers AS c JOIN
	orders AS o ON o.customer_id = c.id JOIN
	order_items AS oi ON oi.order_id = o.id JOIN
	products AS p ON p.id = oi.product_id
		GROUP BY c.name
		ORDER BY total_spent ASC;
		
SELECT *FROM vw_customers_totalspent;

--4. Questão: Crie uma VIEW que apresente o valor total vendido por cada produto.
CREATE VIEW vw_totalamountsold_per_product
(product, total_amount_sold) AS
SELECT p.name, SUM (p.price*oi.quantity) AS total_amount_sold
FROM products AS p JOIN
	order_items AS oi ON oi.product_id = p.id
			GROUP BY p.name
			having SUM(p.price * oi.quantity) < 999999
			ORDER BY p.name;

SELECT *FROM vw_totalamountsold_per_product;

--5. Questão: Crie uma VIEW que mostre o total de vendas por mês
CREATE OR REPLACE VIEW vw_totalsaler_per_month AS
    SELECT  DATE_TRUNC ('month', o.order_date) AS month
            SUM (p.price * oi.quantity) AS total_sales
    FROM products p JOIN
    order_items oi ON oi.product_id = p.id JOIN
    orders o ON o.id = oi.order_id 
        GROUP BY month
        ORDER BY month;


SELECT *FROM vw_totalsales_per_month;

--Questões intermediárias

--6. Questão: Crie uma VIEW que liste os produtos que foram vendidos mais de 100 vezes, mostrando o nome e a quantidade vendida.
CREATE VIEW vw_products_sold_mustthan100times
(product, quantity) AS
SELECT p.name, SUM (oi.quantity) AS quantity
FROM products AS p JOIN
	order_items AS oi ON oi.product_id = p.id
	GROUP BY p.name
	having SUM (oi.quantity) > 100;

SELECT *FROM vw_products_sold_mustthan100times;

--7. Questão: Crie uma VIEW que exiba os produtos que nunca foram vendidos.
CREATE VIEW vw_products_never_sold
(product, never_sold) AS
SELECT p.name, oi.product_id AS never_sold
FROM products AS p left JOIN
	order_items AS oi ON oi.product_id = p.id
		WHERE oi.product_id is null;

SELECT *FROM vw_products_never_sold;

--8. Questão: Crie uma VIEW materializada que calcule o valor total gasto por cada cliente em suas compras.
CREATE materialized VIEW vwm_customers_totalspent
(client, total_spent) AS
SELECT c.name, SUM (price*quantity) AS total_spent
FROM customers AS c JOIN
	orders AS o ON o.customer_id = c.id JOIN
	order_items AS oi ON oi.order_id = o.id JOIN
	products AS p ON p.id = oi.product_id
		GROUP BY c.name
		ORDER BY total_spent ASC;
/*SELECT matviewname 
*FROM pg_matviews 
		WHERE schemaname = 'views_exercises';*/

SELECT *FROM vwm_customers_totalspent;

--9. Questão: Crie uma VIEW materializada que mostre o total de vendas por mês, considerando apenas os pedidos dos últimos seis meses.
CREATE MATERIALIZED VIEW vw_saleslast_sixmonths  AS
    SELECT  DATE_TRUNC('month', o.order_date) AS month,
            SUM (p.price * oi.quantity) AS total_sales
    FROM products p JOIN
    order_items oi ON oi.product_id = p.id JOIN
    orders o ON o.id = oi.order_id
    WHERE o.order_date >= current_date - interval '6 months'
        GROUP BY month
        ORDER BY month;

ALTER materialized VIEW total_sales_per_lastsixmonths rename TO vwm_total_sales_per_lastsixmonths;

SELECT *FROM total_sales_per_lastsixmonths;

--10. Questão: Crie uma VIEW materializada que liste os produtos mais vendidos, mostrando o nome do produto e a quantidade total vendida.
CREATE materialized VIEW vwm_top_selling_products
(product, quantity) AS
SELECT p.name, SUM (oi.quantity) AS total_quantity_sold
*FROM products AS p JOIN
	order_items AS oi ON oi.product_id = p.id
		GROUP BY p.name
		ORDER BY total_quantity_sold desc
			limit 3;

SELECT *FROM vwm_top_selling_products;

--Questões mais complexas:

--11. Questão: Crie uma VIEW que liste os produtos comprados por cada cliente em cada pedido, exibindo o nome do cliente, o nome do produto e a quantidade.
CREATE VIEW vw_allproducts_purchased
(client, product, quantity) AS
SELECT c.name, p.name, oi.quantity
FROM customers AS c JOIN
	orders AS o ON o.customer_id = c.id JOIN
	order_items AS oi ON oi.order_id = o.id JOIN
	products AS p ON p.id = oi.product_id
		ORDER BY c.name ASC;

SELECT c.name, p.name, oi.quantity
FROM customers AS c JOIN
	orders AS o ON o.customer_id = c.id JOIN
	order_items AS oi ON oi.order_id = o.id JOIN
	products AS p ON p.id = oi.product_id
		ORDER BY c.name ASC;

SELECT *FROM vw_allproducts_purchased;

--12. Questão: Crie uma VIEW que mostre o cliente que mais gastou em cada mês, incluindo o nome do cliente e o valor gasto.


--13. Questão: Crie uma VIEW materializada que apresente o valor médio gasto por cada cliente em suas compras, considerando apenas os produtos acima de um determinado preço.

--14. Questão: Compare o tempo de execução das consultas entre uma VIEW que realiza junções em tempo real e uma VIEW materializada equivalente.

--15. Questão: Compare o tempo de atualização de uma VIEW materializada com o tempo de execução da mesma consulta usando uma VIEW padrão.



--Pesquisar a diferença dessas expressões

SELECT order_date *FROM orders ORDER BY order_date ASC;
		
SELECT to_char (o.order_date, 'yyyy-mm') AS mes, SUM (p.price*oi.quantity) AS total_vendas
*FROM products AS p JOIN
	orders AS o ON o.customer_id = p.id JOIN
	order_items AS oi ON oi.order_id = o.id 
		GROUP BY mes
		ORDER BY mes;
		
SELECT distinct o.order_date AS month, SUM (p.price * oi.quantity) AS total_sales		--Obs: to_char in doc pág 167
*FROM products AS p JOIN
	order_items AS oi ON p.id = oi.product_id JOIN 
	orders AS o ON oi.order_id = o.id
		GROUP BY month
		ORDER BY month;
		
SELECT DATE_TRUNC('month', o.order_date) AS month,
SUM (p.price * oi.quantity) AS total_sales
*FROM orders o JOIN 
	order_items oi ON o.id = oi.order_id JOIN 
	products p ON oi.product_id = p.id
		GROUP BY month
		ORDER BY month;
