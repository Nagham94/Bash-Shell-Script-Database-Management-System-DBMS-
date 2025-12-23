#!/bin/bash
    DB_NAME=$1

    echo "listing all tables in the current database..."

    tables=$(ls databases/$DB_NAME/*.data 2> /dev/null)
    
    if [ -z "$tables" ]; then
        echo -e "\nYou don't have any tables yet\n"
    else 
        echo -e "\nYour tables are:\n"
        for table in $tables; do
            echo "$table"
        done
    fi
    
