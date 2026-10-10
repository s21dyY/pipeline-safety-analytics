{{ config(materialized='table') }}

with source as (
    select * from {{ source('phmsa', 'gd_incidents') }}
),

renamed as (

    select
        report_number,
        operator_id,
        trim(name)                                              as operator_name,
        try_to_date(report_received_date, 'MM/DD/YYYY')         as report_received_date,
        try_to_timestamp_ntz(local_datetime, 'MM/DD/YYYY HH24:MI')   as incident_at,
        coalesce(try_to_number(fatal), 0)    as fatalities,
        coalesce(try_to_number(injure), 0)   as injuries,
        
        coalesce(try_to_number(EST_COST_PROP_DAMAGE), 0) + 
        coalesce(try_to_number(EST_COST_OPER_PAID), 0) +
        coalesce(try_to_number(EST_COST_EMERGENCY), 0) +
        coalesce(try_to_number(EST_COST_OTHER), 0) + 
        coalesce(try_to_number(EST_COST_INTENTIONAL_RELEASE), 0)  +
        coalesce(try_to_number(EST_COST_UNINTENTIONAL_RELEASE), 0) as tot_cost_usd
    from source

)
select * from renamed