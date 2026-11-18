WITH RECURSIVE date_spine (date_day, last_date) AS (
    SELECT
        MIN(order_date) AS date_day,
        MAX(order_date) AS last_date
    FROM {{ ref('stg_orders') }}

    UNION ALL

    SELECT
        CAST(date_day + INTERVAL '1 day' AS DATE),
        last_date
    FROM date_spine
    WHERE date_day < last_date
)

SELECT
    CAST(STRFTIME(date_day, '%Y%m%d') AS INTEGER) AS date_key,
    date_day,
    CAST(EXTRACT(YEAR FROM date_day) AS INTEGER) AS year,
    CAST(EXTRACT(QUARTER FROM date_day) AS INTEGER) AS quarter,
    CAST(EXTRACT(MONTH FROM date_day) AS INTEGER) AS month,
    STRFTIME(date_day, '%B') AS month_name,
    CAST(EXTRACT(DAY FROM date_day) AS INTEGER) AS day_of_month,
    CAST(EXTRACT(ISODOW FROM date_day) AS INTEGER) AS day_of_week_number,
    STRFTIME(date_day, '%A') AS day_name,
    EXTRACT(ISODOW FROM date_day) IN (6, 7) AS is_weekend
FROM date_spine
WHERE date_day IS NOT NULL
