SELECT
    oc.client_id AS client_id,
    agent_user.username as agent_username,
     
    CASE
        WHEN cp.buying_stage = 'unreached' THEN '1. Unreached'
        WHEN cp.buying_stage = 'pitched' THEN '2. Pitched'
        WHEN cp.buying_stage = 'scheduled' THEN '3. Scheduled'
        WHEN cp.buying_stage = 'visited' THEN '4. Visited'
        WHEN cp.buying_stage = 'reserved' THEN '5. Reserved'
        WHEN cp.buying_stage = 'reserve_accepted' THEN '6. Reserve Accepted'
        WHEN cp.buying_stage = 'signed' THEN '7. Signed'
        WHEN cp.buying_stage = 'sold' THEN '8. Sold'
        WHEN cp.buying_stage = 'closed' THEN '0. Closed'
        ELSE NULL
    END AS client_buying_stage,

    MIN(timezone('America/Mexico_City', oc.created_at)::date) AS client_creation_date

FROM accounts_buyinglead bl

    LEFT JOIN accounts_opportunitycase oc
        ON oc.id = bl.opportunitycase_ptr_id
    LEFT JOIN accounts_clientprofile cp
        ON cp.profile_ptr_id = oc.client_id
    LEFT JOIN accounts_profile prof
        ON prof.id = cp.profile_ptr_id
    LEFT JOIN auth_user client_user
        ON client_user.id = prof.user_id
    LEFT JOIN accounts_profile ac_profile
        ON ac_profile.id = cp.assignee_id
    LEFT JOIN auth_user agent_user
        ON agent_user.id = ac_profile.user_id

WHERE 
    oc.country = 'MX'

GROUP BY
    oc.client_id,
    cp.buying_stage,
    agent_user.username