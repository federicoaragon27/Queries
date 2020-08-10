SELECT 
    oc.id AS bl_case_id,
    bl.prop_id AS prop_id,
    timezone('America/Buenos_Aires', oc.created_at) AS bl_case_creation
    eqe.origin AS mkt_source

FROM events_questionevent eqe

    LEFT JOIN events_event ee
        ON ee.id = eqe.event_ptr_id
    INNER JOIN accounts_opportunitycase oc
        ON oc.id = ee.opportunity_case_id
    INNER JOIN accounts_buyinglead bl
        ON bl.opportunitycase_ptr_id = oc.id