#!/bin/bash

# base directory for databases
DBDIR="Databases"
# directory containing table operation scripts
NEWMENU_DIR="New_Menu"
# directory containing main menu scripts
MAINMENU_DIR="Main_Menu"

# load all table-related functions from their respective script files
source "$NEWMENU_DIR/createTable.sh"
source "$NEWMENU_DIR/listTables.sh"
source "$NEWMENU_DIR/dropTable.sh"
source "$NEWMENU_DIR/insertIntoTable.sh"
source "$NEWMENU_DIR/selectFromTable.sh"
source "$NEWMENU_DIR/deleteFromTable.sh"
source "$NEWMENU_DIR/updateTable.sh"

connectDatabase() {
    # loop to allow database selection retry on failure
    while true; do
        # ask user for the database name to connect to
        echo "please enter the name of the Database you want to be connected to : "
        read DB_NAME

        # check if the database directory exists
        if [[ -d "$DBDIR/$DB_NAME" ]]; then

            # confirm successful connection
            echo "connected to $DB_NAME Database successfully!"
            # set environment variable for the current database (used by table functions)
            export CURRENT_DB="$DBDIR/$DB_NAME"

            # loop to keep displaying table operations menu
            while true; do
                # display menu of table operations
                echo "choose an option : "
                # use select to create a numbered menu for user selection
                select choice in "Create Table" \
                                 "List Tables" \
                                 "Drop Table" \
                                 "Insert Into Table" \
                                 "Select From Table" \
                                 "Delete From Table" \
                                 "Update Table" \
                                 "Back to Main Menu"
                do
                    # execute the selected operation based on user choice
                    case $REPLY in
                        1) echo "Create Table selected"
                           createTable ;;
                        2) echo "List Tables selected"
                           listTables ;;
                        3) echo "Drop Table selected"
                           dropTable ;;
                        4) echo "Insert Into Table selected"
                           insertIntoTable ;;
                        5) echo "Select From Table selected"
                           selectFromTable ;;
                        6) echo "Delete From Table selected"
                           deleteFromTable ;;
                        7) echo "Update Table selected"
                           updateTable ;;
                        8) echo "Returning to Main Menu..."
                                return ;;
                        *) echo "Invalid choice, try again" ;;
                    esac
                    # break select loop after each operation to re-display menu
                    break
                done
            done

            # exit the database selection loop after successful operations
            break

        else
            # database does not exist, allow retry
            echo "$DB_NAME Database doesn't exist! try again :)"
        fi
    done
}

