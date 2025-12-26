#!/bin/bash
updateTable() {
    DBDIR="Databases"
    echo "Enter the name of the table to update data in:"
    read table_name
    META_FILE="$DBDIR/$DB_NAME/$table_name.meta"
    DATA_FILE="$DBDIR/$DB_NAME/$table_name.data"
    
    if [ -f "$DATA_FILE" ]; then
        columns=($(awk -F: '{print $1}' "$META_FILE"))
        types=($(awk -F: '{print $2}' "$META_FILE"))
        PK_index=$(awk -F: '{if($3=="PK") print NR-1}' "$META_FILE")
        columns_num=${#columns[@]}

        while true; do
            echo "Enter the Primary Key (${columns[0]}) of the row to update: "
            read search_pk

            if ! awk -F: -v pk="$search_pk" '$1==pk' "$DATA_FILE" | grep -q .; then
                echo "No record found with Primary Key: $search_pk"
                continue
            fi

            echo "Current record:"
            awk -F: -v pk="$search_pk" '$1==pk' "$DATA_FILE"
            echo ""

            record="$search_pk"
            
            for ((i=1; i<columns_num; i++)); do
                while true; do
                    read -p "Enter new value for ${columns[i]} (${types[i]}): " value

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

            sed -i "/^$search_pk:/c\\$record" "$DATA_FILE"
            echo "Data updated successfully in $table_name."
            
            read -p "Do you want to update another row? (yes/no): " another
            if [[ "$another" != "yes" && "$another" != "y" ]]; then
                break
            fi
        done
    else
        echo "Table $table_name does not exist in database $DB_NAME."
    fi
}