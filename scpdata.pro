function scpdata, aorname, campaign_name, chname
  ;;copy data from sscdev100 archive to my machine
  
  ;;start with making the directory to house it
  localname =strcompress('/Volumes/external/irac_warm/trending/r' + string(aorname),/remove_all)
  print, 'localname ', localname
  spawn, 'mkdir '+ localname
  cd, localname
  spawn, 'mkdir '+ chname
  cd, chname
  spawn, 'mkdir bcd'
  cd, 'bcd'
  
  remotename = strcompress('jkrick@sscdev100.ipac.caltech.edu:/sha/archive/proc/'+campaign_name + '/r' + string(aorname) + '/' + chname + '/bcd/\*bcd.fits',/remove_all)
  scpcommand = 'scp '+ remotename + '  .'
  spawn, scpcommand
  
  return, 0
end
