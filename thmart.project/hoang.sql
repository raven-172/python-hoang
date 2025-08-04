
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

/*Create table about STORES'S INVOICES*/
CREATE TABLE invoices_list(
    store_id NUMERIC,
    invoice_id VARCHAR(50) PRIMARY KEY,
    invoice_date TIMESTAMP,
    invoice_value NUMERIC(10,2),
    invoice_discount NUMERIC(10,2),
    FOREIGN KEY (store_id) REFERENCES store_list(store_id)
);

/*Import data presented information about  STORES'S INVOICES*/
COPY invoices_list(store_id,invoice_id,invoice_date,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_1.csv'
DELIMITER ',' CSV HEADER;

COPY invoices_list(store_id,invoice_id,invoice_date,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_2.csv'
DELIMITER ',' CSV HEADER;

COPY invoices_list(store_id,invoice_id,invoice_date,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_3.csv'
DELIMITER ',' CSV HEADER;

COPY invoices_list(store_id,invoice_id,invoice_date,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_4.csv'
DELIMITER ',' CSV HEADER;

COPY invoices_list(store_id,invoice_id,invoice_date,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_5.csv'
DELIMITER ',' CSV HEADER;

/*Update data (from 2017 to 2019) presented information about  STORE 1'S INVOICES*/
COPY invoices_list(store_id,invoice_id,invoice_date,invoice_value,invoice_discount)
FROM 'C:/thmart/sale_list/sale_list_add.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM invoices_list
WHERE store_id = 5
ORDER BY invoice_date DESC;

/*Create table about STORES'S RETURNS*/
CREATE TABLE returns_list(
    store_id NUMERIC,
    return_id VARCHAR(50) PRIMARY KEY,
    invoice_id VARCHAR(50),
    return_date TIMESTAMP,
    return_value NUMERIC(10,2),
    FOREIGN KEY (store_id) REFERENCES store_list(store_id),
    FOREIGN KEY (invoice_id) REFERENCES invoices_list(invoice_id)
);

/*Import data presented information about STORES'S RETURNS*/
COPY returns_list(store_id, return_id, invoice_id, return_date, return_value)
FROM 'C:/thmart/returns_list.csv'
DELIMITER ',' CSV HEADER;

/*Check result*/
SELECT * FROM returns_list;

/*Create table about STORES'S DAMAGED ITEMS*/
CREATE TABLE damage_list (
    store_id NUMERIC,
    damage_id VARCHAR(50) PRIMARY KEY,
    damage_date TIMESTAMP,
    damage_value NUMERIC(10,2),
    FOREIGN KEY (store_id) REFERENCES store_list(store_id)
);

/*Import data presented information about STORES'S DAMAGED ITEMS*/
COPY damage_list(store_id, damage_id, damage_date, damage_value)
FROM 'C:/thmart/damage_list.csv'
DELIMITER ',' CSV HEADER;

/*Check result*/
SELECT * FROM damage_list;

/*Create table about STORES'S INVENTORY CHECK*/
CREATE TABLE stock_take_list (
    store_id NUMERIC,
    stock_take_id VARCHAR(50) PRIMARY KEY,
    stock_take_date TIMESTAMP,
    process_date TIMESTAMP,
    stock_take_value NUMERIC(100,2)
);

/*Import data presented information about STORES'S INVENTORY CHECK*/
COPY stock_take_list(store_id, stock_take_id, stock_take_date, process_date, stock_take_value)
FROM 'C:/thmart/stock_take.csv'
DELIMITER ',' CSV HEADER;

/*Check result*/
SELECT * FROM stock_take_list;

/*Create table about STORES'S INVENTORY VALUE*/
CREATE TABLE inventory_report (
    store_id NUMERIC,
    report_date DATE,
    inventory_value NUMERIC(15,2)
);

/*Import data presented information about STORES'S INVENTORY VALUE*/
COPY inventory_report(store_id, report_date, inventory_value)
FROM 'C:/thmart/inventory/inventory_1.csv'
DELIMITER ',' CSV HEADER;

COPY inventory_report(store_id, report_date, inventory_value)
FROM 'C:/thmart/inventory/inventory_2.csv'
DELIMITER ',' CSV HEADER;

COPY inventory_report(store_id, report_date, inventory_value)
FROM 'C:/thmart/inventory/inventory_3.csv'
DELIMITER ',' CSV HEADER;

COPY inventory_report(store_id, report_date, inventory_value)
FROM 'C:/thmart/inventory/inventory_4.csv'
DELIMITER ',' CSV HEADER;

COPY inventory_report(store_id, report_date, inventory_value)
FROM 'C:/thmart/inventory/inventory_5.csv'
DELIMITER ',' CSV HEADER;

/*Check result*/
SELECT * FROM inventory_report;

/*Query information that show needed insights*/
WITH
    sum_report AS (
        SELECT
            s.store_name,
            i.invoice_id,
            i.invoice_date,
            i.invoice_value,
            i.invoice_discount,
            r.return_value
        FROM invoices_list i
        LEFT JOIN store_list s ON s.store_id = i.store_id
        LEFT JOIN returns_list r ON r.return_id = i.return_id
    ),

    daily_report AS (
        SELECT
            store_name,
            DATE(invoice_date) AS sale_date,
            EXTRACT(EPOCH FROM(MAX(invoice_date) - MIN(invoice_date)))/3600 AS operating_time_day,
            COUNT(*) AS num_invoice_day,
            SUM(invoice_value) AS total_income_day,
            SUM(invoice_discount) AS total_discount_day,
            SUM(return_value) AS total_return_day
        FROM sum_report
        GROUP BY sale_date, store_name
        HAVING EXTRACT(EPOCH FROM(MAX(invoice_date) - MIN(invoice_date)))/3600 > 0
    )

SELECT
    store_name,
    EXTRACT(YEAR FROM sale_date) AS sale_year,
    EXTRACT(MONTH FROM sale_date) AS sale_month,
    SUM(total_income_day - COALESCE(total_discount_day,0) - COALESCE(total_return_day,0)) AS net_revenue,
    ROUND(AVG(operating_time_day),2) AS operating_time,
    FLOOR(COALESCE(SUM(num_invoice_day)/NULLIF(SUM(operating_time_day),0),0)) AS sale_per_hour,
    ROUND(SUM(total_income_day - COALESCE(total_discount_day,0) - COALESCE(total_return_day,0))/SUM(num_invoice_day),2) AS avg_value_sale,
    ROUND(SUM(COALESCE(total_discount_day,0))/SUM(total_income_day),2) AS discount_rate,
    SUM(COALESCE(total_return_day,0)) AS return_value_month
FROM daily_report
GROUP BY store_name, sale_year, sale_month;

