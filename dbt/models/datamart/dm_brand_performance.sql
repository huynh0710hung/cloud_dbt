with facts as (
    select * from {{ ref('fact_events') }}
)

select
    brand,
    category_l1,

    count(case when event_type = 'view' then 1 end)         as total_views,
    count(case when event_type = 'cart' then 1 end)         as total_carts,
    count(case when event_type = 'purchase' then 1 end)     as total_purchases,

    sum(case when event_type = 'purchase'
        then price else 0 end)                              as total_revenue,
    round(avg(case when event_type = 'purchase'
        then price end), 2)                                 as avg_selling_price,

    count(distinct product_id)                              as unique_products,
    count(distinct user_id)                                 as unique_buyers,

    round(
        safe_divide(
            count(case when event_type = 'purchase' then 1 end),
            nullif(count(case when event_type = 'view' then 1 end), 0)
        ) * 100, 2
    )                                                       as conversion_rate

from facts
where brand is not null
group by 1, 2
order by total_revenue desc