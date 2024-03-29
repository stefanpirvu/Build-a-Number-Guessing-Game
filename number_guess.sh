#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

show_number_guess_script() {

    echo "Enter your username:"
    read USERNAME

    USER_ID=$($PSQL "SELECT u_id FROM users WHERE name = '$USERNAME'")

    if [[ $USER_ID ]]; then
        GAMES_PLAYED=$($PSQL "SELECT COUNT(u_id) FROM games WHERE u_id = '$USER_ID'")
        BEST_GUESS=$($PSQL "SELECT MIN(guesses) FROM games WHERE u_id = '$USER_ID'")
        echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
    else
        echo "Welcome, $USERNAME! It looks like this is your first time here."
        INSERTED_TO_USERS=$($PSQL "INSERT INTO users(name) VALUES ('$USERNAME')")
        USER_ID=$($PSQL "SELECT u_id FROM users WHERE name = '$USERNAME'")
    fi

    game "$USER_ID"
}

game() {
    SECRET=$((1 + $RANDOM % 1000))
    TRIES=0
    GUESSED=0
    echo "Guess the secret number between 1 and 1000:"

    while [[ $GUESSED = 0 ]]; do
        read GUESS

        if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
            echo "That is not an integer, guess again:"
        elif [[ $SECRET = $GUESS ]]; then
            TRIES=$((TRIES + 1))
            echo "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
            INSERTED_TO_GAMES=$($PSQL "INSERT INTO games(u_id, guesses) VALUES ($1, $TRIES)")
            GUESSED=1
        elif [[ $SECRET -gt $GUESS ]]
            then
                TRIES=$((TRIES + 1))
                echo "It's higher than that, guess again:"
        else
                TRIES=$((TRIES + 1))
                echo "It's lower than that, guess again:"
        fi
    done
}

show_number_guess_script
