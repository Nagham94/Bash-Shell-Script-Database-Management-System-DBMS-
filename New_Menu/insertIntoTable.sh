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

            fi

            # main insert loop: allow multiple inserts
            while true; do
                # collect values into an array
                row_vals=()

                for ((i=0; i<columns_num; i++)); do
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
                                # reject values that are purely numeric
                                if [[ "$value" =~ ^-?[0-9]+$ ]]; then
                                    echo "Invalid input. String cannot be only digits."
                                    continue
                                fi
                                # separator check
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
                                echo "Unknown data type for column ${columns[i]}."
                                continue 2
                                ;;
                        esac

                        # if this is the primary key column, check uniqueness
                        if [[ $i -eq $PK_index ]]; then
                            # check for duplicate PK in existing data rows (data starts at NR>2)
                            exists=$(awk -F: -v col=$((PK_index+1)) -v val="$value" 'NR>2 && $col==val{print 1; exit}' "$DATA_FILE")
                            if [[ "$exists" == "1" ]]; then
                                echo "Primary key value '$value' already exists. Please enter a unique value."
                                continue
                            fi
                        fi

                        row_vals+=("$value")
                        break
                    done
                done

                # join row_vals with ':' and append to data file
                IFS=":"; record="${row_vals[*]}"; unset IFS
                echo "$record" >> "$DATA_FILE"

                echo "Data inserted successfully into $table_name."

                read -p "Do you want to insert another row? (yes/no): " another
                if [[ "$another" != "yes" && "$another" != "y" ]]; then
                    break
                fi
            done
    else
        # data file does not exist for this table
        echo "Table $table_name does not exist in database $DB_NAME."
    fi
}