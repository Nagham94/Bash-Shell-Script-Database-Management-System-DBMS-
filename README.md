# Bash Shell Script Database Management System (DBMS)

## Project Description

This is a file-based Database Management System (DBMS) implemented entirely in Bash shell script. It provides a command-line interface for users to create, manage, and manipulate databases and tables without requiring a traditional database server like MySQL or PostgreSQL. The system stores data in plain text files with colon-delimited format, making it easy to understand and debug.

### Features

- **Database Management:** Create, connect to, and delete databases
- **Table Operations:** Create, list, and drop tables with metadata support
- **Data Manipulation:** Insert, select, update, and delete records with type validation
- **Type Safety:** Built-in validation for `int`, `string`, and `bool` data types
- **Primary Key Support:** uniqueness enforcement
- **Data Integrity:** Protection against invalid input and separator characters

---

## Menu Structure

### Main Menu Options

The Main Menu is the entry point for the DBMS. It provides the following options:

1. **Create Database**
   - Prompts the user to enter a new database name
   - Creates a new directory under `Databases/` to store the database and its tables
   - Validates that the database name is unique

2. **List Databases**
   - Displays all existing databases in the `Databases/` directory
   - Shows a list of available databases the user can connect to

3. **Connect to Database**
   - Prompts the user to select an existing database
   - Allows retry if database name doesn't exist (loop-based selection)
   - Establishes a connection to the database and loads the Table Menu
   - Sets the current database context for subsequent table operations
   - Returns to Main Menu when done with table operations

4. **Drop Database**
   - Prompts the user to select a database to delete
   - Requires confirmation before deletion to prevent accidental data loss
   - Permanently removes the database directory and all its contents

---

### Table Menu Options (New Menu)

Once connected to a database, users access the Table Menu which provides the following operations:

1. **Create Table**
   - Prompts user to define a new table with column names and data types
   - Supports `int`, `string`, and `bool` data types
   - Requires designating one column as the Primary Key (PK)
   - Stores table metadata in a `.meta` file and initializes an empty `.data` file

2. **List Tables**
   - Displays all tables in the currently connected database
   - Shows table names extracted from `.data` files in the database directory

3. **Drop Table**
   - Prompts user to select a table to delete
   - Removes both the `.meta` (metadata) and `.data` (data) files for the table
   - Requires confirmation to prevent accidental deletion

4. **Insert Into Table**
   - Prompts user to enter a Primary Key value (int or string type)
   - User must provide the PK explicitly (no auto-increment)
   - Validates input based on the defined data type
   - For `string` Primary Keys: must not be purely numeric
   - Enforces Primary Key uniqueness (rejects duplicate PKs)
   - Prompts for remaining column values with type validation
   - Supports multiple inserts in a single session

5. **Select From Table**
   - Retrieves and displays all rows from a selected table
   - Shows data in a formatted, readable table structure
   - Displays column headers and separators for clarity

6. **Delete From Table**
   - Prompts user to search for a record by Primary Key
   - Displays the matching record for confirmation
   - Removes the selected row from the table
   - Prevents deletion of non-existent records

7. **Update Table**
   - Offers two update modes:
     - **Option 1:** Update all columns (including Primary Key) in a record at once
     - **Option 2:** Update only selected columns while preserving others
   - Prompts user to search for a record by Primary Key
   - Allows updating the Primary Key to a new value (with validation and uniqueness checks)
   - Validates all input according to data type rules
   - For `string` Primary Keys: must not be purely numeric
   - Prevents duplicate Primary Keys
   - Supports multiple updates in a single session

8. **Back to Main Menu**
   - Disconnects from the current database
   - Returns to the Main Menu for database-level operations

---

## Data Storage Format

- **Databases:** Stored as directories under `Databases/`
- **Table Metadata (`.meta`):** Colon-delimited file with column names, types, and Primary Key designation
  - Format: `column_name:data_type:PK`
- **Table Data (`.data`):** Colon-delimited file with actual record values
  - Format: `pk_value:column1_value:column2_value:...`
  - First line contains column headers
  - Second line contains separator dashes (`---:---:---`)
  - Subsequent lines contain data records

---

## Type Validation Rules

### Integer (`int`)
- Must not be empty
- Must be numeric (positive or negative)
- Regex (non-PK): `^-?[0-9]+$` | Regex (PK): `^[1-9][0-9]*$`

### String (`string`)
- Must not be empty
- Cannot contain colon (`:`) characters (reserved as delimiter)
- Cannot be purely numeric (e.g., "123" is rejected, but "abc123" is allowed)
- Any alphanumeric or special characters (except `:`) are allowed

### Boolean (`bool`)
- Must not be empty
- Must be exactly `true` or `false` (case-sensitive)

---

## Recent Changes

### Version Updates

- **Primary Key Management:** Removed auto-increment; users now explicitly enter PK values
  - PK values must match the defined type (int or string)
  - String PKs must not be purely numeric
  - Uniqueness is enforced across all records

- **Update Operations:** 
  - Same validation and uniqueness rules apply as for Insert operations
  - Prevents duplicate PKs while allowing existing value to remain unchanged

- **Input Validation:** Enhanced with detailed comments
  - All validation blocks now include inline comments explaining each check
  - Consistent validation across Insert and Update operations

- **Database Connection:** Improved retry mechanism
  - Users can retry entering database name if it doesn't exist
  - Table Menu loops to allow multiple operations without returning to Main Menu

---

```bash
# Run the main DBMS script
source ./DBMS.sh

# Follow the menu prompts to:
# 1. Create a database
# 2. Connect to it
# 3. Create tables
# 4. Insert, select, update, or delete data
```

---

## Project Structure

```
bash_project/
├── DBMS.sh                  # Main entry point
├── README.md                # This file
├── Databases/               # Directory containing all databases
│   ├── DB1/                # Sample database 1
│   ├── DB2/                # Sample database 2
│   └── school/             # Sample school database
├── Main_Menu/              # Database-level operations
│   ├── createDatabase.sh
│   ├── listDatabases.sh
│   ├── connectDatabase.sh
│   └── dropDatabase.sh
└── New_Menu/               # Table-level operations
    ├── createTable.sh
    ├── listTables.sh
    ├── dropTable.sh
    ├── insertIntoTable.sh
    ├── selectFromTable.sh
    ├── deleteFromTable.sh
    └── updateTable.sh
```