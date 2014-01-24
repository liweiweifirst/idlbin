function create_planetinfo

  planetinfo = hash()
  keys =['ra', 'dec','aorname','basedir','chname', 'utmjd_center', 'transit_duration', 'period', 'intended_phase', 'exptime','mask', 'maskreg','stareaor','plot_norm','plot_corrnorm']

;---
  planetname = 'wasp38'
  chname = '2'
  ra_ref = 243.95985208 ; 16 15 50.3645 
  dec_ref = 10.03259056 ; +10 01 57.326 
  aorname = ['r45676288', 'r45676032'] ;ch2
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56190.96147D	;55335.4205D
  transit_duration= 279.648 ;min 0.1942 days  taken from NSTED
  period =   6.871815  ;days 
  exptime = 0.4
  intended_phase = 0.5
  stareaor = 0
  plot_norm = 0.1039
  plot_corrnorm = 0.1025

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'fake_dec7'
  chname ='2';  '1'
  ra_ref = 36.712664
  dec_ref = 37.550367
    aorname = ['r0000000000'] ;['r0000000001'] 
  basedir = '/Users/jkrick/irac_warm/simulation_JI/' 
  utmjd_center = 55957.14809D
  transit_duration= 170.0; min  taken from exoplanet transit database
  period =    1.219867  ;days 
  exptime = 0.1
  intended_phase = 0.
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'wasp33'
  chname = '2'
  ra_ref = 36.712664
  dec_ref = 37.550367
    aorname = ['r45383424', 'r45384448', 'r45384704'] ;ch2
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 55957.14809D
  transit_duration= 170.0; min  taken from exoplanet transit database
  period =    1.219867  ;days 
  exptime = 0.4
  intended_phase = 0.
  stareaor = 0
  plot_norm = 0.175
  plot_corrnorm = 0.175

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'hd209458'
  chname = '2'
  ra_ref = 330.79488
  dec_ref = 18.8843175
  aorname = ['r38703872','r38704128','r38704384','r38701312','r38703360','r38703616','r45188864','r45189120','r45189376','r45189632','r45189888','r45190144','r45190400','r45190656','r45190912','r45191168','r45191424','r45191680','r45191936','r45192192','r45192704','r45195264','r45192960','r45193216','r45193472','r45193984','r45193728','r45195520','r45194240','r45194496','r45194752','r45195008','r45196288','r45195776','r45197312','r45196032','r45196544','r45196800','r45197056','r45197568','r45197824','r45198080','r45192448']
  basedir = '/Users/jkrick/irac_warm/' 
  utmjd_center = 51818.05045D; 55938.54133D; 55942.06608D
  transit_duration=184.2 ; min
  period = 3.52474859           ;days intended_phase = 0.0
  exptime = 0.4
  intended_phase = 0
  stareaor = 5
  plot_norm = 0.46
  plot_corrnorm = 0.498

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
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
  stareaor = 5
  mask = 'yes'
  maskreg = fltarr(32,32)
  maskreg[13:16, 4:7] =  !Values.F_NAN
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = '55cnc'
  chname = '2'
  ra_ref = 133.14756
  dec_ref = 28.330094
  aorname = ['r43981312','r43981568','r43981824','r43981056'] 
  ;aorname = ['r43981568'] 
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  ;utmjd_center =  [double(55944.25889), double(55947.20505),double(55949.41467), double(55957.51661)]  
  utmjd_center =  [double(55947.20505)]  
  transit_duration=105.7
  period = 0.73654 
  intended_phase = 0.5
  exptime = [0.02]
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
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
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'hd7924'
  chname = '2'
  ra_ref = 20.496279
  dec_ref = 76.710305
  ;aorname = ['r46981632','r46981888']; 2012
  ;aorname = ['r44605184' ] ;2011
  aorname = ['r44605184', 'r46981632','r46981888'] ; both 2011 and 2012
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 54727.49 - 0.16 ;don't know where this additional change comes from
  utmjd_center = 55866.43 ;from Stephen
  ;utmjd_center = 55866.28554017 ; from the Knutson Nov 2011 observation
  transit_duration=77.73 ;guess at 0.01 period
  period = 5.3978
  intended_phase = 0.0
  exptime = 0.1
  stareaor = 0
  plot_norm = 1.46
  plot_corrnorm = 1.46

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'wasp13'
  chname = '2'
  ra_ref = 140.10268
  dec_ref = 33.882288
  aorname = ['r45676544','r45675520'] ; from my PID
  ;aorname = ['r47047168', 'r47037952'] ;from Dessert PID this is the primary
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56086.49239D
  transit_duration=243.4
  period = 4.353011
  intended_phase = 0.5
  exptime = 0.4
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase,exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
  
;---
  planetname = 'wasp15'
  chname = '2'
  ra_ref = 208.92783
  dec_ref = -32.159837
  aorname = ['r45675264', 'r45675776'] 
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56184.45438D
  transit_duration=222.900000 ; min from nsted
  period = 3.752066
  intended_phase = 0.5
  exptime = 2
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
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
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'hat22'
  chname = '1';'2'
  ra_ref = 155.68122
  dec_ref = 50.128716
  aorname = ['r48704512','r48693504'];['r45675008','r45674752' ] 
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56486.04060; 56081.30088
  transit_duration=172.2
  period = 3.21222
  intended_phase = 0.5
  exptime = 0.4
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
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
  stareaor =4
  plot_norm = 0.0617
  plot_corrnorm = 0.0607
  mask = 'yes'
  maskreg = fltarr(32,32)
  maskreg[4:7, 12:14] =  !Values.F_NAN

  values=list(ra_ref, dec_ref, aorname, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

  ;test that this is all working
;  print, planetinfo.keys()
;  print, planetinfo['wasp13'].keys()
;  print, 'plan', planetinfo['wasp15', 'aorname']
  
  return, planetinfo

end
