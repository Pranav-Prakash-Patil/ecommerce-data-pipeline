with order_categories as (
    select distinct
        items.order_id,
        products.product_category_name
    from {{ ref('fct_order_items') }} as items
    join {{ ref('dim_products') }} as products using (product_id)
),
reviews_by_order as (
    select
        order_id,
        avg(review_score)::numeric(4, 2) as average_order_review_score
    from {{ ref('stg_order_reviews') }}
    group by order_id
)
select
    categories.product_category_name,
    count(distinct categories.order_id) as reviewed_order_count,
    avg(reviews.average_order_review_score)::numeric(4, 2) as average_review_score
from order_categories as categories
join reviews_by_order as reviews using (order_id)
group by categories.product_category_name
