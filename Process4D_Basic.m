%% DataIO
datadir = 'data/20181116_TaS2_Heating/ROI2/';

fname = '06_TaS2_25C_80keV_225kx_CL1p5m_10um_0_2mrad_spot6_sidediff_50x_50y_100z_432step_x128_y128.raw';
%fname = 'tas2microprobe_06_1150kx_cl1p5m_ap50_0p44mrad_spot8_mono60_80kV_93K_50x_50y_100z_432step_x128_y128.raw';
e = datacube( read_empad([datadir,fname],128));

imageBC(e.getPacbed)
axis equal
%e.vis4D
%e.vis4D('detector')