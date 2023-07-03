#! /bin/bash
if [[ -f {{ target_dir }}/neo4j.pid ]]
then
    echo $(date --iso-8601) - Neo4J seems to be already running
    echo If it is not running remove neo4j.pid
    exit 1
fi
# copy configuration file
cp {{ target_dir }}/iguana_suites/graphql/neo4j/{{ item[1].number }}-neo4j.conf {{ target_dir }}/databases/neo4j-{{ item[0].name }}/neo4j-community-{{ neo4j_version }}/conf/neo4j.conf ;
# jvm options
echo $(date --iso-8601) - Starting Neo4J
{{ target_dir }}/databases/neo4j-{{ item[0].name }}/neo4j-community-{{ neo4j_version }}/bin/neo4j start & disown
echo $(date --iso-8601) - Waiting for Neo4J to become available
while :
do
    curl -s 127.0.0.1:7474
    if [ $? -eq 0 ]
    then
        break
    fi
    sleep 2
done
# copy pid
cp {{ target_dir }}/databases/neo4j-{{ item[0].name }}/neo4j-community-{{ neo4j_version }}/run/neo4j.pid {{ target_dir }}/neo4j.pid
# list indices
echo ""
echo "List of Lookup Indices"
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "SHOW LOOKUP INDEXES ;" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
echo ""
echo "List of FullText Indices"
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "SHOW TEXT INDEXES ;" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
# cache the graph
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "MATCH (n) OPTIONAL MATCH (n)-[r]->() RETURN count(n.prop) + count(r.prop);" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
echo $(date --iso-8601) - Neo4J started and accepting connections