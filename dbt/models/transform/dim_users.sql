with events as (
    select * from {{ ref('stg_events') }}
)

select
    user_id,
    min(event_timestamp)                                    as first_seen_at,
    max(event_timestamp)                                    as last_seen_at,
    min(event_date)                                         as first_seen_date,
    max(event_date)                                         as last_seen_date,
    count(*)                                                as total_events,
    countif(event_type = 'view')                            as total_views,
    countif(event_type = 'cart')                            as total_carts,
    countif(event_type = 'purchase')                        as total_purchases,
    count(distinct user_session)                            as total_sessions,
    case when countif(event_type = 'purchase') > 0
         then true else false end                           as is_buyer,
    date_diff(max(event_date), min(event_date), day)        as active_days_span
from events
group by user_id