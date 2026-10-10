use role accountadmin;

-- Create role: transformer
create role if not exists transformer;
grant role transformer to role sysadmin;

-- Create warehouse
create warehouse if not exists dbt_pipeline_wh
    warehouse_size = 'XSMALL'
    auto_suspend = 60
    auto_resume = TRUE
    initially_suspended = TRUE;

-- Stroage
create database if not exists raw;
create schema if not exists raw.phmsa;
create database if not exists analytics;

-- service user for dbt: key pair login, no pw
create user if not exists transformer_user
    type = service
    rsa_public_key = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtwUVPRpkLEN5wpYj9nGHmQbw8+KS7rNASVGNxNINz6LcZyORILfhDcs9EyW9B9eP2pQPsbWXsvrA4lDNYW1OsOqU3qb28zwhELZ9Fv03vRX4XmQZVvHjDRjNrWwRpMLIEp+cijxD3IWBrrv37Ea6+S3riSUghpuLKuu7JzmsITF+wA8BaYGBJmNSNtF6cXAFauXH5eGoJS+m65V5yS8Gw9Tla6iWSTnhV7hXSmYvzWJuWTNXjjdW5q2XlBpqBe++5bZ8poZh/SC3wUS/n67tgUnvtKsUK0InbVTgkni9NQZBIp4geiKyvWJidfDKDiI3EvnrjT0hOHf+EzNkTExKowIDAQAB'
    default_warehouse = dbt_pipeline_wh
    default_role = transformer;

-- grant warehouse
grant usage on warehouse dbt_pipeline_wh to role transformer;

-- grante: read raws (database -> schema -> tables, including future ones)
grant usage on database raw to role transformer;
grant usage on schema raw.phmsa to role transformer;
grant select on all tables in schema raw.phmsa to role transformer;
grant select on future tables in schema raw.phmsa to role transformer;

-- grant: build analytics
grant usage, create schema on database analytics to role transformer;

-- give the role to dbt_user
grant role transformer to user transformer_user;
grant role transformer to user "sandy.yang992";

-- check
show grants to user transformer_user;

-- Create role: loader
use role accountadmin;
create role if not exists loader;
grant role loader to role sysadmin;

-- granting loader for loading raw database
grant usage on warehouse dbt_pipeline_wh to role loader;

-- grant: database access, create schema access
grant usage on database raw to role loader;

-- RAW.PHMSA: may enter, and create the objects write_pandas uses.
-- Tables it creates, it owns, so no per-table grants needed.
grant usage on schema raw.phmsa to role loader;
grant create table, create stage, create file format on schema raw.phmsa to role loader;

-- Create user for loader
create user if not exists loader_user
    type = service
    rsa_public_key = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAr5exhek698A0S6V0hNxSWDWvDH1jPbwHUzCyCLXNtpeOaZmdz5dR0yFAF98hqK9WniGlNvgVJ7pwuN7X73o6T9YYLoWQwXPb9w/QjmOu+w8g/xrIdxr/tlMBnJzijOfrBnYDIyPdeNs195weapCpVMp3FIg2dANAO0Otk0M7+vVqJfs38a5Ap/du24IQmDAZYgup1CYmNULyCGpEessR12WuhhQXFYWrcdt7A7nsZm6VAgGfpT3A8Gkk2HDh70CdvonuZOjF5Vq2ov1U5w4bPzKhN3aT+ZLUz1EQ6f51mdb3Ut/A4g+n3qbHik9uGubaiICDSPVM0+hHv+isgSHLmQIDAQAB'
    default_warehouse = dbt_pipeline_wh
    default_role = loader;;

-- give the role to dbt_user
grant role loader to user loader_user;
grant role loader to user "sandy.yang992";
show grants to user loader_user;

