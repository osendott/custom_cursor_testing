#!/bin/bash

startup()
{
tar -xzf src.tar.gz
tar -xzf theme.tar.gz
}

theme()
{
(cd $PWD/src;
find . -type f -name '*.svg' -print0 | while IFS= read -r -d '' file; do
if [[ `grep "$oldColor" "$file"` ]]; then
echo "Replacing $oldColor with $newColor in $file"
sed -i "s/$oldColor/$newColor/g" "$file"
wait
fi
done)
}

generate_png()
{
count=0  
for fileSource in $PWD/src/*.svg
do
if [ -f "$fileSource" ]; then
count=$((count+1))
file=$(echo $fileSource | cut -d'.' -f1)
echo "$count". "$fileSource" -> "$file.png"
inkscape $fileSource --export-png=$file.png --export-dpi=90
wait
else
echo "no file $fileSource found!"
exit 
fi
done

echo "$count file(s) converted"
}

create_cursors()
{
count=0
for CURSOR in $PWD/src/*.cursor; do
BASENAME=$CURSOR
BASENAME=${BASENAME##*/}
BASENAME=${BASENAME%.*}

count=$((count+1))
(cd $CHANGEDIR;xcursorgen $BASENAME.cursor $OUTDIR/$BASENAME)
wait
done
}

install_cursors()
{
cp $PWD/theme/custom_cursors/. ~/.icons/custom-cursors/ -R
}

cleanup()
{
rm -rf $PWD/src
rm -rf $PWD/theme
rm -rf $PWD/config.dat
}


theme_dark()
{
(cd $PWD/src;
        find . -type f -name '*.svg' -print0 | while IFS= read -r -d '' file; do
sed -i "s/#e8e8e8/#ff0000/g" "$file"
sed -i "s/#2d2d2d/#e8e8e8/g" "$file"
sed -i "s/#ff0000/#2d2d2d/g" "$file"
sed -i "s/#ffffff/#000000/g" "$file"
done)
echo "dark base generated..."
}

get_custom()
{
exec 3>&1;
usrColor=$(dialog --inputbox "enter new color:" 0 0 2>&1 1>&3);
exitcode=$?;
exec 3>&-;

if ! [[ $usrColor =~ ^#[0-9A-Fa-f]{6}$ ]]; then
echo -e \ "Error, choose a valid color, if using a custom hex-code, don't forget the #. Try again..."
get_custom
fi
newColor=$usrColor
}

tar -xzf src.tar.gz
tar -xzf theme.tar.gz

dialog --yes-label "light" --no-label "dark" --title ""  --yesno "Please choose base" 6 25 
response=$?
clear
case $response in
   1) themeStyle="dark";; # set themestyle variable
esac

dialog --title "" --radiolist "Select color:" 10 40 3 \
        1 "Default" on \
        2 "Blue" off \
        3 "Brown" off \
	4 "Green" off \
	5 "Grey" off \
	6 "Orange" off \
	7 "Pink" off \
	8 "Purple" off \
	9 "Red" off \
	10 "Yellow" off \
	11 "Custom" off \
2> config.dat

color=$(<config.dat)
#color=<(`cat result.txt`)
case $color in
	1) newColor="#d64933";;
	2) newColor="#42a5f5";;
	3) newColor="8d6e63";;
	4) newcolor="66bb6a";; 
	5) newColor="bdbdbd";;
	6) newColor="f57c00";;
	7) newColor="f06292";;
	8) newColor="7e57c2";;
	9) newColor="ef5350";;
	10) newColor="ffca28";;
        11) get_custom;;
esac

theme
generate_png
create_cursors
install_cursors
cleanup




