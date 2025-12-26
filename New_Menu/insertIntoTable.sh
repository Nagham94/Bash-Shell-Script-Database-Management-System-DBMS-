#!/bin/bash
insertIntoTable() {
DBDIR="Databases"
echo "enter the name of the table to insert data into:"
read table_name
META_FILE="$DBDIR/$DB_NAME/$table_name.meta"
DATA_FILE="$DBDIR/$DB_NAME/$table_name.data"
if [ -f "$DATA_FILE" ]; then
    columns=($(awk -F: '{print $1}' "$META_FILE"))
    types=($(awk -F: '{print $2}' "$META_FILE"))
    PK_index=$(awk -F: '{if($3=="PK") print NR-1}' "$META_FILE")
    columns_num=${#columns[@]}

    if [ ! -s "$DATA_FILE" ]; then
        echo "${columns[*]}" | sed 's/ /:/g' >> "$DATA_FILE"

        sep_line=""
        for ((j=0; j<columns_num; j++)); do
            sep_line+="---"
        done
        echo "$sep_line" >> "$DATA_FILE"
 
        new_pk=1
    else
        last_pk=$(awk -F: 'END {print $1}' "$DATA_FILE")
        new_pk=$((last_pk + 1))
    fi

    while true; do
        record="$new_pk"
        
        for ((i=1; i<columns_num; i++)); do
        while true; do
            read -p "Enter value for ${columns[i]} (${types[i]}): " value

            case "${types[i]}" in
                int)
                    if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                        echo "Invalid input. Please enter an integer."
                        continue
                    fi
                    ;;
                string)
                    if [[ -z "$value" ]]; then
                        echo "Invalid input. Please enter a non-empty string."
                        continue
                    fi
                    ;;
                bool)
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

            record+=":$value"
            break
        done
        done

    echo "$record" >> "$DATA_FILE"

    echo "Data inserted successfully into $table_name."
        
        read -p "Do you want to insert another row? (yes/no): " another
        if [[ "$another" != "yes" && "$another" != "y" ]]; then
            break
        fi
        new_pk=$((new_pk + 1))
    done
else
    echo "Table $table_name does not exist in database $DB_NAME."
fi
}