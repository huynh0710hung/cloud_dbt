{{ config(materialized='view') }}

with events as (
    select * from {{ ref('stg_events') }}
),

users as (
    select user_id, first_seen_date
    from {{ ref('dim_users') }}
)

select
    {{ dbt_utils.generate_surrogate_key([
        'e.user_id', 'e.product_id', 'e.user_session', 'e.event_timestamp'
    ]) }}                                               as event_id,
    e.user_id,
    e.product_id,
    e.category_id,
    e.user_session,
    e.event_timestamp,
    e.event_date,
    e.event_type,
    e.price,
    e.brand,
    e.category_code,
    e.category_l1,
    e.category_l2,
    u.first_seen_date,
    date_diff(e.event_date, u.first_seen_date, day)     as days_since_first_event,
    date_diff(e.event_date, u.first_seen_date, week)    as weeks_since_first_event
from events e
left join users u using (user_id)