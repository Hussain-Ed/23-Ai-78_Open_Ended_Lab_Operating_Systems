#!/bin/bash

LAB_DIR="$HOME/lab_users"
ARCHIVE_DIR="$HOME/archives"

mkdir -p "$LAB_DIR"
mkdir -p "$ARCHIVE_DIR"

# ---------------- MENU ----------------
while true
do
    echo "=================================="
    echo "     USER WORKSPACE MANAGER"
    echo "=================================="
    echo "1. Create new user workspace"
    echo "2. Set disk quota warning (simulated)"
    echo "3. Search file in all workspaces"
    echo "4. Archive inactive workspaces"
    echo "5. Exit"
    echo "=================================="
    read -p "Enter choice: " choice

    # ---------------- OPTION 1 ----------------
    if [ "$choice" -eq 1 ]; then
        read -p "Enter username: " user

        USER_DIR="$LAB_DIR/$user"

        mkdir -p "$USER_DIR/docs" "$USER_DIR/code" "$USER_DIR/shared"

        # permissions: user + admin only
        chmod 700 "$USER_DIR"

        echo "Workspace created for $user at $USER_DIR"
    fi

    # ---------------- OPTION 2 ----------------
    if [ "$choice" -eq 2 ]; then
        read -p "Enter username: " user

        USER_DIR="$LAB_DIR/$user"

        if [ -d "$USER_DIR" ]; then
            SIZE=$(du -sm "$USER_DIR" | awk '{print $1}')

            echo "Current size: ${SIZE}MB"

            if [ "$SIZE" -gt 100 ]; then
                echo "⚠ WARNING: Quota exceeded (Simulated 100MB limit)"
            else
                echo "✔ Within quota limit"
            fi
        else
            echo "User workspace not found"
        fi
    fi

    # ---------------- OPTION 3 ----------------
    if [ "$choice" -eq 3 ]; then
        read -p "Enter filename or extension (e.g. .py): " pattern

        echo "Searching for: $pattern"
        echo "----------------------------------"

        find "$LAB_DIR" -type f -name "$pattern" -exec ls -lh {} \; | awk '{print $9, $5, $6, $7, $8}'
    fi

    # ---------------- OPTION 4 ----------------
    if [ "$choice" -eq 4 ]; then

        echo "Checking inactive workspaces..."

        for user_path in "$LAB_DIR"/*
        do
            if [ -d "$user_path" ]; then

                LAST_MOD=$(find "$user_path" -type f -mtime -60 | wc -l)

                USERNAME=$(basename "$user_path")

                if [ "$LAST_MOD" -eq 0 ]; then

                    TAR_FILE="$ARCHIVE_DIR/${USERNAME}_archive.tar.gz"

                    tar -czf "$TAR_FILE" -C "$LAB_DIR" "$USERNAME"

                    echo "Archived: $USERNAME -> $TAR_FILE"

                    read -p "Delete original workspace? (y/n): " confirm

                    if [ "$confirm" == "y" ]; then
                        rm -rf "$user_path"
                        echo "Deleted $USERNAME workspace"
                    else
                        echo "Kept $USERNAME workspace"
                    fi

                fi
            fi
        done
    fi

    # ---------------- EXIT ----------------
    if [ "$choice" -eq 5 ]; then
        echo "Exiting Workspace Manager..."
        break
    fi

done
