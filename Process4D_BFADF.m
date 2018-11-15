%% Read Empad Data

%wdir = '/Users/sukhyun/Desktop/data_from_RH/20161122_EM_2016_11_22_TaS2hovden/';
wdir = 'data/';
fname = 'tas2_06_14mx_cl380mm_ap70_30mrad_spot8_mono60_80kV_93K_50x_50y_100z_432step_x128_y128.raw';

e = empad( [wdir, fname], 128 );
vis4D(e.im4D)
%% Get Average CBED;
CBED_ave = e.pacbed;

f_cbed = figure;
imageBC(CBED_ave)
axis equal
colormap inferno
title('Adjust Contrast and Click Apply')
CBED_thresh = im_thr;
[center,radius] = imfindcircles(CBED_thresh,[10 25],'ObjectPolarity','bright','Sensitivity',0.90);
viscircles(center, radius);

%mradperpix = 30/radii;


%% Form Bright Field Image

bf = e.applyDetector(center(2),center(1), 0, radius);
vis4D(bf.im4D)

%% Form ADF Image

adf_min = 20; %in px
adf_max = 50; %in px


adf = e.applyDetector(center(2),center(1), adf_min, adf_max);
vis4D(adf.im4D)
