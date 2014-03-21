function create_planetinfo

  planetinfo = hash()
  keys =['ra', 'dec','aorname_ch2','aorname_ch1','basedir','chname', 'utmjd_center', 'transit_duration', 'period', 'intended_phase', 'exptime','mask', 'maskreg','stareaor','plot_norm','plot_corrnorm']
chname = 0
;---
  planetname = 'wasp38'
  ra_ref = 243.95985208                    ; 16 15 50.3645 
  dec_ref = 10.03259056 ; +10 01 57.326 
  aorname_ch2 = ['r45676288', 'r45676032'] ;ch2
  aorname_ch1 = [' ']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56190.96147D	;55335.4205D
  transit_duration= 279.648 ;min 0.1942 days  taken from NSTED
  period =   6.871815  ;days 
  exptime = 0.4
  intended_phase = 0.5
  stareaor = 0
  plot_norm = 0.1039
  plot_corrnorm = 0.1025

  values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'fake_dec7'
  ra_ref = 36.712664
  dec_ref = 37.550367
  aorname_ch2 = ['r0000000000']   ;['r0000000001'] 
  aorname_ch1 = ['r0000000000']   ;['r0000000001'] 
  basedir = '/Users/jkrick/irac_warm/simulation_JI/' 
  utmjd_center = 55957.14809D
  transit_duration= 170.0; min  taken from exoplanet transit database
  period =    1.219867  ;days 
  exptime = 0.1
  intended_phase = 0.
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'wasp33'
  ra_ref = 36.712664
  dec_ref = 37.550367
  aorname_ch2 = ['r45383424', 'r45384448', 'r45384704'] ;ch2
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 55957.14809D    ;56029.12024D

  transit_duration= 170.0; min  taken from exoplanet transit database
  period =    1.219867  ;days 
  exptime = 0.4
  intended_phase = 0.
  stareaor = 0
  plot_norm = 0.175
  plot_corrnorm = 0.175

  values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'hd209458'
  ra_ref = 330.79488
  dec_ref = 18.8843175
  aorname_ch2 = ['r38703872','r38704128','r38704384','r38701312','r38703360','r38703616','r45188864','r45189120','r45189376','r45189632','r45189888','r45190144','r45190400','r45190656','r45190912','r45191168','r45191424','r45191680','r45191936','r45192192','r45192704','r45195264','r45192960','r45193216','r45193472','r45193984','r45193728','r45195520','r45194240','r45194496','r45194752','r45195008','r45196288','r45195776','r45197312','r45196032','r45196544','r45196800','r45197056','r45197568','r45197824','r45198080','r45192448']
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/' 
  utmjd_center = 51818.05045D; 55938.54133D; 55942.06608D
  transit_duration=184.2 ; min
  period = 3.52474859           ;days intended_phase = 0.0
  exptime = 0.4
  intended_phase = 0
  stareaor = 5
  plot_norm = 0.46
  plot_corrnorm = 0.498

  values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---

  planetname = 'wasp62'
  ra_ref = 87.139641
  dec_ref =-63.988068
  aorname_ch2 = ['r48680448','r48708608', 'r48708352', 'r48708096', 'r48707840', 'r48707584', 'r48707328', 'r48707072', 'r48706816', 'r48706560', 'r48706304', 'r48702720', 'r48702464', 'r48702208', 'r48701952', 'r48701696', 'r48701440', 'r48701184', 'r48700928', 'r48700672', 'r48700416', 'r48697600', 'r48697344', 'r48697088', 'r48696832', 'r48696576', 'r48696320', 'r48696064', 'r48690688', 'r48690432', 'r48690176', 'r48689920', 'r48689664', 'r48689408', 'r48689152', 'r48688896', 'r48688640', 'r48687360', 'r48687104', 'r48686848', 'r48686592', 'r48686336', 'r48686080', 'r48685824', 'r48685568', 'r48685312', 'r48685056', 'r49048576', 'r49048320', 'r49048064', 'r49047808', 'r49047552', 'r49047296', 'r49047040', 'r49046784', 'r49046528', 'r49046272', 'r49046016', 'r49045760', 'r49045504', 'r49045248', 'r49044992', 'r49044736', 'r49044480', 'r49044224', 'r49043968', 'r49043712', 'r49043456', 'r49043200', 'r49042944', 'r49042688', 'r49042432', 'r49042176', 'r49041920', 'r49041664', 'r49041408', 'r49041152', 'r49040896', 'r49040640', 'r49040384', 'r49040128', 'r49039872', 'r48695808'] 
 aorname_ch1 = ['r0000000000']
