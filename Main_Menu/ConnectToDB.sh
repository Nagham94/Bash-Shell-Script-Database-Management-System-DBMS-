#!/bin/bash  
echo "please enter the name of the Database you want to be connected to : "
read DB_name

if [ -d "./databases/$DB_name" ];
then
   
	echo "connected to $DB_name Database successfully!"
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
					                         ./CreateTable.sh "$DB_name" ;;
                                     2) echo "List Tables selected"
					                         ./New_menu/ListTables.sh "$DB_name" ;;
                                     3) echo "Drop Table selected"
					                         ./DropTable.sh "$DB_name" ;;
                                     4) echo "Insert Into Table selected"
				                         	 ./InsertTable.sh "$DB_name" ;;
                                     5) echo "Select From Table selected" 
					                         ./SelectTable.sh "$DB_name" ;;
                                     6) echo "Delete From Table selected"
					                         ./DeleteFromTable.sh "$DB_name" ;;
                                     7) echo "Update Table selected"
					                         ./UpdateTable.sh "$DB_name" ;;
                                     8) echo "Returning to Main Menu..."
                                        break ;;
                                     *) echo "Invalid choice, try again" ;;
                                 esac
        done

else
	echo "$DB_name Database doesn't exist! try again :)"
fi

