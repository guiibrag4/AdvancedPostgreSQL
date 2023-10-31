--Criação de um índice
CREATE index idx_transaction_user_id ON transactions (user_id);

explain select *from transactions where user_id = 'CódigoId' and 'CódigoId';

--Particionamento de tabelas
