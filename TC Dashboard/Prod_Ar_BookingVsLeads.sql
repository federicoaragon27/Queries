SELECT 
	lead_table.case_id,
	lead_table.booking_counter,
	lead_table.last_booking_date,
	lead_table.last_contact_date,

    CASE
    	WHEN /*El ultimo booking para este caso se programo hoy*/
			(
				lead_table.last_booking_date > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '5 hours' AND
				lead_table.last_booking_date <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours'
			)
			THEN lead_table.case_id
        ELSE NULL
    END as booked_today,

	CASE
    	WHEN /*El ultimo contacto para este caso se programo hoy*/
			(
				lead_table.last_contact_date > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '5 hours' AND
				lead_table.last_contact_date <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours' 
			)
			THEN lead_table.case_id
        ELSE NULL
    END as contacted_today,

    CASE
    	WHEN (user_tc.username = 'martina' OR user_tc.username = 'estefania' OR user_tc.username = 'flavia') THEN 'YES'
        ELSE 'NO'
    END as contacted_by_tc,

	user_tc.username as tc_agent_name

FROM (SELECT
		oc.id as case_id,
		COUNT(DISTINCT bb.id) as booking_counter,

		MAX(CASE
    			WHEN (bb.kind = 'appraisal') THEN timezone('America/Buenos_Aires',bb.created_at)
        		ELSE NULL
    		END) as last_booking_date,

    	CASE
    		WHEN ((tt.kind = 'first_contact') OR (tt.kind = 'retry_first_contact') OR (tt.kind = 'follow_up') OR (tt.kind = 'book_visit')) THEN tt.completed_by_id
        	ELSE NULL
    	END as contacted_by_id,

		MAX(	CASE
    		WHEN ((tt.kind = 'first_contact') OR (tt.kind = 'retry_first_contact') OR (tt.kind = 'follow_up') OR (tt.kind = 'book_visit')) THEN timezone('America/Buenos_Aires',tt.completion_date)
        	ELSE NULL
    	END) as last_contact_date

	FROM accounts_sellinglead sl

		LEFT JOIN accounts_opportunitycase oc
			ON sl.opportunitycase_ptr_id = oc.id
		LEFT JOIN bookings_booking bb
			ON oc.id = bb.case_id
		LEFT JOIN tasks_task tt
			ON oc.client_id = tt.client_id

	GROUP BY oc.id, tt.kind, tt.completed_by_id) as lead_table

	LEFT JOIN accounts_profile profile_tc
		ON lead_table.contacted_by_id = profile_tc.id
	LEFT JOIN auth_user user_tc
		ON profile_tc.user_id = user_tc.id

WHERE (user_tc.username = 'estefania' OR user_tc.username = 'martina' OR user_tc.username = 'flavia')
