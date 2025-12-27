#!/bin/bash

listTables() {
    # base directory for databases
    DBDIR="Databases"
    
    # inform user that the operation is in progress
    echo "listing all tables in the current database..."

    # retrieve all .data files (table files) from the current database directory
    tables=$(ls $DBDIR/$DB_NAME/*.data 2> /dev/null)
    
    # check if any tables exist
    if [ -z "$tables" ]; then
        # no tables found
        echo -e "\nYou don't have any tables yet\n"
    else 
        # display all available tables
        echo -e "\nYour tables are:\n"
        # extract table name from the file path (remove directory and .data extension)
        for table in $tables; do
            echo "$(basename "$table" .data)"
        done
    fi
}   
