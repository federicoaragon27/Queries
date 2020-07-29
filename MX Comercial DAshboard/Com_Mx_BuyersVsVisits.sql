SELECT 
    bl.opportunitycase_ptr_id as case_id,
<<<<<<< HEAD
    bl.prop_id,bl.chance_ac,
=======
    bl.prop_id,
    bl.chance_ac,
>>>>>>> master
    (timezone('America/Mexico_City',oc.created_at))::date as case_creation_date,
    cp.profile_ptr_id as buyer_id,
    cp.buying_stage,
    pp.country as prop_country,
    bb.id as booking_id,
    (timezone('America/Mexico_City',bb.created_at))::date as booking_creation_date,
    (timezone('America/Mexico_City',bb.date))::date as booking_due_date,
    bb.kind,
    bb.result,
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
    END as buying_stages,

    CASE
        WHEN bl.stage = 'visited' THEN cp.profile_ptr_id
        WHEN bl.stage = 'reserved' THEN cp.profile_ptr_id
        WHEN bl.stage = 'reserve_accepted' THEN cp.profile_ptr_id
        WHEN bl.stage = 'sold' THEN cp.profile_ptr_id
        ELSE NULL
    END as visited_id

FROM accounts_buyinglead bl

    LEFT JOIN accounts_opportunitycase oc
        ON bl.opportunitycase_ptr_id = oc.id
    LEFT JOIN accounts_clientprofile cp
        ON oc.client_id = cp.profile_ptr_id
    LEFT JOIN properties_property pp
        ON bl.prop_id = pp.id
    LEFT JOIN bookings_booking bb
        ON oc.id = bb.case_id
    LEFT JOIN accounts_profile acprofile
        ON cp.assignee_id = acprofile.id
    LEFT JOIN auth_user user_ac
        ON acprofile.user_id = user_ac.id