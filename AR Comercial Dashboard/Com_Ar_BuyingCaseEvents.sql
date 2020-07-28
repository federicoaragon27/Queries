SELECT ee.id event_id,oc.id as case_id, bce.kind as buying_case_kind, 
ee.created_at::date as event_creation_date, usa.id, usa.first_name,
CASE
WHEN bce.kind = 'reserved' THEN oc.id
ELSE NULL
END as reserved_id,
CASE
WHEN bce.kind = 'signed' THEN oc.id
ELSE NULL
END as sold_id,
oc.country

FROM events_buyingcaseevent bce
LEFT JOIN events_event ee 
   ON ee.id = bce.event_ptr_id
LEFT JOIN accounts_opportunitycase oc
   ON oc.id = ee.opportunity_case_id
LEFT JOIN accounts_buyinglead bl
   ON bl.opportunitycase_ptr_id = oc.id
LEFT JOIN accounts_profile aprof
   ON aprof.id = oc.agent_id
LEFT JOIN auth_user usa
   ON usa.id = aprof.user_id
LEFT JOIN accounts_clientprofile cprof_info
   ON cprof_info.profile_ptr_id = oc.client_id
LEFT JOIN accounts_profile cprof
   ON cprof.id = cprof_info.profile_ptr_id 
LEFT JOIN auth_user usc
   ON usc.id = cprof.user_id