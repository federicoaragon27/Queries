SELECT 
    pp.id as prop_id,
    pp.country,
    MIN(
        CASE
          WHEN pe.kind = 'listed' THEN ee.created_at::date
          ELSE NULL
        END) as listed_date

FROM properties_property pp

    LEFT JOIN events_event ee
        ON pp.id = ee.prop_id
    LEFT JOIN events_propertyevent pe
        ON ee.id = pe.event_ptr_id
  
GROUP BY pp.id