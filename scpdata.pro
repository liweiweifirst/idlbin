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
 ; spawn, scpcommand

  remotebunc = strcompress('jkrick@sscdev100.ipac.caltech.edu:/sha/archive/proc/'+campaign_name + '/r' + string(aorname) + '/' + chname + '/bcd/\*bunc.fits',/remove_all)
  scpbunc = 'scp '+ remotebunc + '  .'
 ; spawn, scpbunc

  remoteraw = strcompress('jkrick@sscdev100.ipac.caltech.edu:/stage/sha/archive/raw/campaign/'+campaign_name + '/r' + string(aorname) + '/' + chname + '/raw/\*dce.fits',/remove_all)
  scpraw = 'scp '+ remoteraw + '  .'
 ; spawn, scpraw
  
  return, 0
end
