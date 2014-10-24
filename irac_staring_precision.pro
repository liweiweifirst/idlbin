pro irac_staring_precision
;make a plot of the noise levels in exoplanet staring mode
;observations from the literature

;Knutson et al. 2011 HD189733
;ch1
x = [1.019,3.314,12.192,40.485,107.324,201.627,335.272,464.237,561.101,716.222,942.553,1.240e3,1.583e3,2.021e3,2.580e3,3.293e3,4.203e3,5.362e3,7.170e3,9.013e3,1.150e4,1.469e4,1.875e4,2.286e4,2.558e4,2.950e4,3.615e4,5.005e4]
y = [3.300e-3,1.858e-3,1.007e-3,5.562e-4,3.520e-4,2.745e-4,2.266e-4,1.982e-4,1.880e-4,1.725e-4,1.583e-4,1.452e-4,1.371e-4,1.295e-4,1.222e-4,1.154e-4,1.105e-4,1.029e-4,9.576e-5,8.785e-5,8.060e-5,7.395e-5,6.687e-5,5.629e-5,5.915e-5,5.479e-5,4.979e-5,4.355e-5]
p1 = plot(x, y/y(0), xtitle = 'Bin Size', ytitle = 'RMS', title = '3.6 microns', /xlog, /ylog, yrange = [0.01, 1.0], xrange = [1, 1E5])
t = text(1E3, 0.3, 'HD189733', color = 'black', /data)
;ch2 
x = [1.007,3.784,12.329,41.839,100.433,192.703,268.589,342.940,444.611,585.297,758.819,1.030e3,1.356e3,1.731e3,2.210e3,2.822e3,3.603e3,4.601e3,5.875e3,7.501e3,9.874e3,1.261e4,1.610e4,2.119e4,2.706e4,3.455e4,4.411e4,5.218e4,5.380e4]
y = [4.635e-3,2.370e-3,1.309e-3,7.224e-4,4.739e-4,3.488e-4,3.067e-4,2.734e-4,2.437e-4,2.172e-4,1.936e-4,1.726e-4,1.561e-4,1.411e-4,1.295e-4,1.205e-4,1.138e-4,1.044e-4,9.854e-5,9.304e-5,8.659e-5,8.058e-5,7.499e-5,6.782e-5,6.156e-5,5.707e-5,4.943e-5,4.101e-5,5.161e-5]

p2 = plot(x, y/y(0), xtitle = 'Bin Size', ytitle = 'RMS', title = '4.5 microns', /xlog, /ylog, yrange = [0.01, 1.0])
t = text(1E3, 0.3, 'HD189733', color = 'black', /data)

;--------------------------------------


;Knutson et al. 2012 GJ436
;ch1  
x =[1.035,6.193,7.319,8.650,10.224,12.083,14.281,16.879,19.949,23.578,27.482,32.936,38.927,45.372,55.140,64.268,77.024,98.968,116.970,141.278,170.366,204.179,244.704,298.415,366.474,448.482,533.983,648.675,788.324,958.037]
y=[0.978,0.416,0.388,0.359,0.334,0.307,0.288,0.265,0.246,0.229,0.215,0.200,0.187,0.174,0.162,0.152,0.143,0.133,0.124,0.117,0.110,0.104,0.098,0.091,0.085,0.078,0.073,0.068,0.064,0.061]

p1 = plot(x, y/y(0), color = 'blue', overplot = p1)

;ch1
x=[1.028,7.126,8.422,9.680,11.127,13.151,15.116,17.866,20.532,24.271,27.897,32.972,38.970,45.421,51.487,60.852,70.926,82.053,96.354,110.980,132.149,151.539,175.479,201.840,231.696,277.114,323.857,382.767,452.392,534.346,637.155,756.889,919.835]

y = [0.987,0.380,0.352,0.329,0.308,0.284,0.265,0.246,0.229,0.212,0.195,0.180,0.166,0.155,0.144,0.133,0.124,0.115,0.107,0.099,0.093,0.086,0.080,0.075,0.069,0.064,0.060,0.056,0.053,0.050,0.046,0.044,0.042]


p1 = plot(x, y/y(0), color = 'blue', overplot = p1)
t = text(1E3, 0.4, 'GJ436', color = 'blue', /data, target = p1)


