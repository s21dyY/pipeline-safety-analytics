{{ config(materialized='table') }}

with source as (
    select * from {{ source('phmsa', 'gd_incidents') }}
),

renamed as (

    select
        report_number,
        try_to_date(report_received_date, 'MM/DD/YYYY') as report_received_date

    from source

)
select * from renamed