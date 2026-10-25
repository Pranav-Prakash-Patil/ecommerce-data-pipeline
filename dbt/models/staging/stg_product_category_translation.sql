select
    nullif(lower(trim(product_category_name)), '') as product_category_name,
    nullif(lower(trim(product_category_name_english)), '') as product_category_name_english
from {{ source('olist', 'product_category_name_translation') }}
