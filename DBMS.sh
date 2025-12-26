#!/bin/bash

echo "Main Menu:"
echo "1) Create Database"
echo "2) List Database"
echo "3) Connect To Databases"
echo "4) Drop Database"

read -p "Choose an option: " choice

source "./Main_Menu/connectDatabase.sh"
source "./Main_Menu/dropDatabase.sh"
source "./Main_Menu/createDatabase.sh"
source "./Main_Menu/listDatabase.sh" 

case $choice in
	1) create_database
		createDatabase ;;
	2) list_database
		listDatabase ;;
	3) connect_database
		connectDatabase ;;
	4) drop_database
		dropDatabase ;;
esac
