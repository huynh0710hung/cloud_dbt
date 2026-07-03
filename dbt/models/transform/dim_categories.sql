with events as (
    select * from {{ ref('stg_events') }}
)

select distinct
    {{ dbt_utils.generate_surrogate_key(['category_code']) }}   as category_id_sk,
    category_code,
    category_l1,
    category_l2,
    category_l3,
    coalesce(category_l3, category_l2, category_l1)             as category_leaf
from events
where category_code is not null