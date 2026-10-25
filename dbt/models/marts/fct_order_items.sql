select
    items.order_id,
    items.order_item_id,
    orders.customer_id,
    items.product_id,
    items.seller_id,
    orders.order_status,
    orders.purchased_at,
    items.shipping_limit_at,
    items.price,
    items.freight_value
from {{ ref('stg_order_items') }} as items
left join {{ ref('stg_orders') }} as orders using (order_id)
