%% data loading
datadir = 'data/20181116_TaS2_Heating/ROI2/';

fname = '07_TaS2_25C_80keV_450kx_CL1p5m_10um_0_2mrad_spot6_sidediff_50x_50y_100z_432step_x128_y128.raw';
%twinned
%fname = '50_25C_80keV_450kx_CL1p9m_10um_0_2mrad_spot6_sideDiff_q8_50x_50y_100z_432step_x128_y128.raw';
%comm
%fname = '52_25C_80keV_450kx_CL1p9m_10um_0_2mrad_spot6_sideDiff_q8_50x_50y_100z_432step_x128_y128.raw';
dim = 128;
%e = empad( [wdir, fname], dim );
e = datacube(read_empad([datadir, fname],dim));
e.vis4D('detector');

%% PACBED
CBED_ave = e.getPacbed;
imageBC(CBED_ave);

%%
twin1 = e.getSingleImage(31,49);
twin2 = e.getSingleImage(34,45);

twin1 = twin1- min(twin1(:));
twin1 = twin1/max(twin1(:));
twin2 = twin2- min(twin2(:));
twin2 = twin2/max(twin2(:));


twinRGB = twin1;
twinRGB(:,:,2) = twin2;
twinRGB(:,:,3) = zeros(size(twin1));