select
    geolocation_zip_code_prefix,
    round(avg(latitude), 6) as latitude,
    round(avg(longitude), 6) as longitude,
    min(geolocation_city) as geolocation_city,
    min(geolocation_state) as geolocation_state,
    count(*) as source_location_count
from {{ ref('stg_geolocation') }}
where geolocation_zip_code_prefix is not null
group by geolocation_zip_code_prefix
