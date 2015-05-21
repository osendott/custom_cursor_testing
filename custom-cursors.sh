#############################################
# noname-cursors v0.9.9                     # current code-base written 17 MAY 2015
# by: William Osendott  & Umut Topuzoglu    #
#############################################

show_progress() # display progress bar
{
PCT=$(( 100*$count/$totalCOUNT ))
echo $PCT | dialog --backtitle "$scriptNAME $scriptVER" --title "$procTITLE" --gauge "" 7 70 0
sleep .06
count=$((count+1))
}

# copy dialogrc to ~/.dialogrc to control colors of script
# set -x # uncomment this if you wanna see what's going on line-by-line, remove before distribution

#############
# variables # list of variables used by script
#############
scriptNAME="Custom Cursors" # name of script (when we decide on one lol)
scriptVER="0.9.9-2" # version number
# choice="" # light/dark response (same as $retval below)
# getColor="" # holds custom-hex until validated
# tmpColor="" # hold user color choice @ menu
# newColor="" # theme color to replace Default
# usrColor="" # custom color from dialog
count="0" # number of files processed
CHANGEDIR=$PWD/src # change to source directory in sub-shell
OUTDIR=$PWD/theme/custom_cursors/cursors # where to generate files
oldColor="#d64933" # default color for cursors
# retval="" # dialog uses stderr to output which button is pressed. this variable copies it, to be read & decide which button pressed (0 yes, 1 no)
# totalCOUNT="" # total number of files to be processed
# PCT="" # percentage of work completed
# procTITLE="" # name of current process, displayed at top of progress bars


# extract source files
tar -xzf src.tar.gz
tar -xzf theme.tar.gz
wait

# light/dark menu
dialog --backtitle "$scriptNAME $scriptVER" --yes-label "light" --no-label "dark" --yesno "Please choose base:" 5 25

choice=$?

case $choice in # read $choice, see which button pressed
	# no (labeled as DARK in this script)
	1) themeStyle="Dark" ;;
	0) themeStyle="Light" ;;
esac

get_Color() # function created to loop display of dialog box until proper hex-code entered
{
  getColor=$(dialog --backtitle "$scriptNAME $scriptVER" --inputbox "Enter hex-code:" 8 40 2>&1 >/dev/tty)

  retval=$? # get button press

  case $retval in
    0) # ok
	usrColor=$getColor ;;
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
dialog --backtitle "$scriptNAME $scriptVER" --menu "Select color:" 20 25 25\
  "1" "Numix (Default)" \
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
  1) newColor="#d64933" 
	colorName="Numix" ;;
  2) newColor="#42a5f5" 
	colorName="Blue" ;;
  3) newColor="#8d6e63" 
	colorName="Brown" ;;
  4) newColor="#66bb6a" 
	colorName="Green" ;;
  5) newColor="#bdbdbd" 
	colorName="Grey" ;;
  6) newColor="#f06292"
	colorName="Pink" ;;
  7) newColor="#7e57c2"
	colorName="Purple" ;;
  8) newColor="#ef5350"
	colorName="Red" ;;
  9) newColor="#ffca28"
	colorName="Yellow" ;;
  10) 
  	until [[ $usrColor =~ ^#[0-9A-Fa-f]{6}$ ]] ; do # until a valid hex-code has been entered, keep the dialog on screen
    	get_Color
  	done 
	colorName="Custom" 

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

# recolor/convert .svg to .png/generate cursors
procTITLE="Creating cursors with $themeStyle base and $colorName ($newColor) highlights"
  totalCOUNT=`ls -1 $PWD/src/*.svg 2>/dev/null | wc -l` # count number of svg files
for getFILES in $PWD/src/*.svg
do
 BASENAME=$getFILES
    BASENAME=${BASENAME##*/}
    BASENAME=${BASENAME%.*}
case $themeStyle in
Dark)
sed -i 's/#e8e8e8/#ff0000/g;s/#2d2d2d/#e8e8e8/g;s/#ff0000/#2d2d2d/g;s/#ffffff/#000000/g' "$getFILES" ;;
esac
sed -i "s/$oldColor/$newColor/g" "$getFILES"
fileSource=$(echo $getFILES | cut -d'.' -f1)
inkscape $getFILES --export-png=$fileSource.png --export-dpi=90 > /dev/null 
wait
(cd $CHANGEDIR;xcursorgen $BASENAME.cursor $OUTDIR/$BASENAME > /dev/null)
show_progress
done


# install theme
  dialog --backtitle "$scriptNAME $scriptVER" --title '' --infobox "installing theme" 3 50
  cp $PWD/theme/custom_cursors/. ~/.icons/custom-cursors/ -R

# clean everything up
  dialog --backtitle "$scriptNAME $scriptVER" --title '' --infobox "Cleaning up" 3 50
  rm -rf $PWD/src
  rm -rf $PWD/theme
  rm -rf $PWD/color.tmp
  dialog --backtitle "$scriptNAME $scriptVER" --title 'Complete' --msgbox 'Cursor files have been generated and installed. Use tweak-tool to set cursor theme to custom-cursors. Enjoy!' 10 50
clear
  exit
