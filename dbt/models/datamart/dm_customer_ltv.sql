with purchases as (
    select * from {{ ref('stg_purchases') }}
),

users as (
    select * from {{ ref('dim_users') }}
),

ltv as (
    select
        p.user_id,
        u.first_seen_date,
        u.last_seen_date,
        u.active_days_span,

        count(distinct p.event_date)                        as purchase_days,
        count(*)                                            as total_orders,
        sum(p.price)                                        as total_revenue,
        round(avg(p.price), 2)                              as avg_order_value,
        min(p.price)                                        as min_order_value,
        max(p.price)                                        as max_order_value,
        count(distinct p.category_l1)                       as categories_purchased,
        count(distinct p.brand)                             as brands_purchased,

        round(
            safe_divide(sum(p.price), nullif(u.active_days_span, 0)) * 30
        , 2)                                                as estimated_monthly_ltv

    from purchases p
    left join users u using (user_id)
    group by 1, 2, 3, 4
)

select
    *,
    case
        when total_revenue >= 1000  then 'High Value'
        when total_revenue >= 300   then 'Mid Value'
        else                             'Low Value'
    end                                                     as ltv_segment
from ltv