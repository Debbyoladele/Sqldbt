select
    id,
    date,
    status,
    chase_date,
    buyer_id,
    confirmed,
    project_fee,
    type,
    area_id,
    region,
    buyer_email_oneoff,
    buyer_name_oneoff,
    a.buyer_name_cleaned,
    a.buyer_email,
    a.buyer_phone,
    a.buyer_address_1,
    a.buyer_address_2,
    a.buyer_city,
    a.buyer_postcode as site_postcode,
    initcap(
        case
            when a.buyer_name_cleaned is null
            then buyer_name_oneoff
            else a.buyer_name_cleaned
        end
    ) as new_buyer_name,
    coalesce(a.buyer_email, buyer_email_oneoff) as new_buyer_email,
    case
        when buyer_name_oneoff is not null
        then 'one-off'
        when a.buyer_name_cleaned is not null
        then 'Recurring'
        else 'unknown'
    end as buyer_status,
    p.prefix || cast(p.project_id as varchar(20)) as project_ref,
    w.associate_percentage,
    case
        when w.associate_percentage = 0 then 'owned' else 'associate'
    end as associate_owned
from {{ ref("staging_tbl_quoted_projects") }}
left join {{ ref("staging_tbl_buyers") }} as a on buyer_id = a.id
left join {{ ref("staging_tbl_project") }} as p on id = p.project_id
left join {{ ref("staging_tbl_area") }} as ga on area_id = ga.area_id
left join {{ ref("staging_tbl_associate") }} as w on ga.associate_id = w.id
left join {{ ref("staging_tbl_quote_header") }} on id = quote_id;