select
    review_id,
    order_id,
    nullif(trim(review_score), '')::integer as review_score,
    nullif(trim(review_creation_date), '')::timestamp as review_created_at,
    nullif(trim(review_answer_timestamp), '')::timestamp as review_answered_at
from {{ source('olist', 'olist_order_reviews_dataset') }}
