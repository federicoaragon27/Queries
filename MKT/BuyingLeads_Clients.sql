SELECT 
    MAX(timezone('America/Buenos_Aires',bb.date))::date AS last_visit_date, 
    client_user.first_name AS nombre_usuario,
    client_user.email AS email_usuario
    
FROM accounts_buyinglead bl

    LEFT JOIN accounts_opportunitycase oc
        ON oc.id = bl.opportunitycase_ptr_id
    LEFT JOIN accounts_clientprofile cp
        ON cp.profile_ptr_id = oc.client_id
    LEFT JOIN accounts_profile prof
        ON prof.id = cp.profile_ptr_id
    LEFT JOIN auth_user client_user
        ON client_user.id = prof.user_id
    LEFT JOIN bookings_booking bb
        ON bb.case_id = oc.id

WHERE
    timezone('America/Buenos_Aires', bb.date)::date >= timezone('America/Buenos_Aires', current_timestamp)::date - INTERVAL '60 days' AND
    oc.country = 'AR' AND
    bb.kind = 'visit' AND bb.result = 'successful'

GROUP BY
    client_user.first_name, 
    client_user.email

ORDER BY last_visit_date DESC