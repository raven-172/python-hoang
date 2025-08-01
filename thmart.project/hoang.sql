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

WITH 
daily_report AS (
    SELECT 
        s.store_name,
        DATE(i.invoice_date) AS sale_day,
        COALESCE(EXTRACT(EPOCH FROM MAX(i.invoice_date) - MIN(i.invoice_date))/3600, 0) AS total_hours_day,
        COUNT(*) AS amount_invoice,
        COALESCE(COUNT(*)/NULLIF(EXTRACT(EPOCH FROM MAX(i.invoice_date)-MIN(i.invoice_date))/3600,0),0) AS invoice_per_hour,
        SUM(i.invoice_value) - COALESCE(SUM(r.return_value),0) AS net_income,
        SUM(i.invoice_value) - COALESCE(SUM(r.return_value),0)/COUNT(*) AS average_invoice_value,
        COALESCE(SUM(i.invoice_discount),0) AS discount_per_day,
        SUM(i.invoice_value) AS income_per_day
    FROM invoices_list i
    LEFT JOIN  store_list s ON s.store_id = i.store_id
    LEFT JOIN returns_list r ON r.return_id = i.return_id
    GROUP BY s.store_name, sale_day
)

    SELECT
        store_name,
        EXTRACT(YEAR FROM sale_day) AS invoice_year,
        EXTRACT(MONTH FROM sale_day) AS invoice_month,
        ROUND(AVG(total_hours_day),2) AS operating_time,
        ROUND(AVG(invoice_per_hour),2) AS avg_inv_per_hour,
        SUM(net_income) AS total_net_income,
        SUM(net_income)/SUM(amount_invoice) AS avg_invoice_value,
        ROUND(SUM(discount_per_day)/SUM(income_per_day),2) AS discount_income_rate
    FROM daily_report
    GROUP BY invoice_year, invoice_month, daily_report.store_name;