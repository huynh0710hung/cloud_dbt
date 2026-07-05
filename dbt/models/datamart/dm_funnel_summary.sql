-- dm_funnel_summary.sql
select
    'Views'    as stage, 1 as stage_order, sum(viewers)       as users from {{ ref('dm_funnel_analysis') }}
union all
select
    'Cart'     as stage, 2 as stage_order, sum(added_to_cart) as users from {{ ref('dm_funnel_analysis') }}
union all
select
    'Purchase' as stage, 3 as stage_order, sum(purchasers)    as users from {{ ref('dm_funnel_analysis') }}