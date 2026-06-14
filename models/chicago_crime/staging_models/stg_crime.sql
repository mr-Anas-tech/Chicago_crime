with crime as (
    select * from {{ source('chicago_crime', 'crime') }}
),

clean_chicago_crime as (
    select
        coalesce(cast(unique_key as string), '0') as crime_id,
        coalesce(case_number, 'Unknown') as case_number,
        extract(date from timestamp(coalesce(date, '1900-01-01 00:00:00'))) as crime_date,
        extract(time from timestamp(coalesce(date, '1900-01-01 00:00:00'))) as crime_time,
        coalesce(block, 'Unknown') as block,
        coalesce(cast(iucr as string), '0') as iucr_code,
        coalesce(primary_type, 'OTHER OFFENSE') as primary_type,
        coalesce(description, 'Unknown') as description,
        coalesce(location_description, 'OTHER') as location_description,
        coalesce(cast(arrest as string), 'Unknown') as is_arrest,  
        coalesce(cast(domestic as string), 'Unknown') as is_domestic,
        coalesce(cast(beat as string), '0') as crime_beat, 
        coalesce(cast(district as string), '0') as district,
        coalesce(ward, 0.0) as ward,
        coalesce(community_area, 0.0) as community_area,
        coalesce(cast(fbi_code as string), '0') as fbi_code,
        safe_cast(x_coordinate as float64) as x_coordinate,
        safe_cast(y_coordinate as float64) as y_coordinate,
        coalesce(year, 1900) as crime_year,
        extract(date from timestamp(coalesce(updated_on, '1900-01-01 00:00:00'))) as report_updated_on,
        safe_cast(latitude as float64) as latitude,
        safe_cast(longitude as float64) as longitude,
        safe_cast(location as string) as location
    from crime
)

select * from clean_chicago_crime