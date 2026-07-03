with source as (
    select * from {{ source('raw', 'raw_events') }}
),

cleaned as (
    select
        cast(user_id as string)                                         as user_id,
        cast(product_id as string)                                      as product_id,
        cast(category_id as string)                                     as category_id,
        cast(user_session as string)                                    as user_session,
        cast(event_time as timestamp)                                   as event_timestamp,
        date(cast(event_time as timestamp))                             as event_date,
        lower(trim(event_type))                                         as event_type,
        lower(trim(brand))                                              as brand,
        cast(price as float64)                                          as price,
        lower(trim(category_code))                                      as category_code,
        split(lower(trim(category_code)), '.')[safe_offset(0)]          as category_l1,
        split(lower(trim(category_code)), '.')[safe_offset(1)]          as category_l2,
        split(lower(trim(category_code)), '.')[safe_offset(2)]          as category_l3
    from source
    where event_type in ('view', 'cart', 'purchase')
      and user_id is not null
      and product_id is not null
)

select * from cleaned