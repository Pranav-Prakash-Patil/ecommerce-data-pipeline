select
    date_trunc('month', purchased_at)::date as sales_month,
    count(*) as order_count,
    count(*) filter (where order_status = 'delivered') as delivered_order_count,
    count(*) filter (where order_status = 'canceled') as canceled_order_count,
    coalesce(sum(merchandise_value) filter (where order_status = 'delivered'), 0)::numeric(14, 2)
        as delivered_merchandise_revenue,
    coalesce(sum(freight_value) filter (where order_status = 'delivered'), 0)::numeric(14, 2)
        as delivered_freight_revenue,
    (avg(merchandise_value) filter (where order_status = 'delivered'))::numeric(14, 2)
        as average_delivered_order_value
from {{ ref('fct_orders') }}
where purchased_at is not null
group by 1
