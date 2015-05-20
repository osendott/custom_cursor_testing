#############################################
# noname-cursors v0.9.9                     # current code-base written 17 MAY 2015
# by: William Osendott  & Umut Topuzoglu    #
#############################################
show_progress()
{
while [[ $PCT -le "100" ]] ; do
PCT=$(( 100*$count/$totalCOUNT ))
echo $PCT | dialog --title "$procTITLE" --gauge "$count of $totalCOUNT...$PCT" 7 70 0
sleep .08
count=$((count+1))

done
}
# copy dialogrc to ~/.dialogrc to control colors of script

# set -x # uncomment this if you wanna see what's going on line-by-line, remove before distribution

#############
# variables # variables will be set by script @ runtime, this is just a list. BASH doesn't require you to declare variables.
#############
choice="" # light/dark response (same as $retval below)
tmpColor="" # hold user color choice @ menu
newColor="" # theme color to replace Default
usrColor="" # custom color from dialog
count="0" # counter
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
dialog --backtitle "Custom Cursors v1.0" --yes-label "light" --no-label "dark" --yesno "Please choose base:" 5 25

choice=$?

case $choice in # read $choice, see which button pressed
	# no (labeled as DARK in this script)
	1) 
	
          
totalCOUNT=`ls -1 $PWD/src/*.svg 2>/dev/null | wc -l` # count number of svg files
	(cd $PWD/src;
        	find . -type f -name '*.svg' -print0 | while IFS= read -r -d '' file; do
          sed -i 's/#e8e8e8/#ff0000/g;s/#2d2d2d/#e8e8e8/g;s/#ff0000/#2d2d2d/g;s/#ffffff/#000000/g' "$file"
procTITLE="Generating DARK files"
show_progress
        done)
        wait ;;
esac

get_Color() # function created to loop display of dialog box until proper hex-code entered
{
  usrColor=$(dialog --backtitle "Custom Cursors v1.0" --inputbox "Enter hex-code:" 8 40 2>&1 >/dev/tty)

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
dialog --backtitle "Custom Cursors v1.0" --menu "Select color:" 20 25 25\
  "1" "Default" \
  "2" "Blue" \
  "3" "Brown" \
  "4" "Green" \
  "5" "Grey" \
  "6" "Pink" \
  "7" "Purple" \
  "8" "Red" \
  "9" "Yellow" \
  "10" "Custom" \
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
  totalCOUNT=`ls -1 $PWD/src/*.svg 2>/dev/null | wc -l` # count number of svg files
  (cd $PWD/src;
  find . -type f -name '*.svg' -print0 | while IFS= read -r -d '' file; do
    if [[ `grep "$oldColor" "$file"` ]]; then
      sed -i "s/$oldColor/$newColor/g" "$file"
     wait
procTITLE="Recoloring cursors..."      
show_progress
fi
done)

# create .png files
  totalCOUNT=`ls -1 $PWD/src/*.svg 2>/dev/null | wc -l` # count how many svg files are in directory
  count=0
  for fileSource in $PWD/src/*.svg
  do
    if [ -f "$fileSource" ]; then
           file=$(echo $fileSource | cut -d'.' -f1)
procTITLE="Creating .png files..."
      show_progress
      inkscape $fileSource --export-png=$file.png --export-dpi=90 > /dev/null # pipe output to nowhere so it's not shown on screen
      wait
    else
      dialog --backtitle "Custom Cursors v1.0" --title 'ERROR' --infobox "no source files found!" 3 50
      exit
    fi
done

# create cursor files
  totalCOUNT=`ls -1 $PWD/src/*.cursor 2>/dev/null | wc -l` # count .cursor files
  count=0
  for CURSOR in $PWD/src/*.cursor; do
    BASENAME=$CURSOR
    BASENAME=${BASENAME##*/}
    BASENAME=${BASENAME%.*}

    proc_TITLE="Creating cursor files..."
    show_progress
    #count=$((count+1))
    #dialog --backtitle "Custom Cursors v1.0" --title '' --infobox "generating cursor $count of $curCount" 3 50 # display how many files converted and how many remain
    (cd $CHANGEDIR;xcursorgen $BASENAME.cursor $OUTDIR/$BASENAME > /dev/null) # pipe output to nowhere so it's not shown on screen
    wait
done

# install theme
  dialog --backtitle "Custom Cursors v1.0" --title '' --infobox "installing theme" 3 50
  cp $PWD/theme/custom_cursors/. ~/.icons/custom-cursors/ -R
  wait

# clean everything up
  dialog --backtitle "Custom Cursors v1.0" --title '' --infobox "Cleaning up" 3 50
  rm -rf $PWD/src
  rm -rf $PWD/theme
  rm -rf $PWD/color.tmp
  wait
  dialog --backtitle "Custom Cursors v1.0" --title 'Complete' --msgbox 'Cursor files have been generated and installed. Use tweak-tool to set cursor theme to custom-cursors. Enjoy!' 10 50
  exit
