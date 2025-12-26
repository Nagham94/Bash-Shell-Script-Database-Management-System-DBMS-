#!/bin/bash 
DBDIR="Databases"
NEWMENU_DIR="New_Menu"
MAINMENU_DIR="Main_Menu"

# Load table functions
source "$NEWMENU_DIR/createTable.sh"
source "$NEWMENU_DIR/listTables.sh"
#source "$NEWMENU_DIR/dropTable.sh"
source "$NEWMENU_DIR/insertIntoTable.sh"
#source "$NEWMENU_DIR/selectFromTable.sh"
#source "$NEWMENU_DIR/deleteFromTable.sh"
source "$NEWMENU_DIR/updateTable.sh"

connectDatabase() {
    echo "please enter the name of the Database you want to be connected to : "
    read DB_NAME

    if [[ -d "$DBDIR/$DB_NAME" ]]; then

        echo "connected to $DB_NAME Database successfully!"
        export CURRENT_DB="$DBDIR/$DB_NAME"

        echo "choose an option : "
        select choice in "Create Table" \
                         "List Tables" \
                         "Drop Table" \
                         "Insert Into Table" \
                         "Select From Table" \
                         "Delete From Table" \
                         "Update Table" \
                         "Back to Main Menu"
        do
            case $REPLY in
                1) echo "Create Table selected"
                   createTable ;;
                2) echo "List Tables selected"
                   listTables ;;
                #3) echo "Drop Table selected"
                #   dropTable ;;
                4) echo "Insert Into Table selected"
                   insertIntoTable ;;
                #5) echo "Select From Table selected"
                #   selectFromTable ;;
                #6) echo "Delete From Table selected"
                #   deleteFromTable ;;
                7) echo "Update Table selected"
                   updateTable ;;
                8) echo "Returning to Main Menu..."
                        return ;;
                *) echo "Invalid choice, try again" ;;
            esac
        done

    else
        echo "$DB_NAME Database doesn't exist! try again :)"
    fi
}