;aorname = [  'r48680448'] ;['r48680960','r48702976']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56545.36259D
  transit_duration=228.7 ; min
  period = 4.411953          ;days intended_phase = 0.0
  exptime = 2.0
  intended_phase = 0.5
  stareaor = 0
  plot_norm = 0.0450
  plot_corrnorm = 0.0451

 values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---




  planetname = 'hd189733'
  ra_ref = 300.18185
  dec_ref = 22.709912
  aorname_ch1 = ['r41592320' ,'r41592832', 'r41591808','r41592576' ,'r41591552','r41592064', 'r41591296']  ;ch1
  aorname_ch2 = ['r31756800','r36787968','r38390016','r38390272','r38390528','r38390784','r38406656']  ;ch2
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

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = '55cnc'
  ra_ref = 133.14756
  dec_ref = 28.330094
;aorname = [ 'r39524608', 'r42000384', 'r43981056', 'r43981312', 'r43981568', 'r43981824', 'r48069888', 'r48070144', 'r48070400', 'r48070656', 'r48070912', 'r48071168', 'r48071424', 'r48071680', 'r48071936', 'r48072192', 'r48072448', 'r48072704', 'r48072960', 'r48073216', 'r48073472', 'r48073728'] ; all ch3

 aorname_ch2 = ['r48069888','r48070144','r48070400','r48070656','r48070912','r48071168','r48071424','r48071680','r48071936','r48072192','r48072448','r48072704','r48072960','r48073216','r48073472','r48073728']  ; ch2
 aorname_ch1 = ['r0000000000']
 basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  ;utmjd_center =  [double(55944.25889), double(55947.20505),double(55949.41467), double(55957.51661)]  
  utmjd_center =  55947.20505D
  transit_duration=105.7
  period = 0.73654 
  intended_phase = 0.5
  exptime = 0.02
  stareaor = 0
  plot_norm = 3.87
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'gj436'
  ra_ref = 175.5493
  dec_ref = 26.704311
  aorname_ch2 = ['r38702592' ,'r38808064', 'r40848128','r42614016' ] 
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/' 
  utmjd_center = 55221.47190D
  transit_duration=96.300
  period = 2.64385
  intended_phase = 0.0
  exptime = [0.1, 0.4, 0.4, 0.4, 0.4]
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'hd7924'
  ra_ref = 20.496279
  dec_ref = 76.710305
  ;aorname = ['r46981632','r46981888']; 2012
  ;aorname = ['r44605184' ] ;2011
  aorname_ch2 = ['r44605184', 'r46981632','r46981888'] ; both 2011 and 2012
   aorname_ch1 = ['r0000000000']
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

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'wasp13'
  ra_ref = 140.10268
  dec_ref = 33.882288
  aorname_ch2 = ['r45676544','r45675520','r47037952','r47047168'] ; from my PID
 ;aorname = ['r47047168', 'r47037952'] ;ch2 from Dessert PID this is the primary
  aorname_ch1 = ['r47036928', 'r47038208'] ;ch1 from Dessert PID this is the primary
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56086.49239D
  transit_duration=243.4
  period = 4.353011
  intended_phase = 0.5
  exptime = 0.4
  stareaor = 0
  plot_norm = 0.0383
  plot_corrnorm = 0.0278

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'wasp12'
  ra_ref = 97.6366
  dec_ref = 29.6723
  aorname_ch1 = ['r28578560'] ;ch1
  aorname_ch2 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 54773.146181D
  transit_duration=175.7
  period = 1.091423
  intended_phase = 0.5
  exptime = 12.
  stareaor = 0
  plot_norm = 0.0228
  plot_corrnorm = 1.0   ; not there

  values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'hat3'
  ra_ref = 206.0941
  dec_ref = 48.0287
  aorname_ch2= ['r31749376'] 
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 55301.31066D
  transit_duration=124.6
  period = 2.899736
  intended_phase = 0.5
  exptime = 2.
  stareaor = 0
  plot_norm = .0274
  plot_corrnorm = .0274   ; not there

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'wasp15'
  ra_ref = 208.92783
  dec_ref = -32.159837
