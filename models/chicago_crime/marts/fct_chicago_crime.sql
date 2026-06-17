{{ config(
    materialized= 'view'
) }}

with int_crime as(
    select * from {{ ref('int_chicago_crime') }}
),

fct as(
    select
    crime_id,
    case_number,
    crime_date,
    crime_time,
    crime_hour,
    crime_day,
    crime_month,
    crime_year,
    crime_week_days,
    report_latancy_days,
    report_updated_on,
    block,
    iucr_code,
    fbi_code,
    is_arrest,
    is_domestic,
     x_coordinate,
    y_coordinate, 
    latitude,
    longitude
    from int_crime
)

select * from fct