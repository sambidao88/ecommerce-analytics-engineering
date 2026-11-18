SELECT
    CAST(store_id AS VARCHAR) AS store_id,
    TRIM(store_name) AS store_name,
    TRIM(city) AS city,
    UPPER(TRIM(country)) AS country,
    LOWER(TRIM(sales_channel)) AS sales_channel,
    CAST(opened_date AS DATE) AS opened_date
FROM {{ ref('stores') }}
