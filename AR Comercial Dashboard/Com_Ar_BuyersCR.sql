SELECT 
	buyer_id,
	lead_date,
	visited_date,
	country,

	CASE
		WHEN (EXTRACT(WEEK FROM lead_date) = EXTRACT(WEEK FROM visited_date)) AND (EXTRACT(YEAR FROM lead_date) = EXTRACT(YEAR FROM visited_date)) THEN 1
		ELSE 0
	END as cr_to_visited_s1,

	CASE
		WHEN (EXTRACT(WEEK FROM visited_date) - EXTRACT(WEEK FROM lead_date) <= 1) AND (EXTRACT(YEAR FROM visited_date) = EXTRACT(YEAR FROM lead_date)) THEN 1
		WHEN (EXTRACT(WEEK FROM visited_date) + 52) - EXTRACT(WEEK FROM lead_date) <= 1 AND (EXTRACT(YEAR FROM visited_date) - EXTRACT(YEAR FROM lead_date) = 1) THEN 1
		ELSE 0
	END as cr_to_visited_s2,

	CASE
		WHEN (EXTRACT(WEEK FROM visited_date) - EXTRACT(WEEK FROM lead_date) <= 2) AND (EXTRACT(YEAR FROM visited_date) = EXTRACT(YEAR FROM lead_date)) THEN 1
		WHEN (EXTRACT(WEEK FROM visited_date) + 52) - EXTRACT(WEEK FROM lead_date) <= 2 AND (EXTRACT(YEAR FROM visited_date) - EXTRACT(YEAR FROM lead_date) = 1) THEN 1
		ELSE 0
	END as cr_to_visited_s3,

	CASE
		WHEN (EXTRACT(WEEK FROM visited_date) - EXTRACT(WEEK FROM lead_date) <= 3) AND (EXTRACT(YEAR FROM visited_date) = EXTRACT(YEAR FROM lead_date)) THEN 1
		WHEN (EXTRACT(WEEK FROM visited_date) + 52) - EXTRACT(WEEK FROM lead_date) <= 3 AND (EXTRACT(YEAR FROM visited_date) - EXTRACT(YEAR FROM lead_date) = 1) THEN 1
		ELSE 0
	END as cr_to_visited_s4,

	CASE
		WHEN (EXTRACT(WEEK FROM visited_date) - EXTRACT(WEEK FROM lead_date) <= 4) AND (EXTRACT(YEAR FROM visited_date) = EXTRACT(YEAR FROM lead_date)) THEN 1
		WHEN (EXTRACT(WEEK FROM visited_date) + 52) - EXTRACT(WEEK FROM lead_date) <= 4 AND (EXTRACT(YEAR FROM visited_date) - EXTRACT(YEAR FROM lead_date) = 1) THEN 1
		ELSE 0
	END as cr_to_visited_s5,

	CASE
		WHEN (EXTRACT(WEEK FROM visited_date) - EXTRACT(WEEK FROM lead_date) <= 5) AND (EXTRACT(YEAR FROM visited_date) = EXTRACT(YEAR FROM lead_date)) THEN 1
		WHEN (EXTRACT(WEEK FROM visited_date) + 52) - EXTRACT(WEEK FROM lead_date) <= 5 AND (EXTRACT(YEAR FROM visited_date) - EXTRACT(YEAR FROM lead_date) = 1) THEN 1
		ELSE 0
	END as cr_to_visited_s6

FROM(
	SELECT 
		oc.client_id as buyer_id,
		oc.country,
<<<<<<< HEAD
		min(timezone('America/Buenos_Aires',oc.created_at))::date as lead_date,
  
  		min(CASE
=======
		MIN(timezone('America/Buenos_Aires',oc.created_at))::date as lead_date,
  		MIN(CASE
>>>>>>> master
    			WHEN bb.kind = 'visit' AND bb.result = 'successful' THEN timezone('America/Buenos_Aires',bb.date)::date
        		ELSE NULL
    		END) as visited_date
  
	FROM accounts_buyinglead bl

        LEFT JOIN accounts_opportunitycase oc
			ON bl.opportunitycase_ptr_id = oc.id
		LEFT JOIN bookings_booking bb
			ON oc.id = bb.case_id

	GROUP BY oc.client_id, oc.country) as funnel_stage_table