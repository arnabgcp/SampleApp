#!/bin/bash

# A script to set up the environment and run the Flask application.

# Exit immediately if a command exits with a non-zero status.
set -e

# Ensure the script is run from the project root directory where run.py is located.
if [ ! -f "run.py" ]; then
    echo "Error: This script must be run from the project root directory."
    exit 1
fi

echo "--- Setting up virtual environment ---"
# Create a virtual environment directory named 'venv' if it doesn't exist.
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate the virtual environment.
source venv/bin/activate

echo "--- Installing dependencies ---"
# Install dependencies from requirements.txt if the file exists.
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "Warning: 'requirements.txt' not found. Skipping dependency installation."
    echo "It is recommended to have a requirements.txt file."
fi

echo "--- Exporting environment variables ---"
# Export variables from the .env file.
ENV_FILE="instance/.env"
if [ -f "$ENV_FILE" ]; then
    # `export $(...)` exports the variables to the current shell.
    # The sed command handles comments and empty lines.
    export $(grep -v '^#' "$ENV_FILE" | xargs)
    echo "Environment variables from $ENV_FILE have been exported."
else
    echo "Warning: $ENV_FILE not found. The application might not connect to the database."
fi

echo "--- Starting the application ---"
# Run the application.
python run.py