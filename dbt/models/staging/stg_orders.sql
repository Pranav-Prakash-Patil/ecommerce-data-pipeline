select
    order_id,
    customer_id,
    nullif(lower(trim(order_status)), '') as order_status,
    nullif(trim(order_purchase_timestamp), '')::timestamp as purchased_at,
    nullif(trim(order_approved_at), '')::timestamp as approved_at,
    nullif(trim(order_delivered_carrier_date), '')::timestamp as delivered_to_carrier_at,
    nullif(trim(order_delivered_customer_date), '')::timestamp as delivered_to_customer_at,
    nullif(trim(order_estimated_delivery_date), '')::timestamp as estimated_delivery_at
from {{ source('olist', 'olist_orders_dataset') }}
