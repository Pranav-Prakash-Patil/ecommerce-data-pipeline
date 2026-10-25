select
    product_id,
    nullif(lower(trim(product_category_name)), '') as product_category_name,
    nullif(trim(product_name_lenght), '')::integer as product_name_length,
    nullif(trim(product_description_lenght), '')::integer as product_description_length,
    nullif(trim(product_photos_qty), '')::integer as product_photos_qty,
    nullif(trim(product_weight_g), '')::integer as product_weight_g,
    nullif(trim(product_length_cm), '')::numeric(10, 2) as product_length_cm,
    nullif(trim(product_height_cm), '')::numeric(10, 2) as product_height_cm,
    nullif(trim(product_width_cm), '')::numeric(10, 2) as product_width_cm
from {{ source('olist', 'olist_products_dataset') }}
