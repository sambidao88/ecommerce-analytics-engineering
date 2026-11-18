SELECT
    customer_id,
    first_name,
    last_name,
    TRIM(first_name || ' ' || last_name) AS customer_full_name,
    email,
    signup_date,
    city,
    country,
    marketing_opt_in,
    customer_segment
FROM {{ ref('stg_customers') }}
