/*Build relevant indexes in each main activity*/
/*SAlE*/

WITH 
    daily_sale_report AS (
        SELECT
            sl.Store_name,
            DATE(Il.Invoice_time) AS Invoice_date,
            EXTRACT(EPOCH FROM(MAX(Il.Invoice_time) - MIN(Il.Invoice_time)))/3600 AS Operating_time_day,
            COUNT(*) AS Total_invoice_quantity_day,
            SUM(Il.Invoice_sub_total) AS Total_invoice_value_day,
            SUM(Il.Invoice_discount) AS Total_invoice_discount_day
        FROM Invoice_list Il
        LEFT JOIN store_list Sl ON Sl.Store_id = Il.store_id
        GROUP BY DATE(Il.Invoice_time), sl.Store_name
),

    daily_return_report AS (
        SELECT  
            Sl.Store_name,
            DATE(Rl.Return_time) AS Return_date,
            COALESCE(COUNT(*),0) AS Total_return_quantity_day,
            COALESCE(SUM(Rl.Return_sub_total),0) AS Total_return_value_day,
            COALESCE(SUM(Rl.Return_discount),0) AS Total_return_discount_day
        FROM Return_List Rl
        LEFT JOIN Store_list Sl ON Sl.Store_id = Rl.store_id
        GROUP BY DATE(Rl.Return_time), sl.store_name
)

SELECT
    dsr.store_name,
    dsr.Invoice_date AS sale_date,
    dsr.Operating_time_day,
    dsr.Total_invoice_quantity_day,
    COALESCE(drr.Total_return_quantity_day,0) AS Total_return_quantity_day,
    dsr.Total_invoice_value_day,
    COALESCE(drr.Total_return_value_day,0) AS Total_return_value_day,
    dsr.Total_invoice_discount_day,
    COALESCE(drr.Total_return_discount_day,0) AS Total_return_discount_day
FROM daily_sale_report dsr
LEFT JOIN daily_return_report drr ON drr.store_name = dsr.store_name AND drr.return_date = dsr.Invoice_date
ORDER BY dsr.store_name, sale_date;

/*INVENTORY MANAGEMENT*/
/*1. INVENTORY*/

SELECT * FROM Inventory_report;

/*2. PURCHASE ORDER VS RECEIPT*/

SELECT
    DATE(COALESCE(Pe.Purchase_time, PO_time)) AS time_date,
    SUM(COALESCE(Po.Total_quantity,0)) AS Total_quantity_po,
    SUM(COALESCE(Pe.Total_quantity,0)) AS Total_qroduct_pe
FROM Purchase_receipt Pe
FULL OUTER JOIN Purchase_Order Po ON Pe.Purchase_time = PO_time
GROUP BY DATE(COALESCE(Pe.Purchase_time, PO_time))
ORDER BY DATE(COALESCE(Pe.Purchase_time, PO_time));

/*3. INVENTORY DAMAGE*/

SELECT
    sl.store_name,
    DATE(Id.Damage_time) AS damage_date,
    SUM(Id.Total_damage_quantity) AS Total_damage_quantity_day,
    SUM(Id.Total_damage_product) AS Total_damage_product_day,
    SUM(Id.Total_damage_value) AS Total_damage_value_day
FROM Inventory_Damaged Id
LEFT JOIN Store_List Sl ON Sl.Store_id = Id.Store_id
GROUP BY DATE(Id.Damage_time), sl.Store_name
ORDER BY DATE(Id.Damage_time);

/*4. INVENTORY RETURN*/

SELECT
    sl.store_name,
    DATE(Pr.Purchase_return_time) AS Purchase_return_date,
    SUM(Pr.Total_quantity) AS Total_purchase_return_quantity_day,
    SUM(Pr.Total_product) AS Total_purchase_return_product_day,
    SUM(Pr.Total) AS Total_purchase_return_value_day,
    SUM(Pr.Paid_by_supplier) AS Total_paid_by_supplier_day
