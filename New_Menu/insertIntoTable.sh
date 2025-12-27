#!/bin/bash
insertIntoTable() {
    # Base directory for databases
    DBDIR="Databases"

    # ask user for table name
    echo "enter the name of the table to insert data into:"
    read table_name

    # paths to metadata and data files 
    META_FILE="$DBDIR/$DB_NAME/$table_name.meta"
    DATA_FILE="$DBDIR/$DB_NAME/$table_name.data"

    # ensure the data file exists before inserting data
    if [ -f "$DATA_FILE" ]; then
        # read column names and types from the metadata file
        columns=($(awk -F: '{print $1}' "$META_FILE"))
        types=($(awk -F: '{print $2}' "$META_FILE"))
        PK_index=$(awk -F: '{if($3=="PK") print NR-1}' "$META_FILE")
        columns_num=${#columns[@]}

        # if file is empty or contains only whitespace, initialize headers and primary key
        if [ ! -s "$DATA_FILE" ] || [ -z "$(grep -v '^[[:space:]]*$' "$DATA_FILE")" ]; then
            # remove any whitespace-only content
            > "$DATA_FILE"
            # write header line with column names (colon separated)
            echo "${columns[*]}" | sed 's/ /:/g' >> "$DATA_FILE"

            # write a simple separator line for readability
            sep_line=""
            for ((j=0; j<columns_num; j++)); do
                sep_line+="---"
            done
            echo "$sep_line" >> "$DATA_FILE"

            # start primary key counter at 1
            new_pk=1
        else
            # read last primary key from the last data row
            last_pk=$(awk -F: 'END {print $1}' "$DATA_FILE")
            new_pk=$((last_pk + 1))
        fi

        # main insert loop: allow multiple inserts
        while true; do
            record="$new_pk"

            # prompt for each non-PK column value and validate by type
            for ((i=1; i<columns_num; i++)); do
                while true; do
                    echo "Enter value for ${columns[i]} (${types[i]}): "
                    read value

                    case "${types[i]}" in
                        int)
                            # reject empty values
                            if [[ -z "$value" ]]; then
                                echo "Integer value cannot be empty."
                                continue
                            fi
                            # accept only integer values
                            if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                                echo "Invalid input. Please enter an integer."
                                continue
                            fi
                            ;;
                        string)
                            # reject empty values
                            if [[ -z "$value" ]]; then
                                echo "Invalid input. Please enter a non-empty string."
                                continue
                            fi
                            # Separator check
                            if [[ "$value" == *:* ]]; then
                                echo "Invalid input. ':' is not allowed in string values."
                                continue
                            fi

                            ;;
                        bool)
                            # reject empty values
                            if [[ -z "$value" ]]; then
                                echo "Boolean value cannot be empty."
                                continue
                            fi
                            # accept only 'true' or 'false'
                            if ! [[ "$value" =~ ^(true|false)$ ]]; then
                                echo "Invalid input. Please enter 'true' or 'false'."
                                continue
                            fi
                            ;;
                        *)
                            # unknown type in metadata
                            echo "Unknown data type for column ${columns[i]}."
                            continue 2
                            ;;
                    esac

                    # append validated value to the record (colon-separated)
                    record+=":$value"
                    break
                done
            done

            # append the new record to the data file
            echo "$record" >> "$DATA_FILE"

            echo "Data inserted successfully into $table_name."

            # ask the user if they want to insert another row
            read -p "Do you want to insert another row? (yes/no): " another
            if [[ "$another" != "yes" && "$another" != "y" ]]; then
                break
            fi
            new_pk=$((new_pk + 1))
        done
    else
        # data file does not exist for this table
        echo "Table $table_name does not exist in database $DB_NAME."
    fi
}