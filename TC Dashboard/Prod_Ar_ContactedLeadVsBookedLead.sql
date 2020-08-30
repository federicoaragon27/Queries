SELECT
    
    custom_pivot.selling_case_id,
    tc_user_book.username as task_responsable,
    tc_user_task_responsable.username as booker,
    oc_sec.urgency as intention,
    timezone('America/Buenos_Aires', bb_sec.created_at) as booking_date,
    timezone('America/Buenos_Aires', custom_pivot.first_booking_date) as first_booking_date,

    CASE
        WHEN 
            (
                (timezone('America/Buenos_Aires', tt.completion_date) >= timezone('America/Buenos_Aires', current_timestamp)::date - INTERVAL '5 hours') AND
                (timezone('America/Buenos_Aires', tt.completion_date) < timezone('America/Buenos_Aires', current_timestamp)::date + INTERVAL '19 hours')
            ) AND 
            (
                (
                    (timezone('America/Buenos_Aires', custom_pivot.first_booking_date) >= timezone('America/Buenos_Aires', current_timestamp)::date - INTERVAL '5 hours') AND
                    (timezone('America/Buenos_Aires', custom_pivot.first_booking_date) < timezone('America/Buenos_Aires', current_timestamp)::date + INTERVAL '19 hours')
                ) OR
                (custom_pivot.first_booking_date IS NULL)
            )
            THEN custom_pivot.selling_case_id
        ELSE NULL
    END as lead_contacted,
    
    CASE
        WHEN 
        (
            (timezone('America/Buenos_Aires', bb_sec.created_at) >= timezone('America/Buenos_Aires', current_timestamp)::date - INTERVAL '5 hours') AND
            (timezone('America/Buenos_Aires', bb_sec.created_at) < timezone('America/Buenos_Aires', current_timestamp)::date + INTERVAL '19 hours') 
        ) AND
            timezone('America/Buenos_Aires',custom_pivot.first_booking_date)::date = timezone('America/Buenos_Aires', current_timestamp)::date
          AND 
        (
            tc_user_book.username = tc_user_task_responsable.username 
        )
        THEN custom_pivot.selling_case_id
        ELSE NULL
    END as lead_booked

FROM tasks_task tt
    
    LEFT JOIN (SELECT
                    oc.id AS selling_case_id,
                    sl.prop_id AS property_id,
                    MIN(bb.created_at) AS first_booking_date,
                    MIN(bb.id) as booking_id

                FROM accounts_sellinglead sl

                    LEFT JOIN accounts_opportunitycase oc
                        ON oc.id = sl.opportunitycase_ptr_id
                    LEFT JOIN bookings_booking bb
                        ON bb.case_id = oc.id
    
                WHERE
                    bb.kind = 'appraisal'

                GROUP BY 
                oc.id,
                sl.prop_id

                ) AS custom_pivot
        ON custom_pivot.property_id = tt.prop_id

    LEFT JOIN bookings_booking bb_sec
        ON bb_sec.id = custom_pivot.booking_id
    LEFT JOIN accounts_profile prof_booker_book_by
        ON prof_booker_book_by.id = bb_sec.booked_by_id
    LEFT JOIN auth_user tc_user_book
        ON tc_user_book.id = prof_booker_book_by.user_id
    LEFT JOIN accounts_profile prof_task_responsable
        ON prof_task_responsable.id = tt.completed_by_id
    LEFT JOIN auth_user tc_user_task_responsable
        ON tc_user_task_responsable.id = prof_task_responsable.user_id
    LEFT JOIN accounts_opportunitycase oc_sec
        ON oc_sec.id = custom_pivot.selling_case_id
                
WHERE
    (tc_user_task_responsable.username = 'estefania' OR tc_user_task_responsable.username = 'martina' OR tc_user_task_responsable.username IS NULL) AND
    (tt.kind = 'first_contact' OR tt.kind = 'retry_first_contact' OR tt.kind = 'follow_up' OR tt.kind = 'book_visit')
    
