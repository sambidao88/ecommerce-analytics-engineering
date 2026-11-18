SELECT
    order_items.order_item_id,
    order_items.order_id,
    orders.order_date,
    orders.order_status,
    orders.customer_id,
    orders.store_id,
    stores.sales_channel,
    orders.payment_method,
    orders.currency,
    order_items.product_id,
    products.category,
    products.subcategory,
    order_items.quantity,
    order_items.unit_price,
    order_items.item_discount,
    order_items.unit_cost_at_sale,
    order_items.quantity * order_items.unit_price AS gross_item_revenue,
    order_items.quantity * order_items.unit_price - order_items.item_discount AS net_item_revenue,
    order_items.quantity * order_items.unit_cost_at_sale AS item_cost_amount,
    order_items.quantity * order_items.unit_price
        - order_items.item_discount
        - order_items.quantity * order_items.unit_cost_at_sale AS gross_profit_before_order_discount
FROM {{ ref('stg_order_items') }} AS order_items
INNER JOIN {{ ref('stg_orders') }} AS orders
    ON order_items.order_id = orders.order_id
INNER JOIN {{ ref('stg_products') }} AS products
    ON order_items.product_id = products.product_id
INNER JOIN {{ ref('stg_stores') }} AS stores
    ON orders.store_id = stores.store_id
