#!/bin/bash

selectFromTable() {

    if [[ -z "$CURRENT_DB" ]]; then
        echo "No database selected!"
        return
    fi

    echo "Enter table name:"
    read table

    META_FILE="$CURRENT_DB/$table.meta"
    DATA_FILE="$CURRENT_DB/$table.data"

    if [[ ! -f "$META_FILE" || ! -f "$DATA_FILE" ]]; then
        echo "Table does not exist!"
        return
    fi

    echo "1) Select All"
    echo "2) Select By Primary Key"
    read -p "Choose option: " choice

    # Read column names
    case $choice in
    1)
        if [[ ! -s "$DATA_FILE" ]]; then
            echo "Table is empty"
            return
        fi

        awk -F':' '{
            for (i=1; i<=NF; i++)
                printf "%-15s", $i
            print ""
        }' "$DATA_FILE"
        ;;

    2)
        read -p "Enter Primary Key value: " pk
	
        result=$(awk -F':' -v key="$pk" '$1 == key' "$DATA_FILE")

        if [[ -z "$result" ]]; then
            echo "Record not found"
            return
        fi
        
	header=$(awk -F: '{printf "%-15s", $1}' "$META_FILE")
    	echo "$header"
    	echo "------------------------------------------------"
        echo "$result" | awk -F':' '{
            for (i=1; i<=NF; i++)
                printf "%-15s", $i
            print ""
        }'
        ;;
    *)
        echo "Invalid option"
        ;;
    esac
}

