# Custom Cursors v1.0-1
# Script by: William Osendott
# Graphics by: uloco
#
######################################################

# variables [newColor & oldColor to be set w/ menu choices]
newColor="1793d0"
oldColor="d64933"
count=0
counter=0
CHANGEDIR=$PWD/src
OUTDIR=$PWD/theme/custom_cursors/cursors

# functions
startup(){ # extract files needed
  tar -xzf src.tar.gz
  tar -xzf theme.tar.gz
}

change_color(){ # function to change color, call for each color to be changed
  (cd $PWD/src;
  	find . -type f -name '*.svg' -print0 | while IFS= read -r -d '' file; do

  	if [[ `grep "$oldColor" "$file"` ]]; then
  		echo "Replacing $oldColor with $newColor in $file"
  		sed -i "s/$oldColor/$newColor/g" "$file"
  	fi
  done)
wait
echo "$oldColor replaced with $newColor"
}

create_png(){ # generate .png files from the .svg's
for fileSource in $PWD/src/*.svg
  do
    if [ -f "$fileSource" ]; then
      count=$((count+1))
      file=$(echo $fileSource | cut -d'.' -f1)
      echo "$count". "$fileSource" -> "$file.png"
      inkscape $fileSource --export-png=$file.png --export-dpi=90
    else
      echo "no file $fileSource found!"
    fi
done

echo "$count file(s) converted"
}

generate_cursors(){ # generate xmc files from .cursor & .png files

for CURSOR in $PWD/src/*.cursor; do
  BASENAME=$CURSOR
  BASENAME=${BASENAME##*/}
  BASENAME=${BASENAME%.*}

# increment counter, change directories and generate cursors
counter=$((count+1))
(cd $CHANGEDIR;xcursorgen $BASENAME.cursor $OUTDIR/$BASENAME)

done

echo "$counter file(s) generated"
}

cleanup(){ # install theme, remove unsused files
cp $PWD/theme/custom_cursor/. ~/.icons/custom-cursor/ -R
wait
rm -rf $PWD/src
rm -rf $PWD/theme
wait
echo "theme installed, source files removed. use tweak-tool to change cursors"
}

title="Please select and option:"
prompt="option:"
options=("Change" "Default" "Manual" "Load")

echo "$title"
base="$prompt "
select opt in "${options[@]}" "Quit"; do

    case "$REPLY" in

    1 ) echo "$opt - get new color, change it" ;; #set the color variable and end loop, resume previous script after this.
    2 ) echo "$opt - use default colors, generate" ;; #
    2 ) echo "$opt - extract files for manual editing, end" ;; #
    2 ) echo "$opt - skip extracting files, use existing" ;; #

    $(( ${#options[@]}+1 )) ) echo "Quitting..."; break;;
    *) echo "Invalid option, try again.";continue;;

    esac

done
