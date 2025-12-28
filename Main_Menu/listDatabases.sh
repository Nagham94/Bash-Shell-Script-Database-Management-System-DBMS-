DBDIR="../Databases"

listDatabases(){
	cd "$DBDIR"
        echo "Available Databases:"
        if ls -d */ 1> /dev/null 2>&1; then
                ls -d */ | sed 's#/##' # Replace / with nothing -> Remove / from the end of the directories name
        else
                echo "No databases are found"
        fi
        cd ..
}

