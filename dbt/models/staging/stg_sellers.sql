select
    seller_id,
    nullif(trim(seller_zip_code_prefix), '') as seller_zip_code_prefix,
    nullif(lower(trim(seller_city)), '') as seller_city,
    nullif(upper(trim(seller_state)), '') as seller_state
from {{ source('olist', 'olist_sellers_dataset') }}
