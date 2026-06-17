{{ config(
    materialized='view'
) }}

with int_data as (
    select * from {{ ref('int_chicago_crime') }}
),

ranked_locations as (
    select
        block,
        location_description,
        crime_beat,
        district,
        ward,
        community_area,
        crime_location,
        row_number() over (partition by block order by crime_beat desc) as rn
    from int_data
)

select
    block,
    location_description,
    crime_beat,
    district,
    ward,
    community_area,
    crime_location
from ranked_locations
where rn = 1