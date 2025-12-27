#!/bin/bash

dropDatabase() {
    # base directory for databases
    DBDIR="Databases"

    # ask user for the database name to delete
    echo "please Enter the Name of the DB to delete:"
    read dbname

    # check if the database directory exists
    if [ -d "$DBDIR/$dbname" ]
    then
        # confirm deletion with the user
        echo "Are you sure you want to delete the database '$dbname'? (y/n)"
        read confirmation

        # if user did not confirm, cancel the deletion
        if [ "$confirmation" != "y" ]; then
            echo "Database deletion canceled."
            exit 0
        fi

        # delete the database directory and all its contents
        echo "Deleting database..."
        rm -r "$DBDIR/$dbname"
        echo "Database deleted successfully"
    else
        # database directory does not exist
        echo "Database not found"
    fi
}