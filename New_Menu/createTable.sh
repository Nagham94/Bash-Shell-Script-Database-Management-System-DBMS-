#!/bin/bash

createTable() {

    # Ensure database is selected
     if [[ -z "$CURRENT_DB" ]]; then
        echo "Error: No database selected"
        return
    fi

    read -p "Enter table name: " TABLE_NAME
    [[ -z "$TABLE_NAME" ]] && { echo "Table name cannot be empty"; return; }

    meta_file="$CURRENT_DB/$TABLE_NAME.meta"
    data_file="$CURRENT_DB/$TABLE_NAME.data"

    [[ -f "$meta_file" ]] && { echo "Table already exists"; return; }

    read -p "Enter number of columns: " col_count
    [[ ! "$col_count" =~ ^[0-9]+$ || "$col_count" -le 0 ]] && {
        echo "Invalid number of columns"
        return
    }

    > "$meta_file"

    # Ask for PK name
    while true; do
        read -p "Enter primary key column name: " pk_name
        [[ -z "$pk_name" ]] && { echo "PK name cannot be empty"; continue; }
        break
    done

    echo "Note: Primary key '$pk_name' is INT by default"

    # Store PK
    echo "$pk_name:int:PK" >> "$meta_file"

    valid_types=("int" "string" "bool")

    for ((i=2; i<=col_count; i++)); do

        # Column name validation
        while true; do
            read -p "Column $i name: " col_name

            if [[ -z "$col_name" ]]; then
                echo "Column name cannot be empty"
                continue
            fi

            # Check duplicate column names
            if cut -d: -f1 "$meta_file" | grep -qx "$col_name"; then
                echo "Column name '$col_name' already exists"
                continue
            fi

            break
        done

        # Column type validation
        while true; do
            read -p "Column $i type (int/string/bool): " col_type

            [[ -z "$col_type" ]] && { echo "Data type cannot be empty"; continue; }

            if [[ " ${valid_types[*]} " =~ " $col_type " ]]; then
                break
            else
                echo "Invalid data type. Allowed: int, string, bool"
            fi
        done

        echo "$col_name:$col_type" >> "$meta_file"
    done

    touch "$data_file"
    echo "Table '$TABLE_NAME' created successfully"
    
    export TABLE_NAME
}

