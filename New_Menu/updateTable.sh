#!/bin/bash

# validate user input based on data type
# Args: $1 = value, $2 = type, $3 = column name
# Returns: 0 if valid, 1 if invalid (prints error message on failure)
validate_input() {
    local value="$1"
    local type="$2"
    local col_name="$3"

    case "$type" in
        int)
            # reject empty values
            if [[ -z "$value" ]]; then
                echo "Integer value cannot be empty."
                return 1
            fi
            # accept only integer values
            if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                echo "Invalid input. Please enter an integer."
                return 1
            fi
            ;;
        string)
            # reject empty values
            if [[ -z "$value" ]]; then
                echo "Invalid input. Please enter a non-empty string."
                return 1
            fi
            # reject values that are purely numeric
            if [[ "$value" =~ ^-?[0-9]+$ ]]; then
                echo "Invalid input. String cannot be only digits."
                return 1
            fi
            # separator check
            if [[ "$value" == *:* ]]; then
                echo "Invalid input. ':' is not allowed in string values."
                return 1
            fi
            ;;
        bool)
            # reject empty values
            if [[ -z "$value" ]]; then
                echo "Boolean value cannot be empty."
                return 1
            fi
            # accept only 'true' or 'false'
            if ! [[ "$value" =~ ^(true|false)$ ]]; then
                echo "Invalid input. Please enter 'true' or 'false'."
                return 1
            fi
            ;;
        *)
            # unknown type in metadata
            echo "Unknown data type for column $col_name."
            return 1
            ;;
    esac

    return 0
}

updateTable() {
    # base directory for databases
    DBDIR="Databases"

    # ask user for table name
    echo "Enter the name of the table to update data in:"
    read table_name

    # paths to metadata and data files
    META_FILE="$DBDIR/$DB_NAME/$table_name.meta"
    DATA_FILE="$DBDIR/$DB_NAME/$table_name.data"
    
    # ensure the data file exists before attempting update
    if [ -f "$DATA_FILE" ]; then
        # check if file is empty or contains only whitespace
        if [ ! -s "$DATA_FILE" ] || [ -z "$(grep -v '^[[:space:]]*$' "$DATA_FILE")" ]; then
            echo "Table $table_name is empty. There is no data to update."
            return
        fi

        # read column names and types from the metadata file
        columns=($(awk -F: '{print $1}' "$META_FILE"))
        types=($(awk -F: '{print $2}' "$META_FILE"))
        PK_index=$(awk -F: '{if($3=="PK") print NR-1}' "$META_FILE")
        columns_num=${#columns[@]}

        # main update loop: allow multiple updates
        while true; do
            # prompt for the primary key to search for
            echo "Enter the Primary Key (${columns[0]}) of the row to update: "
            read search_pk

            # search for the record with matching primary key
            if ! awk -F: -v pk="$search_pk" '$1==pk' "$DATA_FILE" | grep -q .; then
                echo "No record found with Primary Key: $search_pk"
                continue
            fi

            # display the current record
            echo "Current record:"
            echo "${columns[*]}" | sed 's/ /:/g'
            sep_line=""
            for ((j=0; j<columns_num; j++)); do
                sep_line+="---"
            done
            echo "$sep_line"
            # retrieve the full current record for reference
            current_record=$(awk -F: -v pk="$search_pk" '$1==pk' "$DATA_FILE")
            echo "$current_record"
            echo ""

            # prompt user to choose update mode
            echo "What would you like to do?"
            echo "1. Update the entire record"
            echo "2. Update specific columns"
            echo "Choose option (1 or 2): "
            read update_option

            # option 1: update all columns (non-PK) at once
            if [[ "$update_option" == "1" ]]; then
                record="$search_pk"
                
                # prompt for each non-PK column
                for ((i=1; i<columns_num; i++)); do
                    while true; do
                        echo "Enter new value for ${columns[i]} (${types[i]}): "
                        read value

                        # validate input using the validation function
                        if validate_input "$value" "${types[i]}" "${columns[i]}"; then
                            record+=":$value"
                            break
                        fi
                    done
                done

                # update the row in the data file
                sed -i "/^$search_pk:/c\\$record" "$DATA_FILE"
                echo "Data updated successfully in $table_name."

            # option 2: update only selected columns
            elif [[ "$update_option" == "2" ]]; then
                # parse the current record into individual values
                IFS=':' read -ra current_values <<< "$current_record"
                record="$search_pk"

                # list all available columns with their current values
                echo ""
                echo "Available columns (excluding Primary Key):"
                col_num=1
                for ((i=1; i<columns_num; i++)); do
                    echo "$col_num. ${columns[i]} (${types[i]}) [Current: ${current_values[i]}]"
                    ((col_num++))
                done
                echo ""
                # prompt user to select which columns to update
                while true; do
                    echo "Enter the column numbers you want to update (space-separated, e.g., '1 3'): "
                    read columns_input

                    # validate that input contains only space-separated numbers
                    if [[ -z "$columns_input" ]]; then
                        echo "Error: You must enter at least one column number."
                        continue
                    fi

                    if ! [[ "$columns_input" =~ ^[0-9]+( [0-9]+)*$ ]]; then
                        echo "Error: Please enter only numbers separated by spaces."
                        continue
                    fi

                    # check that all numbers are valid column indices
                    valid=1
                    for col_choice in $columns_input; do
                        if [[ $col_choice -lt 1 ]] || [[ $col_choice -gt $((columns_num-1)) ]]; then
                            echo "Error: Column number must be between 1 and $((columns_num-1))."
                            valid=0
                            break
                        fi
                    done

                    if [[ $valid -eq 1 ]]; then
                        columns_to_update=($columns_input)
                        break
                    fi
                done

                # process each column, updating only selected ones
                for ((i=1; i<columns_num; i++)); do
                    found=0
                    # check if this column is in the user's selection
                    for col_choice in "${columns_to_update[@]}"; do
                        if [[ "$col_choice" == "$((i))" ]]; then
                            found=1
                            break
                        fi
                    done
                    
                    # if column is selected, prompt for new value
                    if [[ $found -eq 1 ]]; then
                        while true; do
                            echo "Enter new value for ${columns[i]} (${types[i]}) [Current: ${current_values[i]}]: "
                            read value

                            # validate input using the validation function
                            if validate_input "$value" "${types[i]}" "${columns[i]}"; then
                                record+=":$value"
                                break
                            fi
                        done
                    else
                        # keep current value if column not selected
                        record+=":${current_values[i]}"
                    fi
                done

                # update the row in the data file
                sed -i "/^$search_pk:/c\\$record" "$DATA_FILE"
                echo "Data updated successfully in $table_name."
            else
                # invalid option entered
                echo "Invalid option. Please choose 1 or 2."
                continue
            fi
            
            # ask user if they want to update another row
            echo "Do you want to update another row? (yes/no): "
            read another
            if [[ "$another" != "yes" && "$another" != "y" ]]; then
                break
            fi
        done
    else
        # data file does not exist for this table
        echo "Table $table_name does not exist in database $DB_NAME."
    fi
}