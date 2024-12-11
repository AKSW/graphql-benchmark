# Supplementary material for the paper: "Native Execution of GraphQL Queries over RDF Graphs Using Multi-way Joins"

# Source code
- Tentris (graphql endpoint): https://github.com/dice-group/tentris/tree/graphql-endpoint
- Hypertrie (implementation of the multi-way left join algorithm): https://github.com/dice-group/hypertrie/tree/left-join

# Experiments (Ansible playbook)
To set up the experiments we provide an Ansible playbook.

Installation: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

## Before running the playbook
 - Replace ```<ip_of_host>``` in ```ansible_playbook/inventory.yaml``` with the IP of the managed node (i.e., the server that will run the experiments).
 - Replace ```<target_dir>``` in ```ansible_playbook/roles/base/defaults/main.yaml``` with the absolute path to the directory of the managed node that will store the experiments' required files.
 - Replace ```<user>``` in ```ansible_playbook/roles/base/defaults/main.yaml``` with the username that will be used to login with to the managed node.
 - Install docker in the server that will run the experiments (https://docs.docker.com/engine/install/debian/) (Note: The user must be added to the docker group)

## Playbook Execution
You can execute the playbook by issuing the following command:

    ansible-playbook -kKi inventory.yaml playbook.yaml

## Benchmark Execution
Before running the benchmarks:

- increase ulimit
    
        ulimit -n 64000

- set swappiness to 0

        sudo sysctl vm.swappiness=0
    
- prepare neo4j databases
       
        cd <target_dir>
        sudo ./run_load.sh

To run the benchmark execute the script ```run_graphql.sh``` with root privileges.

    cd <target_dir>
    sudo ./run_graphql.sh
The results  of the benchmark (IGUANA result files) are stored in the directory `<target_dir>/iguana_results/graphql`

## Datasets, Queries and Results
The datasets used in the benchmark, their respective queries and the GraphQL schemata are available for download [here](https://hobbitdata.informatik.uni-leipzig.de/tentris-graphql/data/).

The results reported in the paper and the scripts to generate the plots are available for download [here](https://hobbitdata.informatik.uni-leipzig.de/tentris-graphql/results.zip).

## Pre-Built Binaries
The pre-built binary of our implementation is available for download [here](https://github.com/dice-group/graphql-benchmark/raw/main/ansible_playbook/roles/tentris/files/tentris_server).
