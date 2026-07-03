with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2019-11-01' as date)",
        end_date="cast('2019-12-01' as date)"
    ) }}
)

select
    cast(date_day as date)                          as date_day,
    extract(year from date_day)                     as year,
    extract(month from date_day)                    as month,
    extract(day from date_day)                      as day,
    extract(dayofweek from date_day)                as day_of_week,
    format_date('%A', date_day)                     as day_name,
    format_date('%B', date_day)                     as month_name,
    extract(week from date_day)                     as week_number,
    date_trunc(date_day, week(monday))              as week_start,
    date_trunc(date_day, month)                     as month_start,
    case when extract(dayofweek from date_day) in (1, 7)
         then true else false end                   as is_weekend
from date_spine