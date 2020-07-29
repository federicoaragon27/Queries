<<<<<<< HEAD
SELECT 
=======
SELECT
>>>>>>> master
    table1.buyer_id,
    table1.buyer_creation_date,
    table1.country,
    table1.agent_name,
    table1.visited_id,

    CASE
        WHEN bb.kind='visit' AND bb.result = 'successful' THEN bb.id
        ELSE NULL
    END as book_visit_id
<<<<<<< HEAD

FROM
    (SELECT
        cp.profile_ptr_id as buyer_id,
        MIN(timezone('America/Buenos_Aires',oc.created_at)::date) as buyer_creation_date,
        oc.country,
        user_ac.username as agent_name,

        CASE
            WHEN cp.buying_stage = 'visited' THEN cp.profile_ptr_id
            WHEN cp.buying_stage = 'reserved' THEN cp.profile_ptr_id
            WHEN cp.buying_stage = 'reserve_accepted' THEN cp.profile_ptr_id
            WHEN cp.buying_stage = 'sold' THEN cp.profile_ptr_id
            ELSE NULL
        END as visited_id

    FROM accounts_buyinglead bl
        
        LEFT JOIN accounts_opportunitycase oc
            ON bl.opportunitycase_ptr_id = oc.id
        LEFT JOIN accounts_clientprofile cp
            ON oc.client_id = cp.profile_ptr_id
        LEFT JOIN accounts_profile acprofile
            ON cp.assignee_id = acprofile.id
        LEFT JOIN auth_user user_ac
            ON acprofile.user_id = user_ac.id
    
=======

FROM (SELECT
        cp.profile_ptr_id as buyer_id,
        MIN(timezone('America/Buenos_Aires',oc.created_at)::date) as buyer_creation_date,
        oc.country,
        user_ac.username as agent_name,

        CASE
            WHEN cp.buying_stage = 'visited' THEN cp.profile_ptr_id
            WHEN cp.buying_stage = 'reserved' THEN cp.profile_ptr_id
            WHEN cp.buying_stage = 'reserve_accepted' THEN cp.profile_ptr_id
            WHEN cp.buying_stage = 'sold' THEN cp.profile_ptr_id
            ELSE NULL
        END as visited_id

    FROM accounts_buyinglead bl

        LEFT JOIN accounts_opportunitycase oc
            ON bl.opportunitycase_ptr_id = oc.id
        LEFT JOIN accounts_clientprofile cp
            ON oc.client_id = cp.profile_ptr_id
        LEFT JOIN accounts_profile acprofile
            ON cp.assignee_id = acprofile.id
        LEFT JOIN auth_user user_ac
            ON acprofile.user_id = user_ac.id

>>>>>>> master
    GROUP BY cp.profile_ptr_id, oc.country, user_ac.username) as table1

    LEFT JOIN bookings_booking bb
        ON table1.buyer_id = bb.client_id