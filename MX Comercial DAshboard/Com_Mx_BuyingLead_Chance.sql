SELECT
    oc.client_id AS client_id,
    agent_user.username as agent_username,

    CASE
        WHEN bl.chance_ac = 'low' THEN '1. Low'
        WHEN bl.chance_ac = 'long' THEN '2. Long'
        WHEN bl.chance_ac = 'high' THEN '3. High'
        WHEN bl.chance_ac = 'wants_to_offer' THEN '4. Wants to offer'
        ELSE '0. Sin chance'
    END as chance_ac,

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
    oc.country = 'MX' AND
    cp.buying_stage != 'closed'

GROUP BY
    oc.client_id,
    bl.chance_ac,
    agent_user.username