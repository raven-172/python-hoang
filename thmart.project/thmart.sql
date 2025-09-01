/*1. Creat Store List*/
/*a. Create table*/

CREATE TABLE Store_List(
    Store_id VARCHAR(50) PRIMARY KEY,
    Store_name VARCHAR(100),
    Store_address VARCHAR(100),
    Store_ward VARCHAR(100),
    Store_district VARCHAR(100),
    Store_city VARCHAR(100)
);

/*b. Import data*/

INSERT INTO Store_List (Store_id, Store_name, Store_address, Store_ward, Store_district, Store_city)
VALUES 
    ('TH1', 'TH Mart 1', '867 GIAI PHONG', 'GIAP BAT', 'HOANG MAI', 'HA NOI'),
    ('TH2', 'TH Mart 2', '149 KHUAT DUY TIEN', 'NHAN CHINH', 'THANH XUAN', 'HA NOI'),
    ('TH3', 'TH Mart 3', '230 NGUYEN LAN', 'PHUONG LIET', 'THANH XUAN', 'HA NOI'),
    ('TH4', 'TH Mart 4', '35/99 DINH CONG HA', 'DINH CONG', 'HOANG MAI', 'HA NOI'),
    ('TH5', 'TH Mart 5', 'DOI 3 LAC THI', 'NGOC HOI', 'THANH TRI', 'HA NOI'),
    ('KHO62', 'KHO PHAN PHOI 62', '62 PHAN DINH GIOT', 'PHUONG LIET', 'THANH XUAN', 'HA NOI');    

/*c. Check*/

SELECT * FROM Store_List;

/*2. Create Customer List*/
/*a. Create table*/

CREATE TABLE Customer_List(
    Store_id VARCHAR(50),
    Customer_number VARCHAR(50) PRIMARY KEY,
    Customer_name TYPE VARCHAR(1000),
    Customer_phone TYPE VARCHAR(1000),
    Customer_address TYPE VARCHAR(1000),
    Customer_area TYPE VARCHAR(1000),
    Customer_ward TYPE VARCHAR(1000),
    Customer_sex TYPE VARCHAR(1000),
    Customer_status TYPE VARCHAR(1000),
    FOREIGN KEY (Store_id) REFERENCES Store_List(Store_id)
);

/*b. Import data*/

COPY Customer_List(
    Store_id, 
    Customer_number, 
    Customer_name, 
    Customer_phone, 
    Customer_address, 
    Customer_area, 
    Customer_ward, 
    Customer_sex, 
    Customer_status)
FROM 'C:/thmart_csv/customer_list.csv'
DELIMITER ',' CSV HEADER;

/*c. Check*/

SELECT * FROM Customer_List;

/*3. Create Invoice_List*/
/*a. Create table*/

CREATE TABLE Invoice_List(
    Invoice_number VARCHAR(50) PRIMARY KEY,
    Invoice_time TIMESTAMP, 
    Customer_number VARCHAR(100),
    Store_id VARCHAR(50),
    Invoice_sub_total NUMERIC(10,2),
    Invoice_discount NUMERIC(10,2),
    Invoice_sub_total_after_discount NUMERIC(10,2),
    Invoice_paid NUMERIC(10,2),
    FOREIGN KEY (Store_id) REFERENCES Store_List(Store_id),
    FOREIGN KEY (Customer_number) REFERENCES Customer_List(Customer_number)
);

/*b. Import data*/

COPY Invoice_List(
    Invoice_number,
    Invoice_time, 
    Customer_number,
    Store_id,
    Invoice_sub_total,
    Invoice_discount,
    Invoice_sub_total_after_discount, 
    Invoice_paid)
FROM 'C:/thmart_csv/invoice_list.csv'
DELIMITER ',' CSV HEADER;

/*c. Check*/

SELECT * FROM Invoice_List;

/*4. Create Inventory_Count*/
/*a. Create table*/

