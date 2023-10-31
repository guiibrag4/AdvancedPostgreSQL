CREATE OR REPLACE FUNCTION calcular_total_pedido (pedido_id INT)
RETURNS DECIMAL(10,2) AS $$
DECLARE 
	total DECIMAL (10,2);
BEGIN
	SELECT SUM (p.price * oi.quantity) INTO total
		FROM order_items AS oi JOIN
		products AS p ON oi.product_id = p.id
	WHERE oi.order_id = pedido_id;
	RETURN total;
END;
$$ LANGUAGE plpgsql;

SELECT calcular_total_pedido();

---------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION obter_nome_completo (cliente_id INT)
RETURNS VARCHAR (255) AS $$
DECLARE
	nome_completo VARCHAR (255);
BEGIN 
	SELECT name INTO nome_completo
	FROM CUSTOMERS 
	WHERE id = cliente_id;
	
	IF (nome_completo is not null) THEN
	RETURN nome_completo;
	ELSE 
		return 'O usuário não existe';
	END IF;
	
END;
$$ LANGUAGE plpgsql;

SELECT obter_nome_completo (100001);

CREATE TABLE customers (
    nome VARCHAR (55) NOT NULL DEFAULT 'Guilherme',
    idade INT NOT NULL DEFAULT 18
);

    