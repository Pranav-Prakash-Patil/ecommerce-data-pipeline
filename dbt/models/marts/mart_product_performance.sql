select
    products.product_category_name,
    count(*) filter (where items.order_status = 'delivered') as delivered_item_count,
    count(distinct items.order_id) filter (where items.order_status = 'delivered')
        as delivered_order_count,
    coalesce(sum(items.price) filter (where items.order_status = 'delivered'), 0)::numeric(14, 2)
        as delivered_merchandise_revenue,
    coalesce(sum(items.freight_value) filter (where items.order_status = 'delivered'), 0)::numeric(14, 2)
        as delivered_freight_revenue,
    (avg(items.price) filter (where items.order_status = 'delivered'))::numeric(14, 2)
        as average_delivered_item_price
from {{ ref('fct_order_items') }} as items
join {{ ref('dim_products') }} as products using (product_id)
group by products.product_category_name
