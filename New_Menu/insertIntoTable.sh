#!/bin/bash
insertIntoTable() {
echo "enter the name of the table to insert data into:"
read table_name
DBDIR="Databases"
if [ -f "$DBDIR/$DB_NAME/$table_name.data" ]; then
    columns=($(awk -F: '{print $1}' "$DBDIR/$DB_NAME/$table_name.meta"))
    types=($(awk -F: '{print $2}' "$DBDIR/$DB_NAME/$table_name.meta"))
    PK_index=$(awk -F: '{if($3=="PK") print NR-1}' "$DBDIR/$DB_NAME/$table_name.meta")
    columns_num=0
    
    echo "Data inserted successfully into $table_name."
else
    echo "Table $table_name does not exist in database $DB_NAME."
fi
}