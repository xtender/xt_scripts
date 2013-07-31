 document.writeln('<object id=\"utility\" name=\" \" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"" + activexDownloadURL + "#version=7,0,14,0\" width=\"100\" height=\"50\">');
 document.writeln('<param name=\"movie\" value=\"history.swf\" />');
 document.writeln('<param name=\"FlashVars\" value=\"'+fv+'&$_lconid='+top.lc_id+'\"/>');
 document.writeln('<param name=\"quality\" value=\"high\" />');
 document.writeln('<param name=\"bgcolor\" value=\"#FFFFFF\" />');
 document.writeln('<param name=\"profile\" value=\"false\" />');
 document.writeln('<embed id=\"utilityEmbed\" name=\"history.swf\" src=\"emviewers/scripts/history.swf\" type=\"application/x-shockwave-flash\" flashvars=\"'+fv+'&$_lconid='+top.lc_id+'\" profile=\"false\" quality=\"high\" bgcolor=\"#FFFFFF\" width=\"100\" height=\"50\" align=\"\" pluginspage=\"" + pluginDownloadURL + "\"></embed>');
 document.writeln('</object>');
