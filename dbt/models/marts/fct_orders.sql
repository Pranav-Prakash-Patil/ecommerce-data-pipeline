with items_by_order as (
    select
        order_id,
        count(*) as order_item_count,
        sum(price) as merchandise_value,
        sum(freight_value) as freight_value
    from {{ ref('stg_order_items') }}
    group by order_id
),
payments_by_order as (
    select
        order_id,
        sum(payment_value) as payment_value,
        string_agg(distinct payment_type, ', ' order by payment_type) as payment_types
    from {{ ref('stg_order_payments') }}
    group by order_id
),
reviews_by_order as (
    select
        order_id,
        avg(review_score)::numeric(4, 2) as average_review_score,
        count(*) as review_count
    from {{ ref('stg_order_reviews') }}
    group by order_id
)
select
    orders.order_id,
    orders.customer_id,
    orders.order_status,
    orders.purchased_at,
    orders.approved_at,
    orders.delivered_to_carrier_at,
    orders.delivered_to_customer_at,
    orders.estimated_delivery_at,
    items.order_item_count,
    items.merchandise_value,
    items.freight_value,
    payments.payment_value,
    payments.payment_types,
    reviews.average_review_score,
    coalesce(reviews.review_count, 0) as review_count,
    case
        when orders.order_status <> 'delivered' then null
        when orders.delivered_to_customer_at is null or orders.estimated_delivery_at is null then null
        else orders.delivered_to_customer_at <= orders.estimated_delivery_at
    end as delivered_on_time
from {{ ref('stg_orders') }} as orders
left join items_by_order as items using (order_id)
left join payments_by_order as payments using (order_id)
left join reviews_by_order as reviews using (order_id)
