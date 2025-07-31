/*Create table about STORES*/
CREATE TABLE store_list(
    store_id NUMERIC PRIMARY KEY,
    store_name VARCHAR(50)
);

/*Import data presented information about STORES*/
INSERT INTO store_list (store_id, store_name)
VALUES 
    (1, 'TH Mart 1'),
    (2, 'TH Mart 2'),
    (3, 'TH Mart 3')
    (4, 'TH Mart 4')
    (5, 'TH Mart 5');

/*Check result*/
SELECT* FROM store_list;

/*Create table about STORES'S RETURNS*/
CREATE TABLE returns_list(
    store_id NUMERIC,
    return_id VARCHAR (50) PRIMARY KEY,
    return_date TIMESTAMP,
    return_value NUMERIC(10,2),
    FOREIGN KEY (store_id) REFERENCES store_list(store_id)
);

/*Import data presented information about STORES'S RETURNS*/
COPY returns_list(store_id, return_id, return_date,return_value)
FROM 'C:/thmart/return_list.csv'
DELIMITER ',' CSV HEADER;

/*Check result*/
SELECT * FROM returns_list;

/*Create table about STORES'S INVOICES*/
CREATE TABLE invoices_list(
    store_id NUMERIC,
    invoice_id VARCHAR(50) PRIMARY KEY,
    invoice_date TIMESTAMP,
    return_id VARCHAR (50),
    invoice_value NUMERIC(10,2),
    invoice_discount NUMERIC(10,2)
);

/*Import data presented information about  STORES'S INVOICES*/
COPY invoices_list(store_id,invoice_id,invoice_date,return_id,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_1.csv'
DELIMITER ',' CSV HEADER;

COPY invoices_list(store_id,invoice_id,invoice_date,return_id,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_2.csv'
DELIMITER ',' CSV HEADER;

COPY invoices_list(store_id,invoice_id,invoice_date,return_id,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_3.csv'
DELIMITER ',' CSV HEADER;

COPY invoices_list(store_id,invoice_id,invoice_date,return_id,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_4.csv'
DELIMITER ',' CSV HEADER;

COPY invoices_list(store_id,invoice_id,invoice_date,return_id,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_5.csv'
DELIMITER ',' CSV HEADER;

/*Update data (from 2017 to 2019) presented information about  STORE 1'S INVOICES*/
COPY invoices_list(store_id,invoice_id,invoice_date,return_id,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_add.csv'
DELIMITER ',' CSV HEADER;

/*Check result*/
SELECT * FROM invoices_list
ORDER BY invoice_date;

SELECT
    s.store_name, 
    EXTRACT(YEAR FROM i.invoice_date) AS invoice_year,
    EXTRACT(MONTH FROM i.invoice_date) AS invoice_month,
    ROUND(AVG(EXTRACT(EPOCH FROM MAX(i.invoice_date) - MIN(i.invoice_date))/3600),2) AS avg_hours_per_day,
    COUNT(*)/EXTRACT(EPOCH FROM MAX(i.invoice_date) - MIN(i.invoice_date)/3600) AS invoice_per_hour,


/*Create table with all insight relate with sale*/
CREATE TABLE report AS
    SELECT 
