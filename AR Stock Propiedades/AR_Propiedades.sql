SELECT
    /*Datos propiedad*/    
    pp.id AS prop_id,
    pp.address AS direccion,
    
        /*Barrio*/
    p_loc.short_name AS barrio,

        /*Valuacion*/
    pp.currency AS moneda,
    
    
    pp.pixel_plus as pixel_plus,

    pp.price AS precio_publicacion,
    pp.valuation_price AS precio_valuacion,
    pp.coordinates as coordenadas,

    /*Usuarios de asesores*/
    ac_user.username AS usuario_ac,
    ap_user.username AS usuario_ap,
    
    /*Datos del buying lead*/
    table_buyleads_channel.bl_case_id AS bl_id,
    table_buyleads_channel.bl_case_creation AS fecha_buying_lead,
    
    CASE
        WHEN table_buyleads_channel.origin = 'already_client' THEN 'Cliente antiguo'
        WHEN table_buyleads_channel.origin = 'friend' THEN 'Referido de amigo'
        WHEN table_buyleads_channel.origin = 'Landing' THEN 'Landing'
        WHEN table_buyleads_channel.origin = 'MercadoLibre' THEN 'Mercado Libre'
        WHEN table_buyleads_channel.origin = 'property_post' THEN 'Landing'
        WHEN table_buyleads_channel.origin = 'refered_by_client' THEN 'Referido por cliente'
        WHEN table_buyleads_channel.origin = 'retro' THEN 'Retro'
        WHEN table_buyleads_channel.origin = 'Smith' THEN 'Smith'
        WHEN table_buyleads_channel.origin = 'social_media' THEN 'Redes sociales'
        WHEN table_buyleads_channel.origin = 'Zonaprop' THEN 'Zonaprop'
        WHEN table_buyleads_channel.origin = 'other' THEN 'Otro'
        ELSE NULL
    END AS mkt_source

FROM properties_property pp

    /*Vinculo el asesor comercial y su usuario en Smith*/
    LEFT JOIN properties_location p_loc
        ON p_loc.id = pp.location_id
    /*Vinculo el asesor comercial y su usuario en Smith*/
    LEFT JOIN accounts_profile ac_profile
        ON ac_profile.id = pp.commercial_agent_id
    LEFT JOIN auth_user ac_user
        ON ac_user.id = ac_profile.user_id
    /*Vinculo los buying leads para conocer las consultas*/
    LEFT JOIN (
        SELECT 
            oc.id AS bl_case_id,
            bl.prop_id AS prop_id,
            timezone('America/Buenos_Aires', oc.created_at) AS bl_case_creation,
            eqe.origin AS origin

        FROM events_questionevent eqe

            LEFT JOIN events_event ee
                ON ee.id = eqe.event_ptr_id
            INNER JOIN accounts_opportunitycase oc
                ON oc.id = ee.opportunity_case_id
            INNER JOIN accounts_buyinglead bl
                ON bl.opportunitycase_ptr_id = oc.id

    ) AS table_buyleads_channel
        ON pp.id = table_buyleads_channel.prop_id  
    /*Vinculo el cliente de la propiedad para a través del client profile traerme el agente productor*/
    LEFT JOIN (
        SELECT
            bb.prop_id AS prop_id,
            bb.completed_by_id AS ap_profile_id

        FROM bookings_booking bb
            LEFT JOIN accounts_opportunitycase oc
                ON oc.id = bb.case_id

        WHERE bb.kind = 'appraisal' AND bb.result = 'successful'

    ) AS table_productores
        ON pp.id = table_productores.prop_id
    LEFT JOIN accounts_profile ap_profile
        ON ap_profile.id = table_productores.ap_profile_id
    LEFT JOIN auth_user ap_user
        ON ap_user.id = ap_profile.user_id
WHERE 
    pp.country = 'AR' AND
    pp.operation_status = 'active' AND
    pp.price IS NOT NULL