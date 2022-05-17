#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
{% for i in postgresql_users %}
CREATE USER "{{i.name}}" WITH PASSWORD '{{i.password}}';
{% endfor %}
{% for d in services %}
CREATE DATABASE {{network_name}}_{{d}}_v2 OWNER "$POSTGRES_USER";
\c {{network_name}}_{{d}}_v2
{% for i in postgresql_users %}
GRANT CONNECT ON DATABASE {{network_name}}_{{d}}_v2 TO "{{i.name}}";
GRANT USAGE ON SCHEMA public TO "{{i.name}}";
GRANT {{i.privileges}} ON ALL TABLES IN SCHEMA public TO "{{i.name}}";
{% endfor %}
{% endfor %}
EOSQL

