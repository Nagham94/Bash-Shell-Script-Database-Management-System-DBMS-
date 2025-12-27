#!/bin/bash
updateTable() {
    DBDIR="Databases"
    echo "Enter the name of the table to update data in:"
    read table_name
    META_FILE="$DBDIR/$DB_NAME/$table_name.meta"
    DATA_FILE="$DBDIR/$DB_NAME/$table_name.data"
    
    if [ -f "$DATA_FILE" ]; then
        if [ ! -s "$DATA_FILE" ] || [ -z "$(grep -v '^[[:space:]]*$' "$DATA_FILE")" ]; then
            echo "Table $table_name is empty. There is no data to update."
            return
        fi

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
            echo "${columns[*]}" | sed 's/ /:/g'
            sep_line=""
            for ((j=0; j<columns_num; j++)); do
                sep_line+="---"
            done
            echo "$sep_line"
            current_record=$(awk -F: -v pk="$search_pk" '$1==pk' "$DATA_FILE")
            echo "$current_record"
            echo ""

            echo "What would you like to do?"
            echo "1. Update the entire record"
            echo "2. Update specific columns"
            read -p "Choose option (1 or 2): " update_option

            if [[ "$update_option" == "1" ]]; then
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

            elif [[ "$update_option" == "2" ]]; then
                IFS=':' read -ra current_values <<< "$current_record"
                record="$search_pk"

                echo ""
                echo "Available columns (excluding Primary Key):"
                col_num=1
                for ((i=1; i<columns_num; i++)); do
                    echo "$col_num. ${columns[i]} (${types[i]}) [Current: ${current_values[i]}]"
                    ((col_num++))
                done
                echo ""
                read -p "Enter the column numbers you want to update (space-separated, e.g., '1 3'): " -a columns_to_update

                for ((i=1; i<columns_num; i++)); do
                    found=0
                    for col_choice in "${columns_to_update[@]}"; do
                        if [[ "$col_choice" == "$((i))" ]]; then
                            found=1
                            break
                        fi
                    done
                    
                    if [[ $found -eq 1 ]]; then
                        while true; do
                            read -p "Enter new value for ${columns[i]} (${types[i]}) [Current: ${current_values[i]}]: " value

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
                    else
                        record+=":${current_values[i]}"
                    fi
                done

                sed -i "/^$search_pk:/c\\$record" "$DATA_FILE"
                echo "Data updated successfully in $table_name."
            else
                echo "Invalid option. Please choose 1 or 2."
                continue
            fi
            
            read -p "Do you want to update another row? (yes/no): " another
            if [[ "$another" != "yes" && "$another" != "y" ]]; then
                break
            fi
        done
    else
        echo "Table $table_name does not exist in database $DB_NAME."
    fi
}