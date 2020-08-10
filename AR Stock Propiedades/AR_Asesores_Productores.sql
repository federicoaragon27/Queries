SELECT
    bb.prop_id AS prop_id,
    bb.completed_by_id AS ap_profile_id

FROM bookings_booking bb
    LEFT JOIN accounts_opportunitycase oc
        oc.id = bb.case_id

WHERE bb.kind = 'appraisal' AND bb.result = 'successful' 