CREATE TABLE Inventory_Count(
    Store_id VARCHAR(50),
    IC_number VARCHAR(50),
    IC_time TIMESTAMP,
    IC_completed_time TIMESTAMP,
    IC_total_actual_count NUMERIC(15,2),
    IC_total_price_actual NUMERIC(15,2),
    IC_total_diff_qty NUMERIC(15,2),
    IC_total_net_diff_qty NUMERIC(15,2),
    IC_total_diff_cost NUMERIC(15,2),
    IC_surplus_quantity NUMERIC(15,2),
    IC_surplus_qty NUMERIC(15,2),
    IC_missing_quantity NUMERIC(15,2),
    IC_missing_qty NUMERIC(15,2),
    IC_status VARCHAR(50),
    FOREIGN KEY (Store_id) REFERENCES Store_List(Store_id)
);

/*b. Import data*/

COPY Inventory_Count(
    Store_id,
    IC_number,
    IC_time,
    IC_completed_time,
    IC_total_actual_count,
    IC_total_price_actual,
    IC_total_diff_qty,
    IC_total_net_diff_qty,
    IC_total_diff_cost,
    IC_surplus_quantity,
    IC_surplus_qty,
    IC_missing_quantity,
    IC_missing_qty,
    IC_status)
FROM 'C:/thmart_csv/inventory_count.csv'
DELIMITER ',' CSV HEADER;

/*c. Check*/

SELECT * FROM Inventory_Count;

/*5. Create Inventory_Damaged*/
/*a. Create table*/

CREATE TABLE Inventory_Damaged(
    Damage_number VARCHAR(50),
    Total_damage_quantity NUMERIC(10,2),
    Total_damage_product NUMERIC(10,2),
    Total_damage_value NUMERIC(10,2),
    Damage_time TIMESTAMP,
    Damage_created_time TIMESTAMP,
    Store_id VARCHAR(50),
    Damage_status VARCHAR(50),
    FOREIGN KEY (Store_id) REFERENCES Store_List(Store_id)
);

/*b. Import data*/

COPY Inventory_Damaged(
    Damage_number,
    Total_damage_quantity,
    Total_damage_product,
    Total_damage_value,
    Damage_time,
    Damage_created_time,
    Store_id,
    Damage_status)
FROM 'C:/thmart_csv/inventory_damage.csv'
DELIMITER ',' CSV HEADER;

/*c. Check*/

SELECT * FROM Inventory_Damaged;


/*6. Create Purchase_Order*/
/*a. Create table*/

CREATE TABLE Purchase_Order(
    PO_number VARCHAR(50) PRIMARY KEY,
    PO_time TIMESTAMP,
    Store_id VARCHAR(50),
    Planned_receipt_date DATE,
    Day_left NUMERIC(10,2),
    Total_quantity NUMERIC(10,2),
    Total_product NUMERIC(10,2),
    PO_status VARCHAR(50),
    FOREIGN KEY (Store_id) REFERENCES Store_List(Store_id)
);

ALTER TABLE Purchase_Order
DROP COLUMN Purchase_receipt_number;

/*b. Import data*/

COPY Purchase_Order(
    PO_number,
    PO_time,
    Store_id,
    Planned_receipt_date,
    Day_left,
    Total_quantity,
    Total_product,
    PO_status)
FROM 'C:/thmart_csv/purchase_order.csv'
DELIMITER ',' CSV HEADER;

/*c. Check*/

SELECT * FROM Purchase_Order;

/*7. Create Purchase_receipt*/
/*a. Create table*/

CREATE TABLE Purchase_receipt(
    Purchase_receipt_number VARCHAR(50) PRIMARY KEY,
    PO_number VARCHAR(50),
    Purchase_time TIMESTAMP,
    Purchase_created_time TIMESTAMP,
    Purchase_modified_time TIMESTAMP,
    Store_id VARCHAR(50),
    Total_quantity NUMERIC(15,2),
    Total_product NUMERIC(15,2),
    Sub_total NUMERIC(15,2),
    Discount NUMERIC(15,2),
    Total NUMERIC(15,2),
    Payment_discount NUMERIC(15,2),
    Paid_for_Supplier NUMERIC(15,2),
    Other_charge NUMERIC(15,2),
    Purchase_status VARCHAR(50),
    FOREIGN KEY (Store_id) REFERENCES Store_List(Store_id),
    FOREIGN KEY (PO_number) REFERENCES Purchase_Order(PO_number)
);

/*b. Import data*/

