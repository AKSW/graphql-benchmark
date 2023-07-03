#! /bin/bash
if [[ -f {{ target_dir }}/tentris.pid ]]
then
    echo $(date --iso-8601) - Tentris seems to be already running
    echo If it is not running remove tentris.pid
    exit 1
fi
echo $(date --iso-8601) - Starting Tentris
{{ target_dir }}/systems/{{ tentris_version }}/tentris_server -t {{ tentris_timeout }} -c {{ threads }} -f {{ item[1].path.rdf }} --logfile=false --logstdout </dev/null 2>&1 >{{ target_dir }}/logs/run/{{ item[0] }}-{{ item[1].name }}-{{ item[2].number }}.log & disown
pid=$!
echo $pid > {{ target_dir }}/tentris.pid
echo $(date --iso-8601) - Waiting for Tentris to become available
while :
do
    curl -s 127.0.0.1:9080
    if [ $? -eq 0 ]
    then
        break
    fi
    sleep 2
done
if [ "{{ item[0] }}" = "TentrisGQLBase" ]
then
    echo $(date --iso-8601) - Provided schema without ID
    curl -F "schema=@{{ item[1].schema_path.tentris_noid }}" 127.0.0.1:9080/graphqlschema/
else
    echo $(date --iso-8601) - Provided schema with ID
    curl -F "schema=@{{ item[1].schema_path.tentris }}" 127.0.0.1:9080/graphqlschema/
fi
sleep 2
echo $(date --iso-8601) - Tentris started and accepting connections
