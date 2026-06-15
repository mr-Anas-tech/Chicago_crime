with  staging_data as  (
    select * from 
    {{ ref('stg_crime') }}
),

int_transformation as(
    select 
    crime_id,
    case_number,
    crime_date,
    crime_time,
    extract( hour from crime_time )  as crime_hour,
    extract(day from crime_date) as crime_day,
    extract(dayofweek from crime_date) as crime_weak_days,
    extract(month from crime_date) as crime_month,
    crime_year,
    datetime_diff(cast( report_updated_on as datetime),
    cast(crime_date as datetime), day) as report_latancy_days,
    report_updated_on,
    block,
    iucr_code,
    primary_type as crime_category,
    description as crime_description,
    location_description,
    case when lower(is_arrest)='true' then 1 
    when lower(is_arrest)='false' then 0 
    else  null end as is_arrest,
    case when lower(is_domestic)='true' then 1
    when lower(is_domestic)='false' then 0 else null
    end as is_domestic,
    crime_beat,
    district,
    ward,
    community_area,
    fbi_code,
    x_coordinate,
    y_coordinate, 
    latitude,
    longitude,
    location as crime_location
    from staging_data
)

select * from int_transformation