#!/usr/bin/env bash
set -eu

format=
for f in xml json
do
    if [[ "${1}" == "${f}" ]]; then
        format=$f
    fi
done
if [[ "${format}" == "" ]]; then
    echo "usage ${0} xml|json"
    exit 1
fi

output_directory="/dest/${format}"
if [[ ! -e $output_directory ]]; then
    mkdir -p $output_directory
fi

passed_seconds=0
while ! pg_isready --host localhost --port 5432 --user postgres > /dev/null 2> /dev/null
do
    sleep 1
    passed_seconds=$((passed_seconds + 1))
    if [[ ${passed_seconds} -ge 60 ]]; then
        echo "60 seconds have past. There was something wrong."
        exit 1
    fi
done

psql --host localhost --port 5432 --username postgres --tuples-only < "/bundle/extract_table_as_${format}.sql" > /dev/null

for table in `psql --host localhost --port 5432 --username postgres --tuples-only --command "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"`
do
    if [[ "$1" = "json" ]]; then
        psql --host localhost --port 5432 --username postgres --tuples-only --command "SELECT extract_table_as_json('${table}');" \
            | jq > "${output_directory%/}/${table}.json"
    elif [[ "$1" = "xml" ]]; then
        psql --host localhost --port 5432 --username postgres --tuples-only --command "SELECT extract_table_as_xml('${table}');" \
            | xmllint --format - > "${output_directory%/}/${table}.xsd"
    fi
done;