;  aorname = ['r45675264', 'r45675776'] 
  aorname_ch2 = [ 'r45675776'] 
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56184.45438D
  transit_duration=222.900000 ; min from nsted
  period = 3.752066
  intended_phase = 0.5
  exptime = 2
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

  values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'wasp16'
  ra_ref = 214.68297
  dec_ref = -20.275605
  aorname_ch2 =['r45674240','r45674496'] ;['r48705536', 'r48692736'];
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56578.27412; 56179.09319
  transit_duration=115.2
  period = 3.118601
  intended_phase = 0.5
  exptime = 2
  stareaor = 0
  plot_norm = 1.
  plot_corrnorm = 1.

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'hat22'
  ra_ref = 155.68122
  dec_ref = 50.128716
  aorname_ch2 = ['r45675008','r45674752' ] 
  aorname_ch1 =['r48704512','r48693504']     ;
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center =  56081.30088 ;56486.04060;
  transit_duration=172.2
  period = 3.21222
  intended_phase = 0.5
  exptime = 0.4
  stareaor = 0
  plot_norm = 0.1146;1.
  plot_corrnorm = 0.1146

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'hatp8'
  ra_ref = 343.0414
  dec_ref = 35.447403
  aorname_ch2= ['r36785664', 'r48695040', 'r48698112',  'r48699136',  'r48700160',  'r48704000',  'r48705280', 'r48684800',  'r48695296',  'r48698368',  'r48699392',  'r48703232',  'r48704256',  'r48705792', 'r48694528',  'r48695552',  'r48698624',  'r48699648',  'r48703488',  'r48704768',  'r48706048', 'r48694784',  'r48697856',  'r48698880',  'r48699904',  'r48703744',  'r48705024', 'r48694272', 'r48694016', 'r48693760', 'r48693248', 'r48692992', 'r48692480', 'r48692224', 'r48691968', 'r48684544', 'r48684288', 'r48684032', 'r48683520', 'r48683008', 'r48682496', 'r48681984', 'r48681728',' r48691712', 'r48691456', 'r48691200', 'r48690944'] ;ch2 snaps with 2 AORS on front from Knutson program

  aorname_ch1 =  ['r36787456'] ; ch1 knutson eclipse['r36784384',
;  aorname = [ 'r36789504','r36785664'] ; ch2 knutson eclipse
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center =   55207.80851;55210.88489;
  transit_duration=228.5
  period = 3.076378
  intended_phase = 0.5
  exptime = 2.
  stareaor = 1
  plot_norm = 0.0448
  Plot = 0.0440

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'WASP-14b'
  ra_ref = 218.27649
  dec_ref = 21.894575
  aorname_ch2 = ['allstares' , 'r45838592', 'r45840128', 'r45841408', 'r45842176', 'r45842944', 'r45844480', 'r45845248', 'r45846016', 'r45846784', 'r45839104', 'r45840896', 'r45841664', 'r45842432', 'r45843200', 'r45844736', 'r45845504', 'r45846272', 'r45847040', 'r45839616', 'r45841152', 'r45841920','r45843968','r45843712','r45843456','r45840640','r45840384','r45839872','r45839360','r45838848','r45838336','r48688384','r48688128','r48687872','r48687616','r48683776','r48683264', 'r48682752','r48682240','r48681472','r48681216','r48680704']  ; ch2
;ch2 stares = ['r45428992', 'r45428736', 'r45428480', 'r45428224', 'r45426688']
;'r45843968','r45843712','r45843456','r45840640','r45840384','r45839872','r45839360','r45838848','r45838336'

  aorname_ch1 = ['r31760384', 'r45426944', 'r45427200', 'r45427456','r45427712','r45427968']  ;ch1

  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56020.23972; 56172.81485; transit ;56187.39924  ;one of the secondary times
  transit_duration=183.6
  period = 2.243752
  intended_phase = 0.0
  exptime = 2
  stareaor = 1
  plot_norm =  0.0583 ; for 2.25 apradius
  plot_corrnorm =  0.0580; for 2.25 apradius
;  plot_norm =  0.0599  ; for 2.5 apradius
;  plot_corrnorm =  0.0595; for 2.5 apradius
;  plot_norm = .0611; 0.0599  ; for 3.0 apradius
;  plot_corrnorm = .0602; 0.0596; for 3.0 apradius
  mask = 'yes'
  maskreg = fltarr(32,32)
  maskreg[4:7, 12:14] =  !Values.F_NAN

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)


