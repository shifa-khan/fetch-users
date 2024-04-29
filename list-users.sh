#!/bin/bash

###########
# About: This script is used for fetching usernames of members of a GitHub organization using an API call
# Input parameters:
# Before running the script export the username and token
# export="username"
# export="token"
###########

# Help function
function print_help {
  if [ $# -eq 0 ]; then
    echo "Please provide two arguments: organization name and repository name."
    echo "Usage: ./script.sh org-name repo-name"
    exit 1
  fi
}

# Call the help function
print_help "$@"

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME="$username"
TOKEN="$token"

# User and Repository information
REPO_OWNER="$1"
REPO_NAME="$2"

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch the list of collaborators on the repository
    response=$(github_api_get "$endpoint")
    if [ $? -ne 0 ]; then
        echo "Error fetching collaborators."
        exit 1
    fi

    # Check if the response is empty or not in expected format
    if [ -z "$response" ] || [ "$(echo "$response" | jq '.message')" != "null" ]; then
        echo "Error: Unable to fetch collaborators. Please check if the repository exists and you have permissions."
        exit 1
    fi

    # Parse the response to get the list of collaborators with read access
    collaborators=$(echo "$response" | jq -r '.[].login')

    # Display the list of collaborators with read access
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# Main script

echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
