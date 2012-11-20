function create_planetinfo

  planetinfo = hash()
  keys =['ra', 'dec','aorname','basedir','chname', 'utmjd_center', 'transit_duration', 'period', 'intended_phase', 'exptime','mask', 'maskreg']

;---
  planetname = 'hd189733'
  chname = '1' ;!!!
  ra_ref = 300.18185
  dec_ref = 22.709912
  aorname = ['r41592320' ,'r41592832', 'r41591808','r41592576' ,'r41591552','r41592064', 'r41591296'] 
  basedir = '/Users/jkrick/irac_warm/' 
  utmjd_center =  55556.83649D; 55557.94753D 
  transit_duration=.07574*24.*60.
  period = 2.21857312
  intended_phase = 0
  exptime = 0.1
  mask = 'yes'
  maskreg = fltarr(32,32)
  maskreg[13:16, 4:7] =  !Values.F_NAN
  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = '55cnc'
  chname = '2'
  ra_ref = 133.14756
  dec_ref = 28.330094
  ;aorname = ['r43981312','r43981568','r43981824','r43981056'] 
  aorname = ['r43981568'] 
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  ;utmjd_center =  [double(55944.25889), double(55947.20505),double(55949.41467), double(55957.51661)]  
  utmjd_center =  [double(55947.20505)]  
  transit_duration=105.7
  period = 0.73654 
  intended_phase = 0.5
  exptime = [0.02]
  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'gj436'
  chname = '2'
  ra_ref = 175.5493
  dec_ref = 26.704311
  aorname = ['r38702592' ,'r38808064', 'r40848128','r42614016' ] 
  basedir = '/Users/jkrick/irac_warm/' 
  utmjd_center = 55221.47190D
  transit_duration=96.300
  period = 2.64385
  intended_phase = 0.0
  exptime = [0.1, 0.4, 0.4, 0.4, 0.4]
  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'hd7924'
  chname = '2'
  ra_ref = 20.496279
  dec_ref = 76.710305
  aorname = ['r44605184' ] 
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 54727.49 - 0.16
  transit_duration=77.73 ;guess at 0.01 period
  period = 5.3978
  intended_phase = 0.0
  exptime = 0.1

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'wasp13'
  chname = '2'
  ra_ref = 140.10268
  dec_ref = 33.882288
  aorname = ['r45676544','r45675520']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56086.49239D
  transit_duration=243.4
  period = 4.353011
  intended_phase = 0.5
  exptime = 0.4

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase,exptime, mask, maskreg)
  planetinfo[planetname] = HASH(keys, values)
  
;---
  planetname = 'wasp15'
  chname = '2'
  ra_ref = 208.92783
  dec_ref = -32.159837
  aorname = ['r45675264', 'r45675776'] 
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56184.45438D
  transit_duration=56184.45438
  period = 3.752066
  intended_phase = 0.5
  exptime = 2

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'wasp16'
  chname = '2'
  ra_ref = 214.68297
  dec_ref = -20.275605
  aorname =['r45674240','r45674496']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56179.09319
  transit_duration=115.2
  period = 3.118601
  intended_phase = 0.5
  exptime = 2

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'hat22'
  chname = '2'
  ra_ref = 155.68122
  dec_ref = 50.128716
  aorname = ['r45675008','r45674752' ] 
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56081.30088
  transit_duration=172.2
  period = 3.21222
  intended_phase = 0.5
  exptime = 0.4

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'wasp14'
  chname = '2'
  ra_ref = 218.27649
  dec_ref = 21.894575
  aorname = [ 'r45428992', 'r45428736', 'r45428480', 'r45428224', 'r45426688', 'r45838592', 'r45840128', 'r45841408', 'r45842176', 'r45842944', 'r45844480', 'r45845248', 'r45846016', 'r45846784', 'r45839104', 'r45840896', 'r45841664', 'r45842432', 'r45843200', 'r45844736', 'r45845504', 'r45846272', 'r45847040', 'r45839616', 'r45841152', 'r45841920','r45843968','r45843712','r45843456','r45840640','r45840384','r45839872','r45839360','r45838848','r45838336', 'r45842688', 'r45844224', 'r45844992', 'r45845760', 'r45846528']  ;snapshots and last 5 are ch2 stares

;'r45843968','r45843712','r45843456','r45840640','r45840384','r45839872','r45839360','r45838848','r45838336'

  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56020.23972; 56172.81485; transit ;56187.39924  ;one of the secondary times
  transit_duration=183.6
  period = 2.243752
  intended_phase = 0.0
  exptime = 2

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg)
  planetinfo[planetname] = HASH(keys, values)

  ;test that this is all working
;  print, planetinfo.keys()
;  print, planetinfo['wasp13'].keys()
;  print, 'plan', planetinfo['wasp15', 'aorname']
  
  return, planetinfo

end
