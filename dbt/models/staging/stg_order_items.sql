select
    order_id,
    nullif(trim(order_item_id), '')::integer as order_item_id,
    product_id,
    seller_id,
    nullif(trim(shipping_limit_date), '')::timestamp as shipping_limit_at,
    nullif(trim(price), '')::numeric(12, 2) as price,
    nullif(trim(freight_value), '')::numeric(12, 2) as freight_value
from {{ source('olist', 'olist_order_items_dataset') }}
