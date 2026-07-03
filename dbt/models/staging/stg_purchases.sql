with source as (
    select * from {{ ref('stg_events') }}
),

purchases as (
    select
        user_id,
        product_id,
        category_id,
        category_code,
        category_l1,
        category_l2,
        brand,
        price,
        user_session,
        event_timestamp,
        event_date,
        row_number() over (partition by user_id, product_id, user_session order by event_timestamp) as rn
    from source
    where event_type = 'purchase'
      and price > 0
),

deduped as (
    select * from purchases where rn = 1
)

select
    {{ dbt_utils.generate_surrogate_key(['user_id', 'product_id', 'user_session']) }} as purchase_id,
    user_id,
    product_id,
    category_id,
    category_code,
    category_l1,
    category_l2,
    brand,
    price,
    user_session,
    event_timestamp,
    event_date
from deduped