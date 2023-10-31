/*Questão 1: Crie uma RULE que impede a inserção de produtos com um preço superior a 1000. Ao invés de inserir, essa regra deve
redirecionar a inserção para uma tabela chamada rejected_products.*/

CREATE OR REPLACE RULE rl_products_insert AS ON
	INSERT TO products WHERE price > 1000 DO INSTEAD
		INSERT INTO rejected_products (product_id, name, usuario, acao, price, date)
			VALUES (NEW.id, NEW.name, CURRENT_USER, 'INSERT', NEW.price, CURRENT_DATE);

-- FAZER COM QUE A REGRA DO INSTEAD SEJA REALIZADA SE O PREÇO FOR IGUAL OU MAIOR A 1000, CASO NÃO SERÁ REALIZADO O QUE TEM ANTES DA REGRA

CREATE TABLE rejected_products (
	id SERIAL PRIMARY KEY,
	product_id integer,
	price numeric (10,2),
	name varchar (50),
	usuario varchar (50), --CURRENT_USER;
	acao varchar (30),
	date TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Perguntar ao professor sobre isso aq
);


select *from products;

/*Questão 2: Crie uma RULE que, ao tentar deletar um cliente, redireciona a operação para 
atualizar o email do cliente, tornando-o "deleted@deleted.com", em vez de realmente 
deletar o cliente.*/

CREATE OR REPLACE RULE rl_customers_delete AS ON
	DELETE TO customers DO INSTEAD
		UPDATE customers AS c SET email = 'deleted@deleted.com'
			WHERE OLD.id = c.id;

/*Questão 3: Ao tentar inserir um pedido (order) para um cliente inexistente, redirecione a inserção para 
uma tabela rejected_orders que armazena os pedidos rejeitados e a razão da rejeição.*/

CREATE TABLE rejected_orders (
	id SERIAL PRIMARY KEY,
	order_id integer,
	usuario varchar(50),
	acao varchar,
	razao varchar,
	date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE RULE rl_orders_insert AS ON
	INSERT INTO orders WHERE 


/*Questão 4: Crie uma RULE que impede atualizações na coluna name da tabela products.*/
CREATE OR REPLACE RULE rl_products_update AS ON
	UPDATE TO products as p  
		WHERE NEW.name is DISTINC FROM OLD.name DO INSTEAD NOTHING;


/* 5- Ao tentar inserir um item do pedido (order_item) com uma quantidade negativa, 
redirecione a inserção para uma tabela rejected_order_items que armazena informações 
sobre itens de pedidos rejeitados. */

CREATE TABLE rejected_order_items (
	id SERIAL PRIMARY KEY,
	order_items_id integer,
	usuario varchar (50),
	acao varchar (30),
	razao varchar (30),
	date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE RULE rl_orderitems_insert AS ON
	INSERT TO order_items WHERE NEW.quantity < 0 DO INSTEAD
		INSERT INTO rejected_order_items (order_items_id, usuario, acao, razao, date) 
			VALUES (NEW.id, CURRENT_USER, 'Rejected Insert', 'Quantidade de itens negativa', CURRENT_TIMESTAMP); 







