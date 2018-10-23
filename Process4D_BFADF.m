%% Read Empad Data

%wdir = '/Users/sukhyun/Desktop/data_from_RH/20161122_EM_2016_11_22_TaS2hovden/';

fname = 'tas2_06_14mx_cl380mm_ap70_30mrad_spot8_mono60_80kV_93K_50x_50y_100z_432step_x128_y128.raw';
fid = fopen( fname );

A = fread(fid, 128*128*128*130,'long',0,'l');
im4D = reshape(A,[128,130,128,128]);


%% Get Average CBED);
CBED_ave = squeeze( mean( mean( im4D, 3), 4) );

f_cbed = figure;
imagesc(CBED_ave)
axis equal
colormap inferno

%% Find the Center Disk

f_cbed_thresh = figure;
max_cbed = max(CBED_ave(:));
min_cbed = max(CBED_ave(:));

max_thresh = 0.9;
min_thresh = 0.88;

CBED_thresh = CBED_ave;
CBED_thresh( CBED_thresh > max_thresh*max_cbed ) = max_thresh * max_cbed;
CBED_thresh( CBED_thresh < min_thresh*max_cbed ) = min_thresh * max_cbed;
imagesc(CBED_thresh);
colormap inferno
axis equal

[centers,radii] = imfindcircles(CBED_thresh,[10 20],'ObjectPolarity','bright','Sensitivity',0.9);
viscircles(centers, radii);


%mradperpix = 30/radii;


%% Form Bright Field Image

im4D = im4D - min(im4D(:));
[nx, ny, nsy, nsx] = size(im4D);
[xx, yy, ~, ~] = ndgrid(1:nx, 1:ny,1:nsx,1:nsy);

rr = (yy - centers(1)).^2 + (xx - centers(2)).^2;

bf_mask = ( rr <= radii^2 );

bf4D = im4D.*bf_mask;

vis4D(bf4D)

%% Form ADF Image

adf_min = 20; %in px
adf_max = 50; %in px

adf_mask = ( rr <= adf_max^2 & rr >= adf_min^2);

adf4D = im4D.*adf_mask;

vis4D(adf4D)

