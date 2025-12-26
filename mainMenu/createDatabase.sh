createDatabase() {
        read -p "Enter Database Name: " db_name

        if [[ ! "$db_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "Invalid database name!"
                return
        fi

        # Check if database already exists
        if [[ -d "$db_name" ]]; then
                echo "Database '$db_name' already exists!"
        else
                mkdir "$db_name"
                echo "Database '$db_name' created successfully"
        fi
}

