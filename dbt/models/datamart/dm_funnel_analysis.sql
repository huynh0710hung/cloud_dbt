with facts as (
    select * from {{ ref('fact_events') }}
),

funnel as (
    select
        category_l1,
        user_id,
        max(case when event_type = 'view'     then 1 else 0 end) as did_view,
        max(case when event_type = 'cart'     then 1 else 0 end) as did_cart,
        max(case when event_type = 'purchase' then 1 else 0 end) as did_purchase
    from facts
    where category_l1 is not null
    group by 1, 2
)

select
    category_l1,
    sum(did_view)                                           as viewers,
    sum(did_cart)                                           as added_to_cart,
    sum(did_purchase)                                       as purchasers,

    round(safe_divide(sum(did_cart),
        nullif(sum(did_view), 0)) * 100, 2)                as view_to_cart_rate,
    round(safe_divide(sum(did_purchase),
        nullif(sum(did_cart), 0)) * 100, 2)                as cart_to_purchase_rate,
    round(safe_divide(sum(did_purchase),
        nullif(sum(did_view), 0)) * 100, 2)                as overall_conversion_rate

from funnel
group by 1
order by purchasers desc