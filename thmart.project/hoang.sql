
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
    daily_sale_report AS (
        SELECT
            sl.store_name,
            DATE(il.invoice_date) AS sale_date,
            EXTRACT(EPOCH FROM(MAX(il.invoice_date) - MIN(il.invoice_date)))/3600 AS operating_time_day,
            COUNT(*) AS num_sale_day,
            SUM(il.invoice_value) AS total_income_day,
            COALESCE(SUM(il.invoice_discount),0) AS total_discount_day
        FROM invoices_list il 
        LEFT JOIN store_list sl ON sl.store_id = il.store_id
        GROUP BY DATE(il.invoice_date), sl.store_name
        HAVING EXTRACT(EPOCH FROM(MAX(il.invoice_date) - MIN(il.invoice_date)))/3600 > 0
    ),

    daily_return_report AS (
        SELECT  
            sl.store_name,
            DATE(rl.return_date) AS return_day,
            SUM(rl.return_value) AS total_return_value_day
        FROM returns_list rl
        LEFT JOIN store_list sl ON sl.store_id = rl.store_id
        GROUP BY DATE(rl.return_date), sl.store_name
    ),

    daily_damage_report AS (
        SELECT
            sl.store_name,
            DATE(dl.damage_date) AS damage_day,
            SUM(dl.damage_value) AS total_damage_value_day
        FROM damage_list dl
        LEFT JOIN store_list sl ON sl.store_id = dl.store_id
        GROUP BY DATE(dl.damage_date), sl.store_name
    ),

    daily_check_report AS (
        SELECT
            sl.store_name,
            DATE(stl.stock_take_date) AS check_date,
            SUM(stl.stock_take_value) AS total_check_value_day
        FROM stock_take_list stl
        LEFT JOIN store_list sl ON sl.store_id = stl.store_id
        GROUP BY DATE(stl.stock_take_date), sl.store_name
    ),

    monthly_inventory_report AS (
        SELECT
            sl.store_name,
            DATE(ir.report_date) AS inventory_verify_date,
            ir.inventory_value AS begin_inventory_value
        FROM inventory_report ir
        LEFT JOIN store_list sl ON sl.store_id = ir.store_id
    )   

SELECT
    dsr.store_name,
    EXTRACT(YEAR FROM dsr.sale_date) AS the_year,
    EXTRACT(MONTH FROM dsr.sale_date) AS the_month,
    SUM(dsr.total_income_day)
        - SUM(COALESCE(dsr.total_discount_day,0))
        - SUM(COALESCE(drr.total_return_value_day,0)) AS net_income,
    ROUND(AVG(dsr.operating_time_day),2) AS avg_operating_time,
    FLOOR(COALESCE(SUM(dsr.num_sale_day)/SUM(dsr.operating_time_day),0)) AS sale_per_hour,
    ROUND(COALESCE(
        (SUM(dsr.total_income_day)
        - SUM(COALESCE(dsr.total_discount_day,0))
        - SUM(COALESCE(drr.total_return_value_day,0)))/NULLIF(SUM(dsr.num_sale_day),0)
    ,0),2) AS avg_value_per_sale,
    ROUND(COALESCE(
        SUM(COALESCE(dsr.total_discount_day,0))/NULLIF(
            SUM(dsr.total_income_day)
            - SUM(COALESCE(dsr.total_discount_day,0))
            - SUM(COALESCE(drr.total_return_value_day,0)),0)
    ,0),2) AS discount_rate,
    SUM(COALESCE(drr.total_return_value_day,0)) AS return_value_month,
    SUM(COALESCE(ddr.total_damage_value_day,0)) AS damage_value_month,
    SUM(COALESCE(dcr.total_check_value_day,0)) AS diff_value_month,
    SUM(COALESCE(mir.begin_inventory_value,0)) AS inventory_value_ready
FROM daily_sale_report dsr
LEFT JOIN daily_return_report drr ON drr.store_name = dsr.store_name AND drr.return_day = dsr.sale_date
LEFT JOIN daily_damage_report ddr ON ddr.store_name = ddr.store_name AND ddr.damage_day = dsr.sale_date
LEFT JOIN daily_check_report dcr ON dcr.store_name = dsr.store_name AND dcr.check_date = dsr.sale_date
LEFT JOIN monthly_inventory_report mir ON mir.store_name = dsr.store_name AND mir.inventory_verify_date = dsr.sale_date
GROUP BY dsr.store_name, the_year, the_month
ORDER BY dsr.store_name, the_year, the_month;
