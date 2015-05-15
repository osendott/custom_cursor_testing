#!/bin/bash

# start menu for custom-cursors
# I considered using Zenity and have a proper-ish GUI menu for at least this part
# but I get warnings in my terminal, nothing major or even problematic, but it
# looks ugly, and honestly I'm more comfortable doing it this way. Perhaps in the 
# future I'll give the Zenity way another shot, it does look nice having proper dialogs


# light/dark 
title="Select Cursor-Base"
prompt="chosen"
options=("Light" "Dark")

echo "$title"
base="$prompt "
select opt in "${options[@]}" "Quit"; do 

    case "$REPLY" in

    1 ) echo "command to generate $opt theme goes here" ;; #light theme chosen, remember to end loop after
    2 ) echo "command to generate $opt theme goes here" ;; #dark theme chosen, remember to end loop after
    
    $(( ${#options[@]}+1 )) ) echo "Quitting..."; break;;
    *) echo "Invalid option, try again.";continue;;

    esac

done

# display color choices
title="Select color for cursors"
prompt="color"
options=("Orange" "Blue" "Purple" "Custom")

echo "$title"
base="$prompt "
select opt in "${options[@]}" "Quit"; do 

    case "$REPLY" in

    1 ) echo "$opt - newColor=#code" ;; #set the color variable and end loop, resume previous script after this.
    2 ) echo "$opt - newColor=#code" ;; #
    2 ) echo "$opt - newColor=#code" ;; #
    2 ) echo "$opt - newColor=#code" ;; #

    $(( ${#options[@]}+1 )) ) echo "Quitting..."; break;;
    *) echo "Invalid option, try again.";continue;;

    esac

done
