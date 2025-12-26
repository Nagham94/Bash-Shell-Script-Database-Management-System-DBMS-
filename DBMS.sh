#!/bin/bash

#source createDatabase.sh
#source dropDatabase.sh
DBDIR="Databases" 
NEWMENU_DIR="New_Menu"
MAINMENU_DIR="Main_Menu"

source "$MAINMENU_DIR/createDatabase.sh"
source "$MAINMENU_DIR/listDatabases.sh"
source "$MAINMENU_DIR/connectDatabase.sh"
source "$MAINMENU_DIR/dropDatabase.sh"

while true; 
do
	echo "Main Menu:"
	echo "1) Create Database"
	echo "2) List Database"
	echo "3) Connect To Databases"
	echo "4) Drop Database"
	echo "5) Exit"

	read -p "Choose an option: " choice

	case $choice in
		1) createDatabase
			;;
		2) listDatabases
			;;
		3) connectDatabase
			;;
		4) dropDatabase
			;;
		5) exit 0
			;;
	esac
done
