

fname = 'test.raw';

fid = fopen('/Volumes/Untitled/tas2_03_14mx_cl380mm_ap70_30mrad_spot8_mono60_80kV_93K_50x_50y_100z_432step_x128_y128.raw');


i = 16;

A = fread(fid, 128*128*128*130,'long',0,'l');
im = reshape(A(1:end),[128,130,128,128]);

im = im - min(im(:)) - 1*10^13;
im = im - min(im(:));
%im = log(im + 1);
vis4D(im)