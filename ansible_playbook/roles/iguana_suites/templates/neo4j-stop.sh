#! /bin/bash

if [[ ! -f {{ target_dir }}/neo4j.pid ]]
then
    echo $(date --iso-8601) - Neo4J is not running
    exit 1
fi

{{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/bin/neo4j stop

sleep 20
kill -9 $(cat {{ target_dir }}/neo4j.pid) >/dev/null

rm {{ target_dir }}/neo4j.pid

cp -r {{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/logs {{ target_dir }}/logs/run/neo4j

rm {{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/logs/*.log*
