SELECT 
    cp.profile_ptr_id as buyer_id,
    oc.country,
    bl.chance_ac,

    MIN(timezone('America/Mexico_City',oc.created_at))::date as buyer_creation_date,
    user_ac.username as agent_name,

    CASE
        WHEN cp.buying_stage = 'unreached' THEN '1. Unreached'
        WHEN cp.buying_stage = 'pitched' THEN '2. Pitched'
        WHEN cp.buying_stage = 'scheduled' THEN '3. Scheduled'
        WHEN cp.buying_stage = 'visited' THEN '4. Visited'
        WHEN cp.buying_stage = 'reserved' THEN '5. Reserved'
        WHEN cp.buying_stage = 'reserve_accepted' THEN '6. Reserve Accepted'
        WHEN cp.buying_stage = 'sold' THEN '7. Sold'
        WHEN cp.buying_stage = 'closed' THEN '0. Closed'
        ELSE NULL
    END as buying_stages

FROM accounts_buyinglead bl

    LEFT JOIN accounts_opportunitycase oc
        ON bl.opportunitycase_ptr_id = oc.id
    LEFT JOIN accounts_clientprofile cp
        ON oc.client_id = cp.profile_ptr_id
    LEFT JOIN accounts_profile acprofile
        ON cp.assignee_id = acprofile.id
    LEFT JOIN auth_user user_ac
        ON acprofile.user_id = user_ac.id

GROUP BY cp.profile_ptr_id, agent_name, oc.country, bl.chance_ac