;---
  planetname = 'wasp7'
  ra_ref = 311.04294
  dec_ref = -39.225186
  aorname_ch2 = [ 'r31765248']
  aorname_ch1 = [ 'r31770880']  ; ch1
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 55374.29647
  transit_duration=226.5
  period = 4.954658
  intended_phase = 0.5
  exptime = 2
  stareaor =0;4
  plot_norm = 1
  plot_corrnorm = 1
  
   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---
  planetname = 'hatp17'
  ra_ref = 324.53611
  dec_ref = 30.488196
  aorname_ch2 = [ 'r42625280']
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 55963.75327
  transit_duration=243.4
  period = 10.338
  intended_phase = 0.5
  exptime = 2
  stareaor =0;4
  plot_norm = 1
  plot_corrnorm = 1
  
   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'hatp26'
  ra_ref = 213.15669
  dec_ref = 4.059612
  aorname_ch2 = [ 'r42624768']
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 56026.13620
  transit_duration=147.3
  period = 4.234516
  intended_phase = 0.5
  exptime = 2
  stareaor =0;4
  plot_norm = 1
  plot_corrnorm = 1
  
   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'hd97658'
  ra_ref = 168.63792
  dec_ref = 25.710523
  aorname_ch2 = [ 'r42608128']
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 55981.5450
  transit_duration=147.3
  period = 4.234516
  intended_phase =0.0
  exptime = 0.1
  stareaor =0;4
  plot_norm = 1
  plot_corrnorm = 1
  
   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'hip57274'
  ra_ref = 176.17053
  dec_ref = 30.95822
  aorname_ch2 = [ 'r44273920']
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 54801.015
  transit_duration=184.8
  period = 8.135
  intended_phase =0.0
  exptime = 0.4
  stareaor =0;4
  plot_norm = 1
  plot_corrnorm = 1
  
   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'corot2'
  ra_ref = 291.7771
  dec_ref = 1.3837
  aorname_ch1 = [ 'r31774976']
  aorname_ch2 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center = 55125.09100
  transit_duration=136.0
  period = 1.742994
  intended_phase =0.5
  exptime = 2.
  stareaor =0;4
  plot_norm = .0224
  plot_corrnorm = .0224
  
   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)


;---
  planetname = 'hat6'
  ra_ref = 354.77395
  dec_ref = 42.466135
  aorname_ch1 = [ 'r31758592']  ; ch1
  aorname_ch2 = ['r31751680']   ; ch2
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center =   55458.85371D; 55451.14774D
  transit_duration=210.4 
  period = 3.852985
  intended_phase = 0.5
  exptime = 2.
  stareaor = 0
  plot_norm =.050
  plot_corrnorm = .050

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)
;---------
  planetname = 'xo4'
  ra_ref = 110.38827
  dec_ref = 58.268128
  aorname_ch1 = [ 'r31766784']
  aorname_ch2 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center =   55180.50972D
  transit_duration=100. ; junk
  period = 4.125083
  intended_phase = 0.5
  exptime = 2.
  stareaor = 0
  plot_norm =0.046
  plot_corrnorm = 0.046

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'wasp43'
  ra_ref = 154.90806
  dec_ref = -9.8065685
  aorname_ch2 = [ 'r42615040']  ;ch2
  aorname_ch1 = [ 'r42614272'] ;ch1
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/' 
  utmjd_center =   55772.00350D
  transit_duration=69.6
  period = 0.813475
  intended_phase = 0.5
  exptime = 2.
  stareaor = 0
  plot_norm =.0342
  plot_corrnorm = .0342

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'NoisePixTest2'
  ra_ref = 359.99931
  dec_ref = 0.000694
  aorname_ch1 = [ 'r0000000000'] ;ch1
  aorname_ch2 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/simulation_JI/' 
  utmjd_center =   56701.677D
  transit_duration=69.6  ; junk
  period = 0.813475       ;junk
  intended_phase = 0.5
  exptime = 0.1
  stareaor = 0
  plot_norm =0.3852
  plot_corrnorm = 0.3852

   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;---
  planetname = 'pmap'
  ra_ref = 269.72771
  dec_ref = 67.793367
  aorname_ch2 = [ 'r44462336']
  aorname_ch1 = ['r0000000000']
  basedir = '/Users/jkrick/irac_warm/' 
  utmjd_center = 55981.5450
  transit_duration=147.3
  period = 4.234516
  intended_phase =0.0
  exptime = 0.1
  stareaor =0;4
  plot_norm = 0.4128
  plot_corrnorm = 0.4107
  
   values=list(ra_ref, dec_ref, aorname_ch2, aorname_ch1, basedir, chname, utmjd_center, transit_duration, period, intended_phase, exptime, mask, maskreg, stareaor, plot_norm, plot_corrnorm)
  planetinfo[planetname] = HASH(keys, values)

;--------------------




  ;test that this is all working
;  print, planetinfo.keys()
;  print, planetinfo['wasp13'].keys()
;  print, 'plan', planetinfo['wasp15', 'aorname']
  
  return, planetinfo

end
