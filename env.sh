set -a
source .env
set +a
export SNOWFLAKE_DBT_PRIVATE_KEY="$(cat keys/dbt_key.p8)"