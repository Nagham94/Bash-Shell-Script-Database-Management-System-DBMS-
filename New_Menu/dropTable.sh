#!/bin/bash

dropTable() {
    read -p "Enter table name: " TABLE_NAME

    if [[ ! -f "$CURRENT_DB/$TABLE_NAME.data" ]]; then
        echo "Table does not exist"
        return
    fi

   rm "$CURRENT_DB/$TABLE_NAME.data" "$CURRENT_DB/$TABLE_NAME.meta"
 
    echo "Table '$TABLE_NAME' deleted successfully"
}

