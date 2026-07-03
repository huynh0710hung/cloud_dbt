with facts as (
    select * from {{ ref('fact_events') }}
),

dates as (
    select * from {{ ref('dim_dates') }}
)

select
    f.event_date,
    d.day_name,
    d.week_number,
    d.is_weekend,

    count(*)                                                as total_events,
    count(case when f.event_type = 'view' then 1 end)       as total_views,
    count(case when f.event_type = 'cart' then 1 end)       as total_carts,
    count(case when f.event_type = 'purchase' then 1 end)   as total_purchases,

    sum(case when f.event_type = 'purchase'
        then f.price else 0 end)                            as total_revenue,
    round(avg(case when f.event_type = 'purchase'
        then f.price end), 2)                               as avg_order_value,

    count(distinct f.user_id)                               as unique_users,
    count(distinct f.user_session)                          as unique_sessions,
    count(distinct f.product_id)                            as unique_products,

    round(
        safe_divide(
            count(case when f.event_type = 'purchase' then 1 end),
            nullif(count(case when f.event_type = 'view' then 1 end), 0)
        ) * 100, 2
    )                                                       as overall_conversion_rate

from facts f
left join dates d on f.event_date = d.date_day
group by 1, 2, 3, 4
order by 1