;ch2
x=[1.036,3.821,4.503,5.191,5.967,7.052,8.335,9.580,11.323,13.015,14.960,17.878,20.323,24.020,28.389,34.024,38.567,45.583,53.874,61.925,71.179,84.126,102.237,121.297,139.726,165.984,191.331,229.305,271.016,333.980,394.731,454.398,552.965,670.101,803.099,936.056]

y =[0.980,0.513,0.474,0.443,0.411,0.379,0.351,0.326,0.302,0.282,0.262,0.243,0.226,0.208,0.191,0.177,0.165,0.152,0.141,0.131,0.122,0.113,0.104,0.096,0.089,0.082,0.076,0.070,0.065,0.060,0.056,0.052,0.048,0.045,0.042,0.039]

p2 = plot(x, y/y(0), color = 'blue', overplot = p2)

;ch2
x = [1.033,22.951,59.712,71.671,84.437,100.438,119.987,139.851,162.423,189.990,224.549,265.394,322.529,403.035,476.347,563.467,656.200,786.439,949.230]
y = [0.988,0.216,0.136,0.126,0.117,0.108,0.099,0.092,0.086,0.079,0.074,0.069,0.064,0.058,0.055,0.051,0.048,0.045,0.042]

p2 = plot(x, y/y(0), color = 'blue', overplot = p2)
t = text(1E3, 0.4, 'GJ436', color = 'blue', /data)

;--------------------------------------

;Zellem et al. 2014 HD209458
;ch2
x = [1.020,2.222,8.667,19.615,53.924,84.341,106.510,138.487,182.711,230.736,291.385,367.976,478.453,604.214,763.031,963.592,1.217e3,1.537e3,1.941e3,2.451e3,3.281e3,4.266e3,5.387e3,7.005e3,9.144e3,1.201e4,1.639e4,2.514e4,3.932e4,4.870e4,6.155e4]
y = [3.229e-3,2.176e-3,1.100e-3,7.415e-4,4.651e-4,3.940e-4,3.538e-4,3.176e-4,2.852e-4,2.631e-4,2.427e-4,2.239e-4,2.065e-4,1.957e-4,1.830e-4,1.734e-4,1.643e-4,1.578e-4,1.515e-4,1.436e-4,1.343e-4,1.255e-4,1.142e-4,1.054e-4,9.087e-5,7.872e-5,6.462e-5,5.598e-5,4.596e-5,3.511e-5,2.683e-5]

p2 = plot(x, y/y(0), color = 'red', overplot = p2)
t = text(1E3, 0.5, 'HD209458', color = 'red', /data)



;----------------------------------
;now add straight root N

source_mjy = 1094.              ;mJy  from Star-pet
exptime = 12.

;ch2
gain = 3.71
pixel_scale = 1.22
flux_conv = .1469
xmax = max(p2.xrange)
bin_scale = findgen(xmax) + 1
root_n = sqrt(bin_scale)
source_electrons = mjy_to_electron( source_mjy, pixel_scale, gain, exptime, flux_conv)
sigma_poisson = sqrt(source_electrons)
y =  (sigma_poisson / root_n) / source_electrons

p2 = plot( bin_scale, y/y(0), thick = 3, linestyle = 2, overplot = p2)
;now add root2 * root N
y2 =  3. * y/y(0)
p2 = plot( bin_scale, y2, thick = 3, linestyle = 2, color = 'grey', overplot = p2)

;ch1
gain = 3.7
pixel_scale = 1.22
flux_conv = .1253
xmax = max(p2.xrange)
bin_scale = findgen(xmax) + 1
root_n = sqrt(bin_scale)
source_electrons = mjy_to_electron( source_mjy, pixel_scale, gain, exptime, flux_conv)
sigma_poisson = sqrt(source_electrons)
y =  (sigma_poisson / root_n) / source_electrons

p1 = plot( bin_scale, y/y(0), thick = 3, linestyle = 2, overplot = p1)

;now add root2 * root N
y2 =  3. * y/y(0)
p1 = plot( bin_scale, y2, thick = 3, linestyle = 2, color = 'grey', overplot = p1)

;and some labels
t = text(180, .02, 'Photon noise', /data, target = p1)
t = text(23, 0.7, '3X photon', /data, target = p1, color = 'grey')
t = text(180, .02, 'Photon noise', /data, target = p2)
t = text(23, 0.7, '3X photon', /data, target = p2, color = 'grey')
end
