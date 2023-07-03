#!/bin/bash
workers=( 1 4 8 16 )
datasets=( "lingbm100" "lingbm500" "lingbm1000" )
echo "$(date): GraphQL benchmarks"
# run Query Mixes suites -- only for 1 worker
echo "$(date): Running Query Mixes suites (one worker only)"
###### run Neo4jCypher
for dataset in "${datasets[@]}"
do
	echo 3 >/proc/sys/vm/drop_caches
	echo "$(date): Starting Neo4J for $dataset (qts), QM-Workers: 1"
	./iguana_suites/graphql/neo4j/$dataset/1-start.sh &> /dev/null
	echo "$(date): Running IGUANA (QM Limit) for Neo4J and $dataset (qts) , QM-Workers: 1"
	./iguana-run.sh ./iguana_suites/graphql/neo4j/$dataset/1-qts-QM.yml &> /dev/null
	echo "$(date): Stopping Neo4J for $dataset (qts), QM-Workers: 1"
	./iguana_suites/graphql/neo4j/$dataset/stop.sh &> /dev/null
done
###### run TentrisGQL
for dataset in "${datasets[@]}"
do
	echo 3 >/proc/sys/vm/drop_caches
	echo "$(date): Starting Tentris for $dataset (qts), QM-Workers: 1"
	./iguana_suites/graphql/TentrisGQL/$dataset/1-start.sh &> /dev/null
	echo "$(date): Running IGUANA (QM Limit) for Tentris and $dataset (qts), QM-Workers: 1"
	./iguana-run.sh ./iguana_suites/graphql/TentrisGQL/$dataset/1-qts-QM.yml &> /dev/null
	echo "$(date): Stopping Tentris for $dataset (qts), QM-Workers: 1"
	./iguana_suites/graphql/TentrisGQL/stop.sh &> /dev/null
done
###### run TentrisGQLBase
for dataset in "${datasets[@]}"
do
	echo 3 >/proc/sys/vm/drop_caches
	echo "$(date): Starting TentrisGQLBase for $dataset (qts), QM-Workers: 1"
	./iguana_suites/graphql/TentrisGQLBase/$dataset/1-start.sh &> /dev/null
	echo "$(date): Running IGUANA (QM Limit) for TentrisGQLBase and $dataset (qts), QM-Workers: 1"
	./iguana-run.sh ./iguana_suites/graphql/TentrisGQLBase/$dataset/1-qts-QM.yml &> /dev/null
	echo "$(date): Stopping TentrisGQLBase for $dataset (qts), QM-Workers: 1"
	./iguana_suites/graphql/TentrisGQLBase/stop.sh &> /dev/null
done
#######
# run time limit queries -- multiple workers
echo "$(date): Running Time Limit suites (multiple workers)"
for dataset in "${datasets[@]}"
do
	for i in "${workers[@]}"
	do
		# run neo4j
		echo 3 >/proc/sys/vm/drop_caches
		echo "$(date): Starting Neo4J (all), T-Workers: $i"
		./iguana_suites/graphql/neo4j/$dataset/"$i"-start.sh &> /dev/null
		echo "$(date): Running IGUANA (T Limit) for Neo4J (all) , T-Workers: $i"
		./iguana-run.sh ./iguana_suites/graphql/neo4j/$dataset/"$i"-all-T.yml &> /dev/null
		echo "$(date): Stopping Neo4J (all), T-Workers: $i"
		./iguana_suites/graphql/neo4j/$dataset/stop.sh &> /dev/null
		# run TentrisGQL
		echo 3 >/proc/sys/vm/drop_caches
		echo "$(date): Starting TentrisGQL (all), T-Workers: $i"
		./iguana_suites/graphql/TentrisGQL/$dataset/"$i"-start.sh &> /dev/null
		echo "$(date): Running IGUANA (T Limit) for TentrisGQL (all), T-Workers: $i"
		./iguana-run.sh ./iguana_suites/graphql/TentrisGQL/$dataset/"$i"-all-T.yml &> /dev/null
		echo "$(date): Stopping Tentris (all), T-Workers: $i"
		./iguana_suites/graphql/TentrisGQL/stop.sh &> /dev/null
		# run TentrisGQLbase
		echo 3 >/proc/sys/vm/drop_caches
		echo "$(date): Starting TentrisGQLBase (all), T-Workers: $i"
		./iguana_suites/graphql/TentrisGQLBase/$dataset/"$i"-start.sh &> /dev/null
		echo "$(date): Running IGUANA (T Limit) for TentrisGQLBase (all), T-Workers: $i"
		./iguana-run.sh ./iguana_suites/graphql/TentrisGQLBase/$dataset/"$i"-all-T.yml &> /dev/null
		echo "$(date): Stopping Tentris (all), T-Workers: $i"
		./iguana_suites/graphql/TentrisGQLBase/stop.sh &> /dev/null
	done
done
######
# run time limit queries for neo4jtranslation -- only 1 worker
# run neo4jtranslation
for dataset in "${datasets[@]}"
do
	echo 3 >/proc/sys/vm/drop_caches
	echo "$(date): Starting Neo4j for $dataset (qts), T-Workers: 1"
	./iguana_suites/graphql/neo4j/$dataset/1-start.sh &> /dev/null
	node ./systems/neo4j/translation.js &
	a_id="$!"
	sleep 1m
	echo "$(date): Running IGUANA (Time Limit) for Neo4JGraphQL (ApolloServer) and $dataset"
	./iguana-run.sh ./iguana_suites/graphql/neo4j/$dataset/1-translation-all-T.yml &> /dev/null
	echo "$(date): Stopping Neo4JGraphQL (ApolloServer) for $dataset"
	./iguana_suites/graphql/neo4j/$dataset/stop.sh &> /dev/null
	echo "$(date): Stopping Apollo Server"
	kill -9 "$a_id"
done
