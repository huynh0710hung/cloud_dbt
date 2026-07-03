with facts as (
    select * from {{ ref('fact_events') }}
),

products as (
    select * from {{ ref('dim_products') }}
)

select
    f.product_id,
    p.brand,
    p.category_l1,
    p.category_l2,
    p.latest_price,

    count(case when f.event_type = 'view' then 1 end)       as total_views,
    count(case when f.event_type = 'cart' then 1 end)       as total_carts,
    count(case when f.event_type = 'purchase' then 1 end)   as total_purchases,

    sum(case when f.event_type = 'purchase'
        then f.price else 0 end)                            as total_revenue,

    round(
        safe_divide(
            count(case when f.event_type = 'purchase' then 1 end),
            nullif(count(case when f.event_type = 'view' then 1 end), 0)
        ) * 100, 2
    )                                                       as view_to_purchase_rate,

    round(
        safe_divide(
            count(case when f.event_type = 'purchase' then 1 end),
            nullif(count(case when f.event_type = 'cart' then 1 end), 0)
        ) * 100, 2
    )                                                       as cart_to_purchase_rate,

    count(distinct f.user_id)                               as unique_users

from facts f
left join products p using (product_id)
group by 1, 2, 3, 4, 5