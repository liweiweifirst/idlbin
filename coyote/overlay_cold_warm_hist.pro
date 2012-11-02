pro overlay
ps_open, filename='/Users/jkrick/iwic/overlay_cold_warm_12s.ps',/portrait,/square,/color

greencolor = FSC_COLOR("Green", !D.Table_Size-4)

restore,  '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/xwarm1.sav'
restore,  '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/ywarm1.sav'
restore,  '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/xwarmfit1.sav'
restore,  '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/ywarmfit1.sav'

restore,  '/Users/jkrick/iwic/r25131776/xcold1.sav'
restore, '/Users/jkrick/iwic/r25131776/ycold1.sav'
restore,  '/Users/jkrick/iwic/r25131776/xcoldfit1.sav'
restore, '/Users/jkrick/iwic/r25131776/ycoldfit1.sav'


plot, xwarm, ywarm, xrange= [-0.0, 0.1], xtitle = 'Standard deviation', ytitle = 'Number', title = 'ch 1'
oplot, xwarmfit, ywarmfit, color = greencolor

oplot, xcold, ycold, linestyle = 2
oplot, xcoldfit, ycoldfit, color = greencolor, linestyle = 2

legend, ['cold T = 15.1','warm T = 21.1'], linestyle = [2,0] 



restore,  '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/xwarm2.sav'
restore,  '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/ywarm2.sav'
restore,  '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/xwarmfit2.sav'
restore,  '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/ywarmfit2.sav'

restore,  '/Users/jkrick/iwic/r25131776/xcold2.sav'
restore, '/Users/jkrick/iwic/r25131776/ycold2.sav'
restore,  '/Users/jkrick/iwic/r25131776/xcoldfit2.sav'
restore, '/Users/jkrick/iwic/r25131776/ycoldfit2.sav'


plot, xwarm, ywarm, xrange= [-0.0, 0.1], xtitle = 'Standard deviation', ytitle = 'Number', title = 'ch 2'
oplot, xwarmfit, ywarmfit, color = greencolor

oplot, xcold, ycold, linestyle = 2
oplot, xcoldfit, ycoldfit, color = greencolor, linestyle = 2

legend, ['cold T = 15.1','warm T = 21.1'], linestyle = [2,0] 

ps_close, /noprint,/noid

end
