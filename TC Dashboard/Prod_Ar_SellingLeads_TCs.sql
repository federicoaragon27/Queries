SELECT
    oc.id AS case_id,
    
    CASE
        WHEN sl.stage = 'unreached' THEN '1. Unreached'
        WHEN sl.stage = 'pitched' THEN '2. Pitched'
        WHEN sl.stage = 'scheduled' THEN '3. Scheduled'
        WHEN sl.stage = 'proposal_made' THEN '4. Fuera de TC'
        WHEN sl.stage = 'listed' THEN '4. Fuera de TC'
        WHEN sl.stage = 'consulted' THEN '4. Fuera de TC'
        WHEN sl.stage = 'reserved' THEN '4. Fuera de TC'
        WHEN sl.stage = 'reserve_accepted' THEN '4. Fuera de TC'
        WHEN sl.stage = 'sold' THEN '4. Fuera de TC'
        WHEN sl.stage = 'closed' THEN '0. Closed'
        ELSE NULL
    END as selling_lead_stage,

    timezone('America/Buenos_Aires', oc.created_at) AS sl_creation_date,

    auth_user.username AS tc_name

FROM accounts_sellinglead sl

    LEFT JOIN accounts_opportunitycase oc
        ON oc.id = sl.opportunitycase_ptr_id
    LEFT JOIN accounts_clientprofile cp
        ON cp.profile_ptr_id = oc.client_id
    LEFT JOIN accounts_profile tc_profile_task 
        ON tc_profile_task.id = cp.assignee_id
    LEFT JOIN auth_user
        ON auth_user.id = tc_profile_task.user_id
    
WHERE
    (auth_user.username = 'martina' OR auth_user.username = 'estefania')