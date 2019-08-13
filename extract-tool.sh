perl -pi -e 's/CropBox/CRopBox/g' current-pdf.pdf;
ournum=`gs -q -dNODISPLAY -c "("current-pdf.pdf") (r) file runpdfbegin pdfpagecount = quit" 2>/dev/null`
counter=1
while [ $counter -le $ournum ] ; do  
counterplus=$((counter+1));  
printf -v j "%04d" $counter;
mkdir $counter; 
dpi=72;
dpi_mono=150;
gs -dNOPAUSE -dQUIET -dBATCH -sOutputFile="tmp_original.pdf" \
-dFirstPage=$counter \
-dLastPage=$counter \
-dPDFSETTINGS=/screen \
-dAutoRotatePages=/All \
-sDEVICE=pdfwrite \
-dCompatibilityLevel=1.4 \
-sRGBProfile=AdobeRGB1998.icc \
-sColorConversionStrategy=LeaveColorUnchanged \
-dCompressStreams=true \
-dConvertCMYKImagesToRGB=true \
-dAntiAliasGrayImages=true \
-dAntiAliasMonoImages=true \
-dSubsetFonts=true \
-dDownsampleGrayImages=true \
-dDownsampleMonoImages=true \
-dGrayImageResolution=$dpi_mono \
-dMonoImageResolution=$dpi_mono \
-dGrayImageDownsampleThreshold=1.0 \
-dMonoImageDownsampleThreshold=1.0 \
-dGrayImageDownsampleType=/Bicubic \
-dMonoImageDownsampleType=/Bicubic \
-dAutoFilterGrayImages=false \
-dAutoFilterMonoImages=false \
-dGrayImageFilter=/FlateEncode \
-dGrayMonoFilter=/FlateEncode \
-dAntiAliasColorImages=true \
-dDownsampleColorImages=true \
-dColorImageDownsampleType=/Average \
-dColorImageResolution=144 \
-dColorImageDepth=-1 \
-dColorImageDownsampleThreshold=1.0 \
-dEncodeColorImages=true \
-dColorImageFilter=/DCTEncode \
-dAutoFilterColorImages=false \
-dNOINTERPOLATE -r72 original.pdf >& /dev/null; 
#gs -sDEVICE=pdfwrite -o $counter/original.pdf -c "[/CropBox[10 80 880 1600] /PAGES pdfmark" -f $counter/tmp.pdf;
#rm -f $counter/tmp.pdf;
python ../../do_cropbox.py;
mv tmp_original.pdf $counter/original.pdf;
gs -o $counter/output-text.pdf -q -dNOPAUSE -dQUIET -dBATCH -sDEVICE=pdfwrite -dFILTERVECTOR -dFILTERIMAGE $counter/original.pdf;
gs -o $counter/output-image.pdf -q -dNOPAUSE -dQUIET -dBATCH -sDEVICE=pdfwrite -dFILTERTEXT $counter/original.pdf;
inkscape --without-gui --file=$counter/output-text.pdf --export-plain-svg=$counter/output.svg;
sed -i '' -e "s/font-family:.*;-inkscape-font-specification:/font-family:/" $counter/output.svg;
cd ./$counter;
gs -q -dNODISPLAY ./toolbin_extractFonts.ps -c "(output-text.pdf) extractFonts quit";
for i in `find  *.cff`;
do
s=${i##*+};
mv $i $s;
fontforge -script ./convert.pe $s;
rm -f $s;
done
python ./update-font.py;
rm -f *.woff;
cd ..;
counter=$counterplus;  
echo page$j.pdf; 
done
