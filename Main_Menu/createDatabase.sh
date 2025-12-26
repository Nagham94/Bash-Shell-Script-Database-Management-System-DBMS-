#!/bin/bash 

DBDIR="Databases" 

createDatabase() {
        read -p "Enter Database Name: " DB_NAME

        if [[ ! "$DB_NAME" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "Invalid database name!"
                return
        fi
        
        # Check if database already exists
        if [[ -d "$DBDIR/$DB_NAME" ]]; then
                echo "Database '$DB_NAME' already exists!"
        else
                mkdir "$DBDIR/$DB_NAME"
                echo "Database '$DB_NAME' created successfully"
        fi
}

