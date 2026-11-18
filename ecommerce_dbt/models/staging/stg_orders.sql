SELECT
    CAST(order_id AS VARCHAR) AS order_id,
    CAST(customer_id AS VARCHAR) AS customer_id,
    CAST(store_id AS VARCHAR) AS store_id,
    CAST(order_date AS DATE) AS order_date,
    LOWER(TRIM(order_status)) AS order_status,
    LOWER(TRIM(payment_method)) AS payment_method,
    UPPER(TRIM(currency)) AS currency,
    CAST(shipping_fee AS BIGINT) AS shipping_fee,
    CAST(order_discount AS BIGINT) AS order_discount
FROM {{ ref('orders') }}
