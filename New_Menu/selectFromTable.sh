#!/bin/bash

selectFromTable() {

    [[ -z "$CURRENT_DB" ]] && { echo "No database selected"; return; }

    read -p "Enter table name: " table

    META="$CURRENT_DB/$table.meta"
    DATA="$CURRENT_DB/$table.data"

    [[ ! -f "$META" || ! -f "$DATA" ]] && { echo "Table does not exist"; return; }

    echo "Available columns:"
    awk -F: '{print NR ") " $1}' "$META"

    echo
    echo "Row selection:"
    echo "1) All rows"
    echo "2) By Primary Key(s)"
    read -p "Choice: " row_choice

    if [[ "$row_choice" == "2" ]]; then
        read -p "Enter PK values (comma-separated): " pk_list
    fi

    echo
    echo "Column selection:"
    echo "1) All columns"
    echo "2) Select column numbers"
    read -p "Choice: " col_choice

    if [[ "$col_choice" == "2" ]]; then
        read -p "Enter column numbers (e.g. 1,3): " col_nums
    fi

    # ---- PRINT HEADER ----
    if [[ "$col_choice" == "1" ]]; then
    	cut -d: -f1 "$META" | awk '{printf "%-15s", $1} END {print ""}'
    else
    	awk -F: -v cols="$col_nums" '
    	BEGIN { split(cols, c, ",") }
    	{
        	for (i in c)
            		if (NR == c[i])
                		printf "%-15s", $1
    	}	
    	END { print "" }
    	' "$META"
    fi

    echo "---------------------------------------------"

    # ---- PRINT DATA ----
    if [[ "$row_choice" == "1" ]]; then
        if [[ "$col_choice" == "1" ]]; then
         awk -F':' '{for(i=1;i<=NF;i++) printf "%-15s",$i; print ""}' "$DATA"

        else
            awk -F':' -v cols="$col_nums" '
            BEGIN { split(cols, c, ",") }
            {
                for (i in c)
                    printf "%-15s", $c[i]
                print ""
            }' "$DATA"
        fi
    else
        for pk in $pk_list; do
            if [[ "$col_choice" == "1" ]]; then
                awk -F':' -v pklist="$pk_list" '
		BEGIN {
			split(pklist, keys, ",")
		}
		{
    			for (k in keys) {
        			if ($1 == keys[k]) {
            				for (i=1; i<=NF; i++)
                				printf "%-15s", $i
            				print ""
        			}
    			}
		}
		' "$DATA"

            else
                awk -F':' -v pklist="$pk_list" -v cols="$col_nums" '
		BEGIN {
    			split(pklist, keys, ",")
    			split(cols, c, ",")
		}
		{
    			for (k in keys) {
        			if ($1 == keys[k]) {
            				for (i in c)
                				printf "%-15s", $c[i]
            				print ""
        			}
    			}
		}
		' "$DATA"

            fi
        done
    fi
}
