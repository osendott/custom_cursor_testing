#############################################
# noname-cursors v0.9.8 rewrite 17 MAY 2015 #
# by: William Osendott  & Umut Topuzoglu    #
#############################################

# copy dialogrc to ~/.dialogrc to control colors of script

# set -x # uncomment this if you wanna see what's going on line-by-line, remove before distribution

#############
# variables # variables will be set by script @ runtime, this is just a list. BASH doesn't require you to declare variables.
#############
choice="" # light/dark response (same as $retval below)
tmpColor="" # hold user color choice @ menu
newColor="" # theme color to replace Default
usrColor="" # custom color from dialog
count="" # counter
CHANGEDIR=$PWD/src # change to source directory in sub-shell
OUTDIR=$PWD/theme/custom_cursors/cursors # where to generate files
oldColor="#d64933" # default color for cursors
retval="" # dialog uses stderr to output which button is pressed. this variable copies it, to be read & decide which button pressed (0 yes, 1 no)
colorCount="" # count of svg files in directory
pngCount="" # count of png files in directory
curCount="" # count of .cursor files in directory

# extract source files
tar -xzf src.tar.gz
tar -xzf theme.tar.gz
wait

# light/dark menu
dialog --yes-label "light" --no-label "dark" --yesno "Please choose base:" 5 25

choice=$?

case $choice in # read $choice, see which button pressed
	# no (labeled as DARK in this script)
	1) 
	colorCount=`ls -1 $PWD/src/*.svg 2>/dev/null | wc -l` # count number of svg files
	(cd $PWD/src;
        	find . -type f -name '*.svg' -print0 | while IFS= read -r -d '' file; do
          sed -i 's/#e8e8e8/#ff0000/g;s/#2d2d2d/#e8e8e8/g;s/#ff0000/#2d2d2d/g;s/#ffffff/#000000/g' "$file"
          wait
          count=$((count+1))
          dialog --title '' --infobox "Creating dark base $count of $colorCount"  3 50
        done)
        wait ;;
esac

get_Color() # function created to loop display of dialog box until proper hex-code entered
{
  usrColor=$(dialog --inputbox "Enter hex-code:" 8 40 2>&1 >/dev/tty)

  retval=$? # get button press

  case $retval in
    1) # cancel
    rm -rf $PWD/src
    rm -rf $PWD/theme
    rm -rf $PWD/color.tmp
    exit ;;
    255) # escape has been pressed 
    rm -rf $PWD/src
    rm -rf $PWD/theme
    rm -rf $PWD/color.tmp
     exit ;;
  esac
}

# show menu listing color choices
dialog --radiolist "Select color:" 20 25 25\
  1 "Default" on \
  2 "Blue" off \
  3 "Brown" off \
  4 "Green" off \
  5 "Grey" off \
  6 "Pink" off \
  7 "Purple" off \
  8 "Red" off \
  9 "Yellow" off \
  10 "Custom" off \
2> color.tmp # export choice (a number 1-10) to a temp file

tmpColor=$(<color.tmp) # read choice (as number) from temp file, load into variable

retval=$? # store button press

case $retval in # check button pressed

0) # ok press

case $tmpColor in
  1) newColor="#d64933" ;;
  2) newColor="#42a5f5" ;;
  3) newColor="#8d6e63" ;;
  4) newColor="#66bb6a" ;;
  5) newColor="#bdbdbd" ;;
  6) newColor="#f06292" ;;
  7) newColor="#7e57c2" ;;
  8) newColor="#ef5350" ;;
  9) newColor="#ffca28" ;;
  10) get_Color # call function to display "enter hex-code" dialog
	wait 

  until [[ $usrColor =~ ^#[0-9A-Fa-f]{6}$ ]] ; do # until a valid hex-code has been entered, keep the dialog on screen
    get_Color
  done

  newColor=$usrColor ;; # make sure newColor has been set to users input

  *) # if something went wrong an there's any number other than one of the valid choices in file, cleanup and exit
  rm -rf $PWD/src
  rm -rf $PWD/theme
  rm -rf $PWD/color.tmp
  exit ;;
esac;;


  1) # cancel press
  rm -rf $PWD/src
  rm -rf $PWD/theme
  rm -rf $PWD/color.tmp
  exit ;;
  255) # escape press
  rm -rf $PWD/src
  rm -rf $PWD/theme
  rm -rf $PWD/color.tmp
  exit ;;
esac

# recolor
  count=0
  colorCount=`ls -1 $PWD/src/*.svg 2>/dev/null | wc -l` # count number of svg files
  (cd $PWD/src;
  find . -type f -name '*.svg' -print0 | while IFS= read -r -d '' file; do
    if [[ `grep "$oldColor" "$file"` ]]; then
      sed -i "s/$oldColor/$newColor/g" "$file"
      count=$((count+1))
      wait
      dialog --title '' --infobox "adding $newColor to file $count of $colorCount" 3 50 # display dialog counting files colored
    fi
done)

# create .png files
  pngCount=`ls -1 $PWD/src/*.svg 2>/dev/null | wc -l` # count how many svg files are in directory
  count=0
  for fileSource in $PWD/src/*.svg
  do
    if [ -f "$fileSource" ]; then
      count=$((count+1))
      file=$(echo $fileSource | cut -d'.' -f1)
      dialog --title '' --infobox "creating file $count of $pngCount" 3 50 # count how many files converted and how many remain
      inkscape $fileSource --export-png=$file.png --export-dpi=90 > /dev/null # pipe output to nowhere so it's not shown on screen
      wait
    else
      dialog --title 'ERROR' --infobox "no source files found!" 3 50
      exit
    fi
done

# create cursor files
  curCount=`ls -1 $PWD/src/*.cursor 2>/dev/null | wc -l` # count .cursor files
  count=0
  for CURSOR in $PWD/src/*.cursor; do
    BASENAME=$CURSOR
    BASENAME=${BASENAME##*/}
    BASENAME=${BASENAME%.*}

    count=$((count+1))
    dialog --title '' --infobox "generating cursor $count of $curCount" 3 50 # display how many files converted and how many remain
    (cd $CHANGEDIR;xcursorgen $BASENAME.cursor $OUTDIR/$BASENAME > /dev/null) # pipe output to nowhere so it's not shown on screen
    wait
done

# install theme
  dialog --title '' --infobox "installing theme" 3 50
  cp $PWD/theme/custom_cursors/. ~/.icons/custom-cursors/ -R
  wait

# clean everything up
  dialog --title '' --infobox "Cleaning up" 3 50
  rm -rf $PWD/src
  rm -rf $PWD/theme
  rm -rf $PWD/color.tmp
  wait
  dialog --title 'Complete' --msgbox 'Cursor files have been generated and installed. Use tweak-tool to set cursor theme to custom-cursors. Enjoy!' 10 50
  exit
