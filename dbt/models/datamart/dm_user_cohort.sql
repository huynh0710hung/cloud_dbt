with facts as (
    select * from {{ ref('fact_events') }}
),

cohort_base as (
    select
        user_id,
        date_trunc(first_seen_date, week(monday))           as cohort_week,
        weeks_since_first_event                             as week_number
    from facts
    where event_type = 'purchase'
),

cohort_size as (
    select
        cohort_week,
        count(distinct user_id)                             as cohort_users
    from cohort_base
    where week_number = 0
    group by 1
),

cohort_retention as (
    select
        c.cohort_week,
        c.week_number,
        count(distinct c.user_id)                           as retained_users
    from cohort_base c
    group by 1, 2
)

select
    r.cohort_week,
    r.week_number,
    s.cohort_users,
    r.retained_users,
    round(
        safe_divide(r.retained_users, s.cohort_users) * 100
    , 2)                                                    as retention_rate
from cohort_retention r
left join cohort_size s using (cohort_week)
order by 1, 2