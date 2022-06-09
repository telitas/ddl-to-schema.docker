#!/usr/bin/env bash
set -e

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

output_directory="$(cd $(dirname $0); pwd)/dest"
if [[ ! -e $output_directory ]]; then
    mkdir -p $output_directory
fi

docker compose down --volumes 2> /dev/null
docker compose up --quiet-pull --detach 2> /dev/null

docker compose exec ddl-to-schema bash -c "/bundle/extract.sh $format"

docker compose down --volumes 2> /dev/null

echo "schemas generated at ${output_directory%/}/${format}"
