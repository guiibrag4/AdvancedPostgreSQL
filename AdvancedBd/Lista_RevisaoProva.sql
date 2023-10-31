--Views

--Crie uma view que mostre o nome do cliente e o total de pedidos que ele fez.
CREATE VIEW vw_total_orders_customer AS
    SELECT c.name, count (o.id) as total_orders
    FROM customers c JOIN
    orders o ON o.customer_id = c.id
        GROUP BY c.name;

--Crie uma view mostra todos os produtos que nunca foram pedidos.
CREATE VIEW vw_produtos_nunca_vendidos AS
    SELECT p.name
    FROM products p LEFT JOIN 
    order_items oi ON p.id = oi.product_id
    WHERE oi.product_id IS NULL;

--Crie uma view que mostre a quantidade total de cada produto vendido.
CREATE VIEW vw_qntd_total_produtos_vendidos AS
    SELECT  p.name,  
            SUM(oi.quantity) AS quantidade_total_vendida
    FROM products p JOIN
    order_items oi ON oi.product_id = p.id
        GROUP BY p.name
        ORDER BY quantidade_total_vendida ASC;

--Crie view retorna os clientes que não fizeram nenhum pedido.
CREATE VIEW vw_clientes_sem_pedidos AS
    SELECT  c.name
    FROM customers c LEFT JOIN
    orders o ON o.customer_id = c.id
    WHERE o.id is null;

--Rules

/*Crie uma regra que, ao tentar atualizar o preço de um produto para um valor negativo, automaticamente o 
atualize para preço 0.*/
CREATE RULE rl_products_update AS ON
    UPDATE TO products WHERE price < 0 DO INSTEAD
        UPDATE products SET price = 0
        WHERE id = NEW.id;

--Crie uma regra que impeça a exclusão de clientes que tenham pedidos.
CREATE RULE rl_customers_delete AS ON
DELETE TO customers WHERE EXISTS (
    SELECT 1 FROM orders WHERE custumer_id = OLD.id
) DO INSTEAD NOTHING;

/*Crie uma regra que, ao tentar inserir um cliente com o mesmo e-mail que um cliente existente, a inserção 
seja evitada.*/
CREATE RULE rl_customers_insert AS ON
INSERT TO customers WHERE EXISTS (
    SELECT 1 FROM customers WHERE email = NEW.email
) DO INSTEAD NOTHING;

--Crie uma regra que impeça a alteração do nome de um produto para um nome vazio.
CREATE RULE rl_products_update AS ON
UPDATE TO products WHERE NEW.name = '' DO INSTEAD NOTHING;