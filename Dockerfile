ARG postgres_version=latest
FROM postgres:${postgres_version}

LABEL dev.telitas.project.repository="https://github.com/telitas/ddl-to-schema.docker"
LABEL dev.telitas.base.repository="https://hub.docker.com/_/postgres"

RUN apt-get update && \
    apt-get install -y libxml2-utils jq && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./bundle/extract.sh ./bundle/extract_table_as_json.sql ./bundle/extract_table_as_xml.sql /bundle/
RUN chmod 755 ./bundle/extract.sh
