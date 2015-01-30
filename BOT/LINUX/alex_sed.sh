sed -e 's|\x09||g' -e "s|<td valign=\"middle\" align=\"center\"><a href=\"\.\.|http:\/\/www\.13thplanetemporium\.com/|g" -e "s|\">&nbsp;<\/a><\/td>||g" -e "s|<a href=\"\.\.|http:\/\/www\.13thplanetemporium\.com/|g" -e 's|\\|/|g' -e 's|\">&nbsp\;</a><\/object><\/td>||g' -e 's|\">&nbsp\;<\/a>||g' -e 's|\/\/musik|\/musik|g' -e 's|^|\"|g' -e 's|$|\"|g' instrumentals.dl > files 
 
sed -e 's|^|wget -w 2 --cookies=on --load-cookies=cookies\.txt |g' -e 's|$| \.|g' files > wgetinstrumentals 



