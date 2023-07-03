#! /bin/bash
mkdir -p {{ target_dir }}/databases/neo4j-{{ item.name }}
echo $(date --iso-8601) - Preparing Neo4J
tar -xf {{ target_dir }}/systems/neo4j/neo4j-community-{{ neo4j_version }}-unix.tar.gz -C {{ target_dir }}/databases/neo4j-{{ item.name }}/ ;
# copy apoc jar
cp {{ target_dir }}/systems/neo4j/apoc-{{ apoc_version }}-core.jar {{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/plugins ;
# copy data
cp {{ item.path.neo4j[0] }} {{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/import/nodes.csv ;
cp {{ item.path.neo4j[1] }} {{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/import/edges.csv ;
# run loader
{{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/bin/neo4j-admin database import full --nodes {{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/import/nodes.csv --relationships {{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/import/edges.csv ;
# created indices
echo "dbms.security.auth_enabled=false" >> {{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/conf/neo4j.conf ;
echo $(date --iso-8601) - Starting Neo4J
{{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/bin/neo4j start & disown
while :
do
    curl -s 127.0.0.1:7474
    if [ $? -eq 0 ]
    then
        break
    fi
    sleep 2
done
# node lookup
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "CREATE LOOKUP INDEX node_label_lookup_index IF NOT EXISTS FOR (n) ON EACH labels(n);" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
# relationship lookup
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "CREATE LOOKUP INDEX rel_type_lookup_index IF NOT EXISTS FOR ()-[r]-() ON EACH type(r);" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
# facutly (uri) index
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "CREATE TEXT INDEX faculty_index IF NOT EXISTS FOR (n:Faculty) ON ( n.uri ) ;" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
# lecturer (uri) index 
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "CREATE TEXT INDEX lecturer_index IF NOT EXISTS FOR (n:Lecturer) ON ( n.uri ) ;" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
# university (uri) index 
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "CREATE TEXT INDEX university_index IF NOT EXISTS FOR (n:University) ON ( n.uri ) ;" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
# research group (uri) index
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "CREATE TEXT INDEX res_group_index IF NOT EXISTS FOR (n:ResearchGroup) ON ( n.uri ) ;" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
# department (uri) index
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "CREATE TEXT INDEX department_index IF NOT EXISTS FOR (n:Department) ON ( n.uri ) ;" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
# publication (name) index
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "CREATE TEXT INDEX publication_index IF NOT EXISTS FOR (n:Publication) ON ( n.name ) ;" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
echo ""
echo "List of Lookup Indices"
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "SHOW LOOKUP INDEXES ;" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
echo ""
echo "List of TEXT Indices"
curl -H "Content-Type: application/json" --user neo4j:neo4j -d '{ "statements" : [ { "statement" : "SHOW TEXT INDEXES ;" } ] }' http://localhost:7474/db/neo4j/tx/commit ;
{{ target_dir }}/databases/neo4j-{{ item.name }}/neo4j-community-{{ neo4j_version }}/bin/neo4j stop
