#!/bin/bash

outputSizes=( 16 24 32 48 64 96 128 )
# see http://www.imagemagick.org/script/color.php
backColors=( darkgrey red3 steelblue3 orange violetred2 lemonchiffon )

for bColor in ${backColors[@]} ; do 
	echo "Generating $bColor iconset..."
	[ -d ${bColor} ] || mkdir ${bColor}
	for oSize in ${outputSizes[@]} ; do 
		echo -n "  * ${oSize}x${oSize} px... "
		[ -d ${bColor}/${oSize}x${oSize} ] || mkdir ${bColor}/${oSize}x${oSize}
		while read line ; do
			# nounnames is a comma seperated list of <svgfilename>,<desired outputname>
			svgname=`echo $line | cut -d, -f1`
			name=`echo $line | cut -d, -f2`
			# scaling of icon should be relative to output size (~90%), rounded
			s=`echo $oSize*0.76 | bc`
			scaleSize=`printf %.0f $s`
			# background & rounding
			case $oSize  in
    			16 ) bSize=15; rSize=2;;
    			24 ) bSize=23; rSize=3;;
    			32 ) bSize=31; rSize=4;;
    			48 ) bSize=47; rSize=5;;
    			64 ) bSize=63; rSize=6;;
    			96 ) bSize=94; rSize=8;;
    			128 ) bSize=128; rSize=12;;	
			esac
			backgroundImage=`mktemp`
			iconImage=`mktemp`
			convert -size ${oSize}x${oSize} xc:transparent -fill ${bColor} -draw "roundrectangle 0,0 ${bSize},${bSize} ${rSize},${rSize}" PNG:${backgroundImage}
			#convert ${svgname} -transparent white -negate -scale ${scaleSize}x${scaleSize} PNG:${iconImage}
			convert ${svgname} -transparent white -negate -compose CopyOpacity -fill white -colorize 100% -filter Gaussian -scale ${scaleSize}x${scaleSize} PNG:${iconImage}
			composite -gravity center ${iconImage} ${backgroundImage} ${bColor}/${oSize}x${oSize}/${name}.png
			rm $backgroundImage
			rm $iconImage
		done < nounnames.txt
		echo "Done"
	done
done
