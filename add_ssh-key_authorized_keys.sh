#!/bin/bash

echo "SSH Key Adder for Termux"
echo "========================"

# Create directory if not exists
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Create authorized_keys if not exists
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

echo "Please paste your public SSH key and press Ctrl+D:"
cat >> ~/.ssh/temp_key.pub

# Validate the key
if grep -q "ssh-" ~/.ssh/temp_key.pub; then
    # Ask for key description with validation
    while true; do
        echo ""
        echo "Please enter a description for this key (e.g., 'laptop', 'work_pc', 'user_john'):"
        read key_description
        
        if [ -n "$key_description" ]; then
            break
        else
            echo "❌ Description cannot be empty. Please try again."
        fi
    done
    
    # Add the key with description to authorized_keys
    echo "# Added: $(date) - $key_description" >> ~/.ssh/authorized_keys
    cat ~/.ssh/temp_key.pub >> ~/.ssh/authorized_keys
    echo "" >> ~/.ssh/authorized_keys
    
    echo "✅ SSH key added successfully with description: '$key_description'!"
    rm ~/.ssh/temp_key.pub
else
    echo "❌ Invalid SSH key format!"
    rm ~/.ssh/temp_key.pub
    exit 1
fi

echo ""
echo "Current authorized keys:"
echo "========================="
cat ~/.ssh/authorized_keys