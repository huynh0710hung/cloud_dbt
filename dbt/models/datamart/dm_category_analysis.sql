with facts as (
    select * from {{ ref('fact_events') }}
)

select
    category_l1,
    category_l2,
    category_code,

    count(case when event_type = 'view' then 1 end)         as total_views,
    count(case when event_type = 'cart' then 1 end)         as total_carts,
    count(case when event_type = 'purchase' then 1 end)     as total_purchases,

    sum(case when event_type = 'purchase'
        then price else 0 end)                              as total_revenue,

    round(avg(case when event_type = 'purchase'
        then price end), 2)                                 as avg_purchase_price,

    count(distinct user_id)                                 as unique_users,
    count(distinct product_id)                              as unique_products,

    round(
        safe_divide(
            count(case when event_type = 'purchase' then 1 end),
            nullif(count(case when event_type = 'view' then 1 end), 0)
        ) * 100, 2
    )                                                       as conversion_rate

from facts
where category_l1 is not null
group by 1, 2, 3