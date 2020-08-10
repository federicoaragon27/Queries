SELECT 
    sl.opportunitycase_ptr_id as case_id,
    sl.prop_id,
    oc."chance_AP" as chance_ap_custom,
    (timezone('America/Buenos_Aires',oc.created_at))::date as case_creation_date,
    cp.profile_ptr_id as seller_id,
    cp.stage,
    pp.country as prop_country,
    bb.id as booking_id,
    (timezone('America/Buenos_Aires',bb.created_at))::date as booking_creation_date,
    (timezone('America/Buenos_Aires',bb.date))::date as booking_due_date,
    bb.kind,
    bb.result,
    user_ap.username as agent_name,
  
    CASE
        WHEN sl.stage = 'unreached' THEN '1. Unreached'
        WHEN sl.stage = 'pitched' THEN '2. Pitched'
        WHEN sl.stage = 'scheduled' THEN '3. Scheduled'
        WHEN sl.stage = 'proposal_made' THEN '4. Proposal Made'
        WHEN sl.stage = 'listed' THEN '5. Listed'
        WHEN sl.stage = 'consulted' THEN '6. Consulted'
        WHEN sl.stage = 'reserved' THEN '7. Reserved'
        WHEN sl.stage = 'reserve_accepted' THEN '8. Reserve Accepted'
        WHEN sl.stage = 'sold' THEN '9. Sold'
        WHEN sl.stage = 'closed' THEN '0. Closed'
        ELSE NULL
    END as selling_stages,

    CASE
        WHEN sl.stage = 'listed' THEN sl.opportunitycase_ptr_id
        WHEN sl.stage = 'consulted' THEN sl.opportunitycase_ptr_id
        WHEN sl.stage = 'reserved' THEN sl.opportunitycase_ptr_id
        WHEN sl.stage = 'reserve_accepted' THEN sl.opportunitycase_ptr_id
        WHEN sl.stage = 'sold' THEN sl.opportunitycase_ptr_id
        ELSE NULL
    END as listed_id

FROM accounts_sellinglead sl

    LEFT JOIN accounts_opportunitycase oc
        ON sl.opportunitycase_ptr_id = oc.id
    LEFT JOIN accounts_clientprofile cp
        ON oc.client_id = cp.profile_ptr_id
    LEFT JOIN properties_property pp
        ON sl.prop_id = pp.id
    LEFT JOIN bookings_booking bb
        ON oc.id = bb.case_id
    LEFT JOIN accounts_profile acprofile
        ON cp.assignee_id = acprofile.id
    LEFT JOIN auth_user user_ap
        ON acprofile.user_id = user_ap.id