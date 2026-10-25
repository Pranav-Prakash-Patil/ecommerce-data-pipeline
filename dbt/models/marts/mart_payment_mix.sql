select
    coalesce(payment_type, 'not_defined') as payment_type,
    count(*) as payment_record_count,
    count(distinct order_id) as order_count,
    sum(payment_value)::numeric(14, 2) as payment_value,
    avg(payment_installments)::numeric(10, 2) as average_installments
from {{ ref('stg_order_payments') }}
group by coalesce(payment_type, 'not_defined')
