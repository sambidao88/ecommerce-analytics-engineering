SELECT
    CAST(customer_id AS VARCHAR) AS customer_id,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    LOWER(TRIM(email)) AS email,
    CAST(signup_date AS DATE) AS signup_date,
    TRIM(city) AS city,
    UPPER(TRIM(country)) AS country,
    CAST(marketing_opt_in AS BOOLEAN) AS marketing_opt_in,
    LOWER(TRIM(customer_segment)) AS customer_segment
FROM {{ ref('customers') }}
