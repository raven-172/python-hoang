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
