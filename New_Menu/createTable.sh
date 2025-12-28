#!/bin/bash

createTable() {

    # Ensure database is selected
     if [[ -z "$CURRENT_DB" ]]; then
        echo "Error: No database selected"
        return
    fi

    read -p "Enter table name: " TABLE_NAME
    if [[ -z "$TABLE_NAME" ]]; then
	    echo "Table name cannot be empty";
	    return; 
    fi

    meta_file="$CURRENT_DB/$TABLE_NAME.meta"
    data_file="$CURRENT_DB/$TABLE_NAME.data"

    if [[ -f "$meta_file" ]]; then
	     echo "Table already exists"
	     return
    fi

    read -p "Enter number of columns: " col_count
    if [[ ! "$col_count" =~ ^[0-9]+$ || "$col_count" -le 0 ]]; then
        echo "Invalid number of columns"
        return
    fi

    > "$meta_file"

    # Ask for PK name
    while true; do
        read -p "Enter primary key column name: " pk_name
        if [[ -z "$pk_name" ]]; then
	       	echo "PK name cannot be empty";
	       	continue;
	else
        	break
	fi
    done

    while true; do
    	read -p "Enter primary key type (int/string): " pk_type
    	valid_types_pk=("int" "string")

    	if [[ -z "$pk_type" ]]; then
		echo "Data type cannot be empty"; 
		continue;
	fi

        if [[ " ${valid_types_pk[*]} " =~ " $pk_type " ]]; then # check for a matched regex pattern.
    		break
	else
		echo "Invalid data type. Allowed: int, string"
    	fi
	done

   echo "$pk_name:$pk_type:PK" >> "$meta_file"

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
            if cut -d: -f1 "$meta_file" | grep -qx "$col_name"; then # q to quite without printing, x for exact match
                echo "Column name '$col_name' already exists"
                continue
            fi

            break
        done

        # Column type validation
        while true; do
            read -p "Column $i type (int/string/bool): " col_type

            if [[ -z "$col_type" ]]; then
		    echo "Data type cannot be empty";
		    continue; 
	    fi

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
}

