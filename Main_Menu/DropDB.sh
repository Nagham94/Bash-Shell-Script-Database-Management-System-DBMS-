#!/bin/bash
DBDIR="../databases"

echo "please Enter the Name of the DB to delete:"
read dbname
if [ -d "$DBDIR/$dbname" ]
then
    echo "Are you sure you want to delete the database '$dbname'? (y/n)"
    read confirmation
    if [ "$confirmation" != "y" ]; then
        echo "Database deletion canceled."
        exit 0
    fi
    echo "Deleting database..."
    rm -r "$DBDIR/$dbname"
    echo "Database deleted successfully"
else
    echo "Database not found"
fi
