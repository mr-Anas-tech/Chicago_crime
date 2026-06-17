{{ config(
    materialized='view'
) }}

with int_data as (
    select * from {{ ref('int_chicago_crime') }}
),

deduped as (
    select 
        iucr_code,
        fbi_code,
        crime_category,
        crime_description,
        row_number() over (partition by iucr_code order by fbi_code) as rn
    from int_data
)

select 
    iucr_code,
    fbi_code,
    crime_category,
    crime_description
from deduped 
where rn = 1