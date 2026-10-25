select
    customers.customer_state,
    count(*) as delivered_order_count,
    avg(
        extract(epoch from (orders.delivered_to_customer_at - orders.purchased_at)) / 86400.0
    )::numeric(10, 2) as average_delivery_days,
    avg(
        greatest(
            extract(epoch from (orders.delivered_to_customer_at - orders.estimated_delivery_at))
                / 86400.0,
            0
        )
    )::numeric(10, 2) as average_late_days,
    avg(orders.delivered_on_time::integer)::numeric(6, 4) as on_time_delivery_rate
from {{ ref('fct_orders') }} as orders
join {{ ref('dim_customers') }} as customers using (customer_id)
where orders.order_status = 'delivered'
  and orders.purchased_at is not null
  and orders.delivered_to_customer_at is not null
  and orders.estimated_delivery_at is not null
group by customers.customer_state
