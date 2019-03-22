%% data loading
wdir = 'data/';
%high t
%fname = '13_TaS2_300C_80keV_80kx_CL1p9m_10um_0_2mrad_spot6_shiftdiff_50x_50y_100z_432step_x128_y128.raw';
%twinned
%fname = '50_25C_80keV_450kx_CL1p9m_10um_0_2mrad_spot6_sideDiff_q8_50x_50y_100z_432step_x128_y128.raw';
%fname = '07_TaS2_25C_80keV_450kx_CL1p5m_10um_0_2mrad_spot6_sidediff_50x_50y_100z_432step_x128_y128.raw';
%comm
fname = '52_25C_80keV_450kx_CL1p9m_10um_0_2mrad_spot6_sideDiff_q8_50x_50y_100z_432step_x128_y128.raw';
dim = 128;
%e = empad( [wdir, fname], dim );
e = datacube(read_empad([wdir, fname],dim));
e.vis4D('detector');

%%
t1s1 = [31, 49; 49, 48; 40, 63];
t1s2 = [40, 44; 49, 58; 31, 59];
t2s1 = [30, 54; 44, 45; 46, 62];
t2s2 = [34, 45; 50, 53; 36, 63];

ae = e;
ae.im4D(:,:,:,:) = 0;
%sets = t2s1;
sets = cat(3,t1s1, t1s2);
twins(:,:,:,1) = sets;
sets = cat(3,t2s1, t2s2);
twins(:,:,:,2) = sets;
scan_stack = zeros(128,128,3);
for twin = 1:2
    ae.im4D(:,:,:,:) = 0;
    sets= twins(:,:,:,twin);
    for set = 1:size(sets,3)
        for peak = 1:size(sets,1)
           ae.im4D(sets(peak,2,set), sets(peak,1,set),:,:) = e.im4D(sets(peak,2,set), sets(peak,1,set),:,:);
           
           
           ae.im4D(sets(peak,2,set)-1, sets(peak,1,set)-1,:,:) = e.im4D(sets(peak,2,set)-1, sets(peak,1,set)-1,:,:);
           ae.im4D(sets(peak,2,set)-1, sets(peak,1,set),:,:) = e.im4D(sets(peak,2,set)-1, sets(peak,1,set),:,:);
           ae.im4D(sets(peak,2,set), sets(peak,1,set)-1,:,:) = e.im4D(sets(peak,2,set), sets(peak,1,set)-1,:,:);
           ae.im4D(sets(peak,2,set)+1, sets(peak,1,set)-1,:,:) = e.im4D(sets(peak,2,set)+1, sets(peak,1,set)-1,:,:);
           ae.im4D(sets(peak,2,set)-1, sets(peak,1,set)+1,:,:) = e.im4D(sets(peak,2,set)-1, sets(peak,1,set)+1,:,:);
           ae.im4D(sets(peak,2,set)+1, sets(peak,1,set),:,:) = e.im4D(sets(peak,2,set)+1, sets(peak,1,set),:,:);
           ae.im4D(sets(peak,2,set), sets(peak,1,set)+1,:,:) = e.im4D(sets(peak,2,set), sets(peak,1,set)+1,:,:);
           ae.im4D(sets(peak,2,set)+1, sets(peak,1,set)+1,:,:) = e.im4D(sets(peak,2,set)+1, sets(peak,1,set)+1,:,:);
        end
    end
    scan1 = ae.getScan();
    scan1 = scan1 - min(scan1(:));
    scan1 = scan1./max(scan1(:));

    scan_stack(:,:,twin) = scan1;
    ae.vis4D('detector');
end
%imageBC(scan);
figure; image(scan_stack)
imwrite(scan_stack,'rgb.tif')

%% PACBED
CBED_ave = e.pacbed;
imageBC(CBED_ave);

%%
vis4D_reverse(e.im4D);

%% masking peaks
%50
%bragg 1
%peak_pos = [20 29; 17 32; 15 37; 15 42; 19 47; 23 49; 29 48];
%bragg 2
%peak_pos = [55 25; 52 28; 50 33; 50 38; 54 43; 58 44; 63 44; 68 41; 69 36;69 31; 66 27; 61 24 ];

%52
peak_pos = [21 29; 17 32; 15 37; 15 42; 19 47; 23 49; 28 48; 32 46; 34 40; 34 35; 31 31; 27 29; ];
r = 2;
masked_scans = zeros(128,128, size(peak_pos,1));
for peak = 1:size(peak_pos,1)
    masked = e.applyDetector(peak_pos(peak,1), peak_pos(peak,2),0,r);
    masked_scans(:,:,peak) = squeeze( mean( mean( masked.im4D, 1), 2) );
end
%% Plotting maps
for peak = 1:size(peak_pos,1)
    imageBC(masked_scans(:,:,peak));
end
%% basura
return;

p1 = [20 29]; %flipped versus in image!!!
p2 = [17 32];
p3 = [15 37];
r = 2;
m1 = e.applyDetector(p1(1),p1(2),0,r);
m2 = e.applyDetector(p2(1),p2(2),0,r);
m3 = e.applyDetector(p3(1),p3(2),0,r);
%%
masked_cbed=squeeze( mean( mean( m1.im4D, 3), 4) );
imageBC(masked_cbed);

%%
masked_scan1 = squeeze( mean( mean( m1.im4D, 1), 2) );
imageBC(masked_scan1);

masked_scan2 = squeeze( mean( mean( m2.im4D, 1), 2) );
imageBC(masked_scan2);

masked_scan3 = squeeze( mean( mean( m3.im4D, 1), 2) );
imageBC(masked_scan3);
