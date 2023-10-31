/* Sintaxe 	Trigger e Função*/

CREATE TRIGGER {nome da trigger}
AFTER INSERT ON {nome da tabela} 
FOR EACH ROW -- ou STATEMENT	 
EXECUTE FUNCTION {nome da função};

CREATE OR REPLACE FUNCTION {nome da função}
RETURN TRIGGER AS $$
BEGIN
	{TIPO DE AÇÃO QUE DESEJA FAZER NA FUNÇÃO}
RETURN NEW -- OU RETURN NULL
END;
$$ LANGUAGE plpgsql;

/* Questão 1. A) Crie um trigger que, toda vez que um item do pedido for inserido ou 
atualizado na tabela "orders_items" a coluna "order_total" da tabela "orders" seja 
atualizada automaticamente com o preço total do pedido. */

CREATE OR REPLACE FUNCTION calculate_order_total ()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE orders 
	SET order_total = (
		SELECT SUM (p.price*oi.quantity)
		FROM order_items oi JOIN
			products p ON oi.product_id = p.id
		WHERE oi.order_id = NEW.order_id
	)
	WHERE id = NEW.order_id;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_order_total
AFTER INSERT OR UPDATE ON order_items
FOR EACH ROW
EXECUTE FUNCTION calculate_order_total();

-----------------------------------------------------

/* Questão 1. B) Crie um trigger que, quando um novo pedido for inserido na tabela 
"orders", atualize o campo "order_date" automaticamente com a data atual.*/

CREATE OR REPLACE FUNCTION att_date ()
RETURNS TRIGGER AS $$
BEGIN 
	UPDATE orders as o
	SET order_date = NOW ()
	WHERE o.id = NEW.id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_orders_date 
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION att_date();

ALTER TABLE orders
	ALTER column order_date DROP NOT NULL;

insert into orders (customer_id) VALUES (1);

-- Caso o create trigger fosse BEFORE seria mais fácil, dessa forma não precisaria
-- fazer um UPDATE e colocar apenas da seguinte forma: 

/*CREATE OR REPLACE FUNCTION att_date ()
RETURNS TRIGGER AS $$
BEGIN 
	NEW.order_date := now();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_orders_date
BEFORE INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION att_date(); */

/* Obs: Dessa forma funciona mesmo com a coluna order_date sendo not null, pois antes de inserir a linha
uma data está sendo definida, por isso é ainda mais efeito para a integridade do banco de dados */

-----------------------------------------------------

/* Questão 2: Crie um trigger que, quando um item de pedido for excluído da tabela
"order_items", atualize o campo "quantity" do produto correspondente na tabela
"products" para refletir o estoque atual. */

CREATE OR REPLACE FUNCTION att_quantity ()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE products
	SET quantity = quantity + OLD.quantity
	WHERE id = OLD.product_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_quantity_products
AFTER DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION att_quantity();

ALTER TABLE products
	ADD COLUMN quantity int;

DELETE FROM order_items	
	WHERE ID = 10;

-----------------------------------------------------

/* Questão 3: Crie um trigger que, quando um pedido for atualizado na tabela "orders",
verifique se o novo valor da coluna "customer_id" é válido (ou seja, se corresponde a
um cliente existente na tabela "customers").*/

CREATE OR REPLACE FUNCTION verification_customerid ()
RETURNS TRIGGER AS $$ 
BEGIN 
	IF EXISTS (SELECT *FROM customers where id = NEW.customer_id) THEN 
	RETURN NEW;	
	ELSE 
		RAISE EXCEPTION 'O novo valor de customer_id não corresponde a um cliente existente na tabela customers';
	END IF
END;
$$ LANGUAGE plpgsql

CREATE OR REPLACE TRIGGER verication 
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION verification_customerid ();


-----------------------------------------------------

/* Questão 4: Crie um trigger que, quando um produto for atualizado na tabela "products"
e o preço for alterado, atualize automaticamente o preço de todos os itens de pedido
associados a esse produto na tabela "order_items" para refletir o novo preço.*/



