with events as (
    select * from {{ ref('stg_events') }}
),

latest as (
    select
        product_id,
        category_id,
        category_code,
        category_l1,
        category_l2,
        category_l3,
        brand,
        price,
        row_number() over (
            partition by product_id
            order by event_timestamp desc
        ) as rn
    from events
    where price is not null
),

product_stats as (
    select
        product_id,
        min(price)      as min_price,
        max(price)      as max_price,
        avg(price)      as avg_price
    from events
    group by product_id
)

select
    l.product_id,
    l.category_id,
    l.category_code,
    l.category_l1,
    l.category_l2,
    l.category_l3,
    l.brand,
    l.price             as latest_price,
    p.min_price,
    p.max_price,
    round(p.avg_price, 2) as avg_price
from latest l
left join product_stats p using (product_id)
where l.rn = 1 