FROM Purchase_return Pr
LEFT JOIN Store_List Sl ON Sl.Store_id = Pr.Store_id
GROUP BY DATE(Pr.Purchase_return_time), sl.Store_name
ORDER BY DATE(Pr.Purchase_return_time);

/*4. INVENTORY COUNT*/

SELECT
    sl.store_name,
    DATE(Ic.IC_completed_time) AS IC_date,
    SUM(Ic.IC_total_net_diff_qty) AS IC_total_net_diff_qty_day
FROM Inventory_Count Ic
LEFT JOIN Store_List Sl ON Sl.Store_id = Ic.Store_id
GROUP BY DATE(Ic.IC_completed_time), sl.Store_name
ORDER BY DATE(Ic.IC_completed_time);

/*5. INVENTORY COUNT - Processing time*/

SELECT
    sl.store_name,
    DATE(Ic.IC_completed_time) AS IC_date,
    AVG(ABS(EXTRACT(EPOCH FROM (Ic.IC_time - Ic.IC_completed_time))/86400)) AS Processing_time
FROM Inventory_Count Ic
LEFT JOIN Store_List Sl ON Sl.Store_id = Ic.Store_id
GROUP BY DATE(Ic.IC_completed_time), sl.Store_name
ORDER BY DATE(Ic.IC_completed_time);

/*6. PURCHASE RECEIPT STATUS*/

SELECT
    DATE(Purchase_time) AS Purchase_date,
    SUM(CASE WHEN Purchase_status = 'Completed' THEN 1 ELSE 0 END) AS Purchase_completed_quantity,
    SUM(CASE WHEN Purchase_status = 'Draft' THEN 1 ELSE 0 END) AS Purchase_draft_quantity
FROM Purchase_receipt
GROUP BY DATE(Purchase_time)
ORDER BY DATE(Purchase_time);

/*7. INVENTORY DAMAGE STATUS*/

SELECT
    DATE(Damage_time) AS Damage_date,
    SUM(CASE WHEN Damage_status = 'Completed' THEN 1 ELSE 0 END) AS Damage_completed_quantity,
    SUM(CASE WHEN Damage_status = 'Draft' THEN 1 ELSE 0 END) AS Damage_draft_quantity
FROM Inventory_Damaged
GROUP BY DATE(Damage_time)
ORDER BY DATE(Damage_time);

/*8. PURCHASE RETURN STATUS*/

SELECT
    DATE(Purchase_return_time) AS Purchase_date,
    SUM(CASE WHEN Purchase_return_status = 'Completed' THEN 1 ELSE 0 END) AS Purchase_return_completed_quantity,
    SUM(CASE WHEN Purchase_return_status = 'Draft' THEN 1 ELSE 0 END) AS Purchase_return_draft_quantity
FROM Purchase_return
GROUP BY DATE(Purchase_return_time)
ORDER BY DATE(Purchase_return_time);

/*9. INVENTORY DAMAGE - Processing time*/

SELECT
    DATE(Damage_time) AS Damage_date,
    AVG(ABS(EXTRACT(EPOCH FROM (Damage_created_time - Damage_time))/86400)) AS Processing_time
FROM Inventory_Damaged
GROUP BY DATE(Damage_time)
ORDER BY DATE(Damage_time);

/*10. PURCHASE RECEIPT - Processing time*/

SELECT
    DATE(Purchase_time) AS Purchase_date,
    AVG(ABS(EXTRACT(EPOCH FROM (Purchase_created_time - Purchase_time))/86400)) AS Processing_time
FROM Purchase_receipt
GROUP BY DATE(Purchase_time)
ORDER BY DATE(Purchase_time);

/*11. PURCHASE RETURN - Processing time*/

SELECT
    DATE(Purchase_return_time) AS Purchase_return_date,
    AVG(ABS(EXTRACT(EPOCH FROM (Purchase_return_created_time - Purchase_return_time))/86400)) AS Processing_time
FROM Purchase_return
GROUP BY DATE(Purchase_return_time)
ORDER BY DATE(Purchase_return_time);