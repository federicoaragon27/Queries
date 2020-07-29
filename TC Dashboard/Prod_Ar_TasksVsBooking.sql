SELECT 
    task.id as task_id,
    booking.id as booking_id,
    oc.id as case_id,

   CASE
    	WHEN (timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND (timezone('America/Buenos_Aires',task.completion_date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') THEN task.id
        ELSE NULL
    END as contacted,

    CASE
    	WHEN (timezone('America/Buenos_Aires',booking.created_at) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND (timezone('America/Buenos_Aires',booking.created_at) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') AND (booking.kind = 'appraisal') AND (auth_user.username = booking_user.username) THEN booking.id
        ELSE NULL
    END as booked,

   CASE
    	WHEN (timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND (timezone('America/Buenos_Aires',task.completion_date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') THEN oc.id
        ELSE NULL
    END as lead_contacted,

    CASE
    	WHEN (timezone('America/Buenos_Aires',booking.created_at) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND (timezone('America/Buenos_Aires',booking.created_at) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') AND (booking.kind = 'appraisal') AND (auth_user.username = booking_user.username) THEN oc.id
        ELSE NULL
    END as lead_booked,

<<<<<<< HEAD
    uth_user.username as assignee_agent_name,
=======
    auth_user.username as assignee_agent_name,
>>>>>>> master
    booking_user.username as booking_agent_name,
    oc.urgency

FROM tasks_task task
  
<<<<<<< HEAD
  LEFT JOIN bookings_booking booking
    ON task.prop_id = booking.prop_id
  LEFT JOIN accounts_sellinglead sl
    ON task.prop_id = sl.prop_id
  LEFT JOIN accounts_opportunitycase oc
    ON sl.opportunitycase_ptr_id = oc.id
  LEFT JOIN accounts_profile accprofile
    ON task.assignee_id = accprofile.id
  LEFT JOIN auth_user
    ON accprofile.user_id = auth_user.id
  LEFT JOIN accounts_profile bookprofile
    ON booking.booked_by_id = bookprofile.id
  LEFT JOIN auth_user booking_user
    ON bookprofile.user_id = booking_user.id
=======
    LEFT JOIN bookings_booking booking
        ON task.prop_id = booking.prop_id
    LEFT JOIN accounts_sellinglead sl
        ON task.prop_id = sl.prop_id
    LEFT JOIN accounts_opportunitycase oc
        ON sl.opportunitycase_ptr_id = oc.id
    LEFT JOIN accounts_profile accprofile
        ON task.assignee_id = accprofile.id
    LEFT JOIN auth_user
        ON accprofile.user_id = auth_user.id
    LEFT JOIN accounts_profile bookprofile
        ON booking.booked_by_id = bookprofile.id
    LEFT JOIN auth_user booking_user
        ON bookprofile.user_id = booking_user.id
>>>>>>> master

WHERE
    (auth_user.username = 'martina' OR auth_user.username = 'estefania' OR auth_user.username = 'flavia') AND
    (task.kind = 'first_contact' OR task.kind = 'retry_first_contact' OR task.kind = 'follow_up' OR task.kind = 'book_visit')