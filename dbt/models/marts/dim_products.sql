select
    products.product_id,
    coalesce(
        replace(translations.product_category_name_english, '_', ' '),
        replace(products.product_category_name, '_', ' '),
        'unknown'
    ) as product_category_name,
    products.product_name_length,
    products.product_description_length,
    products.product_photos_qty,
    products.product_weight_g,
    products.product_length_cm,
    products.product_height_cm,
    products.product_width_cm
from {{ ref('stg_products') }} as products
left join {{ ref('stg_product_category_translation') }} as translations
    using (product_category_name)
