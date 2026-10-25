select
    order_id,
    nullif(trim(payment_sequential), '')::integer as payment_sequential,
    nullif(lower(trim(payment_type)), '') as payment_type,
    nullif(trim(payment_installments), '')::integer as payment_installments,
    nullif(trim(payment_value), '')::numeric(12, 2) as payment_value
from {{ source('olist', 'olist_order_payments_dataset') }}
