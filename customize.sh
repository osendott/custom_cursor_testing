#!/bin/bash
################################################################################
#script will fully automate the theming & generation of cursor files
#written by: William Osendott
################################################################################

#set -x #remove this line before distribution, this tells the script to print
       #everything it does to the terminal. when it prints a variable, it will
       #print what the variable contains (instead just the variable name)
       #this makes it easier to debug the script.


# create /src directory in working directory
  mkdir $PWD/src/ #create /src directory first

# copy all files in .../default to .../src directory
  cp $PWD/default/. $PWD/src/ -R


#######
#INPUT#
####### Get hexcode from user to use as replacement for default color. This
      # could be expanded to edit outline color & grey color as well.

      # get user input, save in newColor variable
      read -p "New Color (as hex-code, default is #d64933:) " newColor

# if there's no new color supplied, use original color
if [ -z "$newColor" ]
  then
    echo "No color supplied, using default..."
    newColor=#d64933
fi


################################################################################


#######
#THEME#
####### This section will recolor all .svg files. Could use a config file in
      # order to avoid having to ask for any user input, but this is probably
      # easier.
      #
      # this could be greatly expanded. with .svg files, one could change
      # just about every aspect of them quite easily with bash as the .svg files
      # themselves are plain-text, so you would just have to find "outline" or
      # "stroke", etc. and then replace old value w/ new one. For this, we're
      # just going to look for a hex-code and replace with a different hex-code.

# this variable holds color to be replaced
  oldColor="#d64933"

#find all .svg files in & below current directory
#(~/script/.../.../...)
#replace old color code w/ new one, use values held in variables.
(cd $PWD/src;
	find . -type f -name '*.svg' -print0 | while IFS= read -r -d '' file; do

	if [[ `grep "$oldColor" "$file"` ]]; then
		echo "Replacing $oldColor with $newColor in $file"
		sed -i "s/$oldColor/$newColor/g" "$file"
	fi
done)
################################################################################


######
#PNGS#
###### Generate .png files from .svg files in /src/ dir

count=0 # counter, increments each time file is converted
        # could be removed as it's not needed, but I like to
        # let the user know something every now and again ;)

# open each .svg file in the /src directory, strip away just the filename
# then pass to inkscape to convert to .png using original filename
# increment counter, display total count at end of process
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



################################################################################


##########
#GENERATE#
########## Grab all .cursor files for /src/ directory, pass them through
         # xcursorgen to generate files.

counter=0 # counter, increments each time file is converted
          # could be removed as it's not needed, but I like to
          # let the user know something every now and again ;)
          # $PWD gets you the directory the script is being ran from

# set variable for which directory to cd into (xcursorgen problem w/o this)
# set directory to export generated files to
  CHANGEDIR=$PWD/src
  OUTDIR=$PWD/theme/Numix-Cursor/cursors

# for each .cursor file, strip away everything except the name of cursor
  for CURSOR in $PWD/src/*.cursor; do
    BASENAME=$CURSOR
    BASENAME=${BASENAME##*/}
    BASENAME=${BASENAME%.*}

# increment counter, change directories and generate cursors
  counter=$((count+1))
  (cd $CHANGEDIR;xcursorgen $BASENAME.cursor $OUTDIR/$BASENAME)

done


# let the user know what we've done
  echo "$counter file(s) generated"
  echo ""
  echo "removing /src directory..."
# remove the /src directory we created including all files inside
  rm -rf $PWD/src
  echo "...done"
  echo ""
  echo "installing cursors to ~/.icons/ directory..."

# copy new cursors to ~/.icons/ directory
	cp $PWD/theme/Numix-Cursor/. ~/.icons/Numix-Cursor/ -R
  echo "...done"
  echo ""
  echo "please use tweak-tool to set cursor theme to Numix-Cursor"


################################################################################
