%d1
%wdir = '/Volumes/Noah/20181119_TaS2_Heating_EMPAD_PARADIM/EMPAD/20181115_TaS2_Heating/';
%d2
wdir = '/Users/sung/Desktop/20181116_TaS2_Heating/';
sub = '';
%calibration
%wdir = '/Volumes/Noah/20181119_TaS2_Heating_EMPAD_PARADIM/calibration/';
%rh
%wdir= '/Users/noah/Desktop/data_from_RH/20161122_EM_2016_11_22_TaS2hovden/';
fname = '08_TaS2_250C_80keV_450kx_CL1p9m_10um_0_2mrad_spot6_shiftdiff_50x_50y_26z_113step_x128_y128.raw';
dim = 128;
e = datacube(read_empad([wdir sub fname],dim));
%%
hexagonalLatticeBuilder(e);
%%
masked_e = e;
load('big_a.mat');
masked_e.im4D = masked_e.im4D .* mask;
load('big_b.mat');
masked_e.im4D = masked_e.im4D - e.im4D .* mask;
%load('c.mat');
%masked_e.im4D = masked_e.im4D - 1.* e.im4D .* mask ;

%[mask,mask_pos] = masked_e.generateHexagonalLatticeMask(12,-4,37,9,10); %x0, y0, a, theta, n
%%
imageBC(masked_e.getScan());
%%

e.vis4D('scan');

%%
imwrite(normalizer(e.getPacbed()),'pacbed.tif');
imwrite(normalizer(e.getScan()),'scan.tif');

%% hold slicing
rel = squeeze(e.im4D(850:900,684,14,:));
norm = sum(rel,1);
rel = rel./norm;
figure; imagesc(rel);
figure; imagesc(squeeze(e.im4D(600,600,:,:)));
%figure; imagesc(squeeze(e.im4D(600:800,700,:,5)));

%%
rel = squeeze(e.im4D(90:105,66,30,:));
norm = sum(rel,1);
rel = rel./norm;
figure; imagesc(rel);
%figure; imagesc(squeeze(e.im4D(600,600,:,:)));
%figure; imagesc(squeeze(e.im4D(600:800,700,:,5)));

%%
e = datacube(read_temsim('../20190304_pld_multislice/output/it15',2732,2732));
%%
r = e.rebin4D(4,'detector');
r.vis4D('detector');
%3,4 are scan dimensions
%%
r_im = r.im4D;
r_im = cat(3,r_im,r_im);
r_im = cat(4,r_im,r_im);
r.im4D = r_im;
r.vis4D('detector');

%%
r.im4D(:,:,end-2:end,:) = [];
r.im4D(:,:,:,end:end) = [];


%%
function [norm] = normalizer(data)
    norm = data-min(data(:));
    norm = norm./ max(norm(:));
end




