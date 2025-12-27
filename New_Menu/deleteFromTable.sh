#!/bin/bash

deleteFromTable() {

    if [[ -z "$CURRENT_DB" ]]; then
        echo "No database selected!"
        return
    fi

    echo "Enter table name:"
    read table

    META_FILE="$CURRENT_DB/$table.meta"
    DATA_FILE="$CURRENT_DB/$table.data"

    if [[ ! -f "$META_FILE" || ! -f "$DATA_FILE" ]]; then
        echo "Table does not exist!"
        return
    fi

    if [[ ! -s "$DATA_FILE" ]]; then
        echo "Table is empty"
        return
    fi

    read -p "Enter Primary Key value to delete: " pk

    # Check if record exists
    if ! awk -F':' -v key="$pk" '$1 == key {found=1} END{exit !found}' "$DATA_FILE"
    then
        echo "Record not found"
        return
    fi

    echo "Are you sure you want to delete this record? (y/n)"
    read confirm
    [[ "$confirm" != "y" ]] && echo "Deletion cancelled" && return

    # Delete record safely
    awk -F':' -v key="$pk" '$1 != key' "$DATA_FILE" > "$DATA_FILE.tmp"
    mv "$DATA_FILE.tmp" "$DATA_FILE"

    echo "Record deleted successfully"
}

