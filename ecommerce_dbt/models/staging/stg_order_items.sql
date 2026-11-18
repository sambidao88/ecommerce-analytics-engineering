SELECT
    CAST(order_item_id AS VARCHAR) AS order_item_id,
    CAST(order_id AS VARCHAR) AS order_id,
    CAST(product_id AS VARCHAR) AS product_id,
    CAST(quantity AS INTEGER) AS quantity,
    CAST(unit_price AS BIGINT) AS unit_price,
    CAST(item_discount AS BIGINT) AS item_discount,
    CAST(unit_cost_at_sale AS BIGINT) AS unit_cost_at_sale
FROM {{ ref('order_items') }}
