CREATE TABLE store_list(
    store_id NUMERIC PRIMARY KEY,
    store_name VARCHAR(50)
);

INSERT INTO store_list (store_id, store_name)
VALUES 
    (1, 'TH Mart 1'),
    (2, 'TH Mart 2'),
    (3, 'TH Mart 3')
    (4, 'TH Mart 4')
    (5, 'TH Mart 5');

CREATE TABLE returns_list(
    store_id NUMERIC,
    return_id VARCHAR (50) PRIMARY KEY,
    return_date TIMESTAMP,
    return_value NUMERIC(10,2),
    FOREIGN KEY (store_id) REFERENCES store_list(store_id)
);

COPY returns_list(store_id, return_id, return_date,return_value)
FROM 'C:/thmart/return_list.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM returns_list;

CREATE TABLE invoices_list(
    store_id NUMERIC,
    invoice_id VARCHAR(50) PRIMARY KEY,
    invoice_date TIMESTAMP,
    return_id VARCHAR (50),
    invoice_value NUMERIC(10,2),
    invoice_discount NUMERIC(10,2)
);

COPY returns_list(store_id, return_id, return_date,return_value)
FROM 'C:/thmart/return_list.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM invoices_list;
