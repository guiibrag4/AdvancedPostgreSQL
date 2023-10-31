-- Tabela de Produtos
CREATE TABLE products (
id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL,
price DECIMAL(10, 2) NOT NULL
);
-- Tabela de Clientes
CREATE TABLE customers (
id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL,
email VARCHAR(255) NOT NULL
);
-- Tabela de Pedidos
CREATE TABLE orders (
id SERIAL PRIMARY KEY,
customer_id INT REFERENCES customers(id),
order_date DATE NOT NULL
);
-- Tabela de Itens do Pedido
CREATE TABLE order_items (
id SERIAL PRIMARY KEY,
order_id INT REFERENCES orders(id),
product_id INT REFERENCES products(id),
quantity INT NOT NULL
);

CREATE OR REPLACE FUNCTION insert_records_by_quantity(record_count INT)
RETURNS VOID AS $$
DECLARE
    i INT;
    last_product_id INT;
    last_customer_id INT;
    last_order_id INT;
BEGIN
    -- Obter o último ID de produto
    SELECT COALESCE(MAX(id), 0) INTO last_product_id FROM products;
    
    -- Inserir registros nas tabelas products
    i := 1;
    WHILE i <= record_count LOOP
        INSERT INTO products (name, price) VALUES ('Product ' || (last_product_id + i), RANDOM() * 1000) RETURNING id INTO last_product_id;
        i := i + 1;
    END LOOP;

    -- Obter o último ID de cliente
    SELECT COALESCE(MAX(id), 0) INTO last_customer_id FROM customers;
    -- Obter o último ID de pedido
    SELECT COALESCE(MAX(id), 0) INTO last_order_id FROM orders;
    
    i := 1;
    WHILE i <= record_count LOOP
        -- Inserir registros nas tabelas customers
        INSERT INTO customers (name, email) VALUES ('Customer ' || (last_customer_id + i), 'customer' || (last_customer_id + i) || '@example.com') RETURNING id INTO last_customer_id;

        -- Inserir registros nas tabelas orders
        INSERT INTO orders (customer_id, order_date) VALUES (last_customer_id, current_date - (i || ' days')::INTERVAL) RETURNING id INTO last_order_id;
        
        -- Inserir quantidade aleatória de produtos em pedidos
        FOR j IN 1..(FLOOR(RANDOM() * 30) + 1) LOOP
            INSERT INTO order_items (order_id, product_id, quantity) VALUES (last_order_id, FLOOR(RANDOM() * last_product_id) + 1, FLOOR(RANDOM() * 10) + 1);
        END LOOP;

        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Para executar a função e inserir os registros (por exemplo, inserir 100000)
SELECT insert_records_by_quantity(100000);