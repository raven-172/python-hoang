CREATE TABLE store_list(
    store_id NUMERIC PRIMARY KEY,
    store_name VARCHAR(50)
);

INSERT INTO store_list (store_id, store_name)
VALUES 
    (1, 'TH Mart 1'),
    (2, 'TH Mart 2'),
    (3, 'TH Mart 3');

CREATE TABLE sales(
    sale_id VARCHAR(50) PRIMARY KEY,
    sale_date TIMESTAMP,
    store_id NUMERIC,
    FOREIGN KEY (store_id) REFERENCES store_list(store_id)
);

