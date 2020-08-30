SELECT 
  bb.id as booking_id,
  bb.result,
  bb.kind,
  (timezone('America/Buenos_Aires',bb.date))::date as booking_date,
  bb.booked_by_id,
  bb.case_id,
  bb.client_id,
  bb.performed_by_id,
  (timezone('America/Buenos_Aires',bb.created_at))::date as booking_creation_date,
  bb.completed_by_id,
  bb.completion_time,
  pp.address,
  pp.country,
  oc."chance_AP" as chance_ap_custom,
  oc."chance_TC" as chance_tc_custom,
  oc.urgency,
  (timezone('America/Buenos_Aires',oc.created_at))::date as case_creation_date,
  user_tc.username as tc_asignee_name,
  user_ap.username as ap_asignee_name,

  CASE
	  WHEN /*Agendado para hoy o mas adelante Y creado antes que hoy*/
      (timezone('America/Buenos_Aires',bb.date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '5 hours') AND
      (timezone('America/Buenos_Aires',bb.created_at) <= timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '5 hours')
      THEN 1
		ELSE 0
  END as initial_stock,

  CASE
		WHEN /*La creacion del booking es hoy*/
      (
        timezone('America/Buenos_Aires',bb.created_at) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '5 hours' AND
        timezone('America/Buenos_Aires',bb.created_at) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours'
      )
      THEN 1
		ELSE 0
  END as booked_today,

  CASE
	    WHEN /*El booking fue creado para que se realice hoy*/
      (
        timezone('America/Buenos_Aires',bb.date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '5 hours' AND
        timezone('America/Buenos_Aires',bb.date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours'
      )
      THEN 1
		ELSE 0
  END as due_today,

  CASE
		WHEN /*Agendado para manana o mas adelante Y creado hoy o antes*/ 
      (timezone('America/Buenos_Aires',bb.date) > timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') AND
      (timezone('America/Buenos_Aires',bb.created_at) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours')
      THEN 1
		ELSE 0
  END as final_stock,
    
  CASE
    WHEN (oc."chance_TC" = 'high') THEN 1
    ELSE 0
  END as high_chance_tc,

  CASE
    WHEN (oc."chance_AP" = 'high') THEN 1
    ELSE 0
  END as high_chance_ap,

  CASE
    WHEN (oc."chance_AP" = 'high') AND (oc."chance_TC" = 'high') THEN 1
    ELSE 0
  END as actual_high_chance_tc_ap_coincidence,
    
  CASE
    WHEN (bb.result = 'successful') THEN '1. Visited'
    WHEN (bb.result = 'agent_reschedule') THEN '2. Rescheduled'
    WHEN (bb.result = 'reschedule') THEN '2. Rescheduled'
    WHEN (bb.result = 'changed_funnel') THEN '3. Canceled'
    WHEN (bb.result = 'closed') THEN '3. Canceled'
    WHEN (bb.result = 'no_answer') THEN '3. Canceled'
    WHEN (bb.result = 'turned_down') THEN '3. Canceled'
    ELSE '4. No Result'
  END as booking_result_type,
    
  CASE
    WHEN
      (timezone('America/Buenos_Aires',bb.date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '8 days' + INTERVAL '19 hours') AND
      (timezone('America/Buenos_Aires',bb.date) <= timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '5 hours')
      THEN 1
    ELSE 0
  END as stock_last_week,

	CASE
    WHEN 
      (timezone('America/Buenos_Aires',bb.date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '7 days' + INTERVAL '19 hours') AND
      (timezone('America/Buenos_Aires',bb.date) > timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours')
      THEN 1
    ELSE 0
  END as stock_next_week

FROM bookings_booking bb

  LEFT JOIN accounts_opportunitycase oc
    ON oc.id = bb.case_id
  LEFT JOIN properties_property pp
    ON pp.id = bb.prop_id 
  LEFT JOIN accounts_profile profile_tc
    ON profile_tc.id = bb.booked_by_id  
  LEFT JOIN auth_user user_tc
    ON user_tc.id = profile_tc.user_id
  LEFT JOIN accounts_profile profile_ap
    ON profile_ap.id = bb.performed_by_id
  LEFT JOIN auth_user user_ap
    ON user_ap.id = profile_ap.user_id 
  
WHERE
  (user_tc.username = 'estefania' OR user_tc.username = 'martina') 
  