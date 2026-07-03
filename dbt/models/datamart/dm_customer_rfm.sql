with purchases as (
    select * from {{ ref('stg_purchases') }}
),

rfm_raw as (
    select
        user_id,
        max(event_date)                                     as last_purchase_date,
        count(distinct event_date)                          as frequency,
        sum(price)                                          as monetary,
        date_diff(date '2019-11-30', max(event_date), day) as recency_days
    from purchases
    group by user_id
),

rfm_scored as (
    select
        user_id,
        recency_days,
        frequency,
        round(monetary, 2)                                  as monetary,
        last_purchase_date,

        -- score 1-4 (4 = best)
        ntile(4) over (order by recency_days desc)          as r_score,
        ntile(4) over (order by frequency asc)              as f_score,
        ntile(4) over (order by monetary asc)               as m_score
    from rfm_raw
),

segmented as (
    select
        *,
        concat(cast(r_score as string),
               cast(f_score as string),
               cast(m_score as string))                     as rfm_score,

        case
            when r_score = 4 and f_score = 4               then 'Champion'
            when r_score = 4 and f_score = 3               then 'Loyal'
            when r_score = 3 and f_score >= 3              then 'Potential Loyalist'
            when r_score = 4 and f_score <= 2              then 'New Customer'
            when r_score = 3 and f_score <= 2              then 'Promising'
            when r_score = 2 and f_score >= 3              then 'At Risk'
            when r_score = 2 and f_score <= 2              then 'Needs Attention'
            when r_score = 1 and f_score >= 3              then 'Cant Lose Them'
            when r_score = 1 and f_score <= 2              then 'Lost'
            else 'Other'
        end                                                 as segment
    from rfm_scored
)

select * from segmented