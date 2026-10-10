-- FATAL should equal the sum of fatalities by person type.
-- Returns the rows where it doesn't. Zero rows = pass.

select
    report_number,
    coalesce(try_to_number(fatal), 0)    as fatalities,
    coalesce(try_to_number(injure), 0)   as injuries,
from {{ source('phmsa', 'gd_incidents') }}
where coalesce(try_to_number(fatalities), 0) !=
      coalesce(try_to_number(num_emp_fatalities), 0)
    + coalesce(try_to_number(num_contr_fatalities), 0)
    + coalesce(try_to_number(num_er_fatalities), 0)
    + coalesce(try_to_number(num_worker_fatalities), 0)
   + coalesce(try_to_number(num_gp_fatalities), 0) 
   or
   coalesce(try_to_number(injuries), 0) !=
      coalesce(try_to_number(num_emp_injuries), 0)
    + coalesce(try_to_number(num_contr_injuries), 0)
    + coalesce(try_to_number(num_er_injuries), 0)
    + coalesce(try_to_number(num_worker_injuries), 0)
   + coalesce(try_to_number(num_gp_injuries), 0)
