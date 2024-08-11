#!/bin/sh

# POSIX-compliant Snake Game 
# Use WASD to move, Q to quit

# Initialize variables
width=20
height=10

# snake head x y position
x=$((width / 2))
y=$((height / 2))

# snake body parts x y positions excluding head
snake_body_parts=""

food_x=0
food_y=0
dx=1
dy=0
score=0
game_over=0

# Function to generate random number between 0 and n-1
random() {
    awk -v n="$1" 'BEGIN{srand(); print int(rand()*n)}'
}

# Function to spawn food
spawn_food() {
    food_x=$(random $width)
    food_y=$(random $height)
}

# Spawn initial food
spawn_food

# Function to draw the game board
draw_board() {
    clear

    for i in $(seq 0 $((height - 1))); do
        for j in $(seq 0 $((width - 1))); do
            if [ $i -eq $y ] && [ $j -eq $x ]; then
                printf "X"
            # elif echo "$snake_body_parts" | grep -q -w "$j,$i"; then
            #     printf "o"
            elif is_body_part $j $i; then
                printf "o"
            elif [ $i -eq $food_y ] && [ $j -eq $food_x ]; then
                printf "*"
            else
                printf "."
            fi
        done
        printf "\n"
    done
    printf "Score: %d\n" "$score"
    printf "$snake_body_parts $body_part_count\n"
}

# Function to check if a coordinate is part of the snake's body
is_body_part() {
    case " $snake_body_parts " in
        *" $1,$2 "*) return 0 ;;
        *) return 1 ;;
    esac
}

remove_first_item() {
    # arg comprehension removes the first item from a string
    set -- $1
    shift
    echo "$*"
}

update_snake() {
    # Update snake head position
    prev_x=$x
    prev_y=$y
    x=$((x + dx))
    y=$((y + dy))

    # Check for collisions with walls
    if [ $x -lt 0 ] || [ $x -ge $width ] || [ $y -lt 0 ] || [ $y -ge $height ]; then
        game_over=1
    fi

    # check for collision with body parts
    if echo "$snake_body_parts" | grep -q -w "$x,$y"; then
        game_over=1
    fi

    # Check if food is eaten
    if [ $x -eq $food_x ] && [ $y -eq $food_y ]; then
        score=$((score + 1))
        spawn_food
    fi

    # lets just update the body parts
    snake_body_parts="$snake_body_parts $prev_x,$prev_y"

    # check for how many body parts there are
    # if we're below the score, we can add a body part
    # otherwise we want to remove the last body part
    body_parts_count=$(echo $snake_body_parts | wc -w)
    if [ $body_parts_count -gt $score ]; then
        # snake_body_parts=$(echo $snake_body_parts | cut -d' ' -f2-)
        snake_body_parts=$(remove_first_item "$snake_body_parts")
    fi
}

# Main game loop
while [ $game_over -eq 0 ]; do
    draw_board

    # Read user input (with a timeout)
    read -t 0.1 -n 1 key

    # Update direction based on input
    case $key in
        w) dy=-1; dx=0 ;;
        s) dy=1; dx=0 ;;
        a) dx=-1; dy=0 ;;
        d) dx=1; dy=0 ;;
        q) game_over=1 ;;
    esac

    update_snake
    
done

printf "Game Over! Final Score: %d\n" "$score"
