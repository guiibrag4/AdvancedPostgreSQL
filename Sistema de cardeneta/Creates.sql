CREATE SCHEMA fiado_pago;

SET seach_path to fiado_pago;

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    login VARCHAR (50) NOT NULL,
    senha VARCHAR (25) NOT NULL,
    nome VARCHAR (60) NOT NULL,
    email VARCHAR (150) NOT NULL,
    telefone VARCHAR (25) NOT NULL
);

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR (60) NOT NULL,
    cpf VARCHAR (12) NOT NULL,
    telefone VARCHAR (25) NOT NULL,
    endereco_cobranca VARCHAR (100) NOT NULL
);

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,    
    data_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL (10,2) 
);

CREATE TABLE pedidos_produtos (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL,
    produto_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL
);

CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR (50) NOT NULL,
    preco DECIMAL (10,2)
);

--Inserção das foreign keys

ALTER TABLE pedidos
    add constraint fk_pedido_cliente
        FOREIGN KEY (cliente_id) REFERENCES clientes (id);

ALTER TABLE pedidos_produtos
    add constraint fk_pedidoproduto_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedidos (id);

ALTER TABLE pedidos_produtos
    add constraint fk_pedidoproduto_produto
        FOREIGN KEY (produto_id) REFERENCES produtos (id);
