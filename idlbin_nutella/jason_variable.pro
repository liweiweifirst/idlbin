pro jason_variable
ra = [265.2014160 ,264.9981689 ,264.8756104 ,265.1251526 ,264.9855652 ,265.0793457 ,265.0325928 ,265.0628052 ,265.0370789 ,265.0438538 ,265.0905457 ,265.0192566 ,265.0273743 ,264.9758911 ,264.9370422 ,264.9657898 ,265.0337219 ,265.0077820 ,264.9830322 ,265.0755920 ,265.0514832 ,264.9953918 ,264.9815063 ,264.9079895 ,265.1853027 ,265.0873413 ,265.0104065 ,265.2487488 ,264.9339294 ,265.0144348 ,264.9145508 ,265.0120850 ,264.9297791 ,264.8664856 ,264.9659119 ,265.1011963 ,265.0574341 ,265.0524597 ,265.0514526 ]


dec = [68.9389420,68.9462357,68.9552612,68.9603271,68.9651031,68.9737244,68.9814377,68.9827576,68.9856033,68.9859467,68.9866257,68.9869919,68.9880600,68.9883575,68.9933167,68.9945679,68.9974365,68.9985123,68.9998016,69.0030899,69.0042648,69.0056152,69.0056915,69.0077591,69.0113525,69.0135117,69.0143738,69.0186081,69.0195923,69.0244904,69.0279388,69.0299530,69.0316086,69.0313568,69.0333786,69.0380707,69.0492554,69.0498352,69.0506134]

;findobject, ra, dec

;do the same for morgans's variable stars
morgandec = [69.006256 ,68.986572,68.999542,69.020775,69.015053,68.992767,69.020241]
morganra = [264.911638 ,264.932876,265.074377,264.935597,264.913337,265.076388,264.989773]

findobject, morganra, morgandec
end
