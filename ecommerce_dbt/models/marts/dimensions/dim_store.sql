SELECT
    store_id,
    store_name,
    city,
    country,
    sales_channel,
    opened_date
FROM {{ ref('stg_stores') }}
