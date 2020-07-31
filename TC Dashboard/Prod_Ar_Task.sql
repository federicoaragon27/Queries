SELECT 
    task.id as task_id,

	CASE
    	WHEN 
            (timezone('America/Buenos_Aires',task.deadline_date) <= timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.completion_date) IS NULL OR timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours')
            THEN 1
        WHEN 
            (timezone('America/Buenos_Aires',task.deadline_date) IS NULL) AND
            (timezone('America/Buenos_Aires',task.creation_date) <= timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.completion_date) IS NULL OR timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours')
            THEN 1
        ELSE 0
    END as stock_beginning,

	CASE
    	WHEN
            (timezone('America/Buenos_Aires',task.deadline_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.deadline_date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.completion_date) IS NULL OR timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') 
            THEN 1
        WHEN
            (timezone('America/Buenos_Aires',task.deadline_date) IS NULL) AND
            (timezone('America/Buenos_Aires',task.creation_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.creation_date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') 
            THEN 1
    	WHEN
            (timezone('America/Buenos_Aires',task.deadline_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.deadline_date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.completion_date) <= timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours')
            THEN 0
    	WHEN 
            (timezone('America/Buenos_Aires',task.deadline_date) > timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.completion_date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours')
            THEN 1
        ELSE 0
    END as born,

	CASE
    	WHEN 
            (timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '1 day' + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.completion_date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours')
            THEN 1
        ELSE 0
    END as contacted,

	CASE
    	WHEN
            (timezone('America/Buenos_Aires',task.deadline_date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.completion_date) IS NULL OR timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours')
            THEN 1
        WHEN
            (timezone('America/Buenos_Aires',task.deadline_date) IS NULL) AND
            (timezone('America/Buenos_Aires',task.creation_date) <= timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours') AND
            (timezone('America/Buenos_Aires',task.completion_date) IS NULL OR timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date + INTERVAL '19 hours')
            THEN 1
        ELSE 0
    END as stock_ending,

    CASE
    	WHEN (task.kind = 'first_contact') THEN '1. First Contact'
        WHEN (task.kind = 'retry_first_contact') THEN '2. Retry First Contact'
        WHEN (task.kind = 'follow_up') THEN '3. Follow Up'
        WHEN (task.kind = 'book_visit') THEN '4. Interested Follow Up'
        ELSE ''
    END as task_kind_custom,

    CASE
    	WHEN (timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '7 days') THEN 0.2
        ELSE 0
    END as weekly_workload,

	CASE
    	WHEN (timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '30 days') THEN 0.045
        ELSE 0
    END as monthly_workload,
    
	CASE
    	WHEN (timezone('America/Buenos_Aires',task.completion_date) > timezone('America/Buenos_Aires',current_timestamp)::date - INTERVAL '90 days') THEN 0.015
        ELSE 0
    END as quarterly_workload,

    timezone('America/Buenos_Aires',task.creation_date)::date as creation_date_custom,
    timezone('America/Buenos_Aires',task.deadline_date)::date as deadline_date_custom,
    timezone('America/Buenos_Aires',task.completion_date)::date as completion_date_custom,
    timezone('America/Buenos_Aires',current_timestamp)::date as today,

    task.kind as task_kind,
    auth_user.username as assignee_agent_name,
    clprofile.stage as client_stage,
    clprofile.new,
    oc.urgency,
    oc."chance_AP",
    oc."chance_TC"

FROM tasks_task task
  
    LEFT JOIN accounts_profile accprofile
        ON task.assignee_id = accprofile.id
    LEFT JOIN auth_user
        ON accprofile.user_id = auth_user.id 
    LEFT JOIN accounts_sellinglead sl
        ON task.prop_id = sl.prop_id
    LEFT JOIN accounts_opportunitycase oc
        ON sl.opportunitycase_ptr_id = oc.id
    LEFT JOIN accounts_clientprofile clprofile
        ON task.client_id = clprofile.profile_ptr_id

GROUP BY
    task.id,
    clprofile.stage,
    clprofile.new,
    oc.urgency,
    assignee_agent_name,
    oc."chance_AP",
    oc."chance_TC"