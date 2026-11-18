SELECT
    product_id,
    product_name,
    category,
    subcategory,
    unit_cost,
    list_price,
    list_price - unit_cost AS list_price_margin,
    is_active
FROM {{ ref('stg_products') }}
