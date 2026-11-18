SELECT
    CAST(product_id AS VARCHAR) AS product_id,
    TRIM(product_name) AS product_name,
    TRIM(category) AS category,
    TRIM(subcategory) AS subcategory,
    CAST(unit_cost AS BIGINT) AS unit_cost,
    CAST(list_price AS BIGINT) AS list_price,
    CAST(is_active AS BOOLEAN) AS is_active
FROM {{ ref('products') }}