COPY Purchase_receipt(
    Purchase_receipt_number,
    PO_number,
    Purchase_time,
    Purchase_created_time,
    Purchase_modified_time,
    Store_id,
    Total_quantity,
    Total_product,
    Sub_total,
    Discount,
    Total,
    Payment_discount,
    Paid_for_Supplier,
    Other_charge,
    Purchase_status)
FROM 'C:/thmart_csv/purchase_receipt.csv'
DELIMITER ',' CSV HEADER;

/*c. Check*/

SELECT * FROM Purchase_receipt;

/*8. Create Purchase_return*/
/*a. Create table*/

CREATE TABLE Purchase_return(
    Purchase_return_number VARCHAR(50) PRIMARY KEY,
    Purchase_receipt_number VARCHAR(50),
    Purchase_return_time TIMESTAMP,
    Purchase_return_created_time TIMESTAMP,
    Store_id VARCHAR(50),
    Total_quantity NUMERIC(10,2),
    Total_product NUMERIC(10,2),
    Sub_total NUMERIC(10,2),
    Discount NUMERIC(10,2),
    Total NUMERIC(10,2),
    Paid_by_Supplier NUMERIC(10,2),
    Purchase_return_status VARCHAR(50),
    FOREIGN KEY (Store_id) REFERENCES Store_List(Store_id),
    FOREIGN KEY (Purchase_receipt_number) REFERENCES Purchase_receipt(Purchase_receipt_number)
);

/*b. Import data*/

COPY Purchase_return(
    Purchase_return_number,
    Purchase_receipt_number,
    Purchase_return_time,
    Purchase_return_created_time,
    Store_id,
    Total_quantity,
    Total_product,
    Sub_total,
    Discount,
    Total,
    Paid_by_Supplier,
    Purchase_return_status)
FROM 'C:/thmart_csv/purchase_return.csv'
DELIMITER ',' CSV HEADER;

/*c. Check*/

SELECT * FROM Purchase_return;

/*9. Create Inventory_report*/
/*a. Create table*/

CREATE TABLE Inventory_report(
    Store_id VARCHAR(50),
    Report_date TIMESTAMP,
    Inventory_value NUMERIC(20,2)
);

/*b. Import data*/

COPY inventory_report(store_id, report_date, inventory_value)
FROM 'C:/thmart_csv/inventory_1.csv'
DELIMITER ',' CSV HEADER;

COPY inventory_report(store_id, report_date, inventory_value)
FROM 'C:/thmart_csv/inventory_2.csv'
DELIMITER ',' CSV HEADER;

COPY inventory_report(store_id, report_date, inventory_value)
FROM 'C:/thmart_csv/inventory_3.csv'
DELIMITER ',' CSV HEADER;

COPY inventory_report(store_id, report_date, inventory_value)
FROM 'C:/thmart_csv/inventory_4.csv'
DELIMITER ',' CSV HEADER;

COPY inventory_report(store_id, report_date, inventory_value)
FROM 'C:/thmart_csv/inventory_5.csv'
DELIMITER ',' CSV HEADER;

/*c. Check*/

SELECT * FROM inventory_report;

/*.10. Create Return_List*/
/*a. Create table*/

CREATE TABLE Return_List(
    Return_number VARCHAR(50) PRIMARY KEY,
    Invoice_number VARCHAR(50),
    Return_time TIMESTAMP, 
    Customer_number VARCHAR(100),
    Store_id VARCHAR(50),
    Return_sub_total NUMERIC(10,2),
    Return_discount NUMERIC(10,2),
    Return_sub_total_after_discount NUMERIC(10,2),
    Refunded_to_customer NUMERIC(10,2),
    FOREIGN KEY (Store_id) REFERENCES Store_List(Store_id),
    FOREIGN KEY (Invoice_number) REFERENCES Invoice_List(Invoice_number),
    FOREIGN KEY (Customer_number) REFERENCES Customer_List(Customer_number)
);

/*b. Import data*/

COPY Return_List(
    Return_number,
    Invoice_number,
    Return_time, 
    Customer_number,
    Store_id,
    Return_sub_total,
    Return_discount,
    Return_sub_total_after_discount,
    Refunded_to_customer)
FROM 'C:/thmart_csv/return_list.csv'
DELIMITER ',' CSV HEADER;

/*c. Check*/

SELECT * FROM Return_List;