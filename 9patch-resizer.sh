#!/bin/bash


    # 9patch-resizer.sh, (c) Straitjacket Entertainment
    # -- resize 9patch .png image by imageMagick...
    #
    # usage: 9patch-resizer <resize:imageMagickStyle> <source.png> <target.png>
    #


SCRIPT_NAME=`basename $0`;

help() {
    echo "${SCRIPT_NAME} <resize:imageMagickStyle> <source.png> <target.png>";
    echo;
}

resize="$1";
src="$2";
tgt="$3";
    [ "${resize}" == "" ] && { help; echo "ERROR: <resize> is missing! example: \"50%\" or \"123x\" or \"123x321\!\"..."; echo; exit; }
    [ "${src}"    == "" ] && { help; echo "ERROR: <source.png> is missing!"; echo; exit; }
    [ ! -r "${src}"     ] && { help; echo "ERROR: source.png not found!"; echo; exit; }
    [ "${tgt}"    == "" ] && { help; echo "ERROR: <target.png> is missing!"; echo; exit; }
    [ -d "${tgt}"       ] && { help; echo "ERROR: target.png is a directory!"; echo; exit; }

    is9Patch=`echo "${src}"|rev|cut -d'.' -f2`;
    [ "${is9Patch}" != "9" ] && { help; echo "ERROR: source is not 9patch image!"; echo; exit; }

    tgtDir=`dirname "${tgt}"`;
    [ ! -d "${tgtDir}" ] && { mkdir -p "${tgtDir}"; }


srcWidth=`convert "${src}" -print "%wx%h\n" /dev/null|cut -d'x' -f1`;
srcHeight=`convert "${src}" -print "%wx%h\n" /dev/null|cut -d'x' -f2`;


# innerRectangle
innerWidth=`expr ${srcWidth} - 2`;
innerHeight=`expr ${srcHeight} - 2`;
convert "${src}" -crop "${innerWidth}x${innerHeight}+1+1" "${tgt}-innerRectangle.png";


# outerRectangle
convert "${src}" -strokewidth 0 -fill "rgba(255, 255, 255, 1)" -draw "rectangle 1,1 ${innerWidth},${innerHeight}" "${tgt}-outerRectWhite.png";
convert "${tgt}-outerRectWhite.png" -fuzz 01% -transparent white "${tgt}-outerRectangle.png"
rm -f "${tgt}-outerRectWhite.png";


# resize: src image
convert -resize "${resize}" "${tgt}-innerRectangle.png" "${tgt}-innerSized.png";
innerSizedWidth=`convert "${tgt}-innerSized.png" -print "%wx%h\n" /dev/null|cut -d'x' -f1`;
innerSizedHeight=`convert "${tgt}-innerSized.png" -print "%wx%h\n" /dev/null|cut -d'x' -f2`;


# resize: 9patch
outerSizedWidth=`expr ${innerSizedWidth} + 2`;
outerSizedHeight=`expr ${innerSizedHeight} + 2`;
convert -resize ${outerSizedWidth}x${outerSizedHeight}\! -filter Point "${tgt}-outerRectangle.png" "${tgt}-outerSized.png";


# composite: 9patch(~outer) + inner
composite "${tgt}-innerSized.png" "${tgt}-outerSized.png" -geometry +1+1 "${tgt}-finalSized.png";


# finalize
convert "${tgt}-finalSized.png" "${tgt}";
rm -f "${tgt}-innerRectangle.png" "${tgt}-outerRectangle.png" "${tgt}-innerSized.png" "${tgt}-outerSized.png" "${tgt}-finalSized.png";


