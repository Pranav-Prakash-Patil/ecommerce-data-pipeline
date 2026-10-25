select
    customer_id,
    customer_unique_id,
    nullif(trim(customer_zip_code_prefix), '') as customer_zip_code_prefix,
    nullif(lower(trim(customer_city)), '') as customer_city,
    nullif(upper(trim(customer_state)), '') as customer_state
from {{ source('olist', 'olist_customers_dataset') }}
