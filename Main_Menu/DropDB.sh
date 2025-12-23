echo "please Enter the Name of the DB to delete:"
read dbname
if [ -d "databases/$dbname" ]
then
    echo "Are you sure you want to delete the database '$dbname'? (y/n)"
    read confirmation
    if [ "$confirmation" != "y" ]; then
        echo "Database deletion canceled."
        exit 0
    fi
    echo "Deleting database..."
    rm -r "databases/$dbname"
    echo "Database deleted successfully"
else
    echo "Database not found"
fi
