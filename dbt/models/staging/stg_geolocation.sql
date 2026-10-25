select
    nullif(trim(geolocation_zip_code_prefix), '') as geolocation_zip_code_prefix,
    nullif(trim(geolocation_lat), '')::numeric(10, 6) as latitude,
    nullif(trim(geolocation_lng), '')::numeric(10, 6) as longitude,
    nullif(lower(trim(geolocation_city)), '') as geolocation_city,
    nullif(upper(trim(geolocation_state)), '') as geolocation_state
from {{ source('olist', 'olist_geolocation_dataset') }}
