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
        try_to_timestamp_ntz(local_datetime, 'MM/DD/YYYY HH24:MI')   as incident_at

    from source

)
select * from renamed