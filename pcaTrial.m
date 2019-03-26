%% DataIO
datadir = 'data/20181116_TaS2_Heating/ROI1_Switching/';

fname = '50_25C_80keV_450kx_CL1p9m_10um_0_2mrad_spot6_sideDiff_q8_50x_50y_100z_432step_x128_y128.raw';
%fname = 'tas2microprobe_06_1150kx_cl1p5m_ap50_0p44mrad_spot8_mono60_80kV_93K_50x_50y_100z_432step_x128_y128.raw';


e = datacube( read_empad([datadir,fname],128));
e.vis4D

%e = e.rebin4D(8);
%%
x0 = 65;
y0 = 80;
wd = 14;
ec = e.crop4D([x0-wd,x0+wd,y0-wd,y0+wd],'detector');
ec.vis4D


%%
pacbed = ec.getPacbed;
im4D = ec.im4D;

[ny, nx, nsx ,nsy] = size(im4D);
%% Hand pick the peaks of interest
[x, y] = em_clickAddRemove([], [], pacbed, false);

%% Apply Mask

r_mask2 = 5 ^2;
% Pre calculate meshgrid for mask generation

[xx, yy] = meshgrid(1:nx, 1:ny);
 
for sx = 1:nsx
    for sy = 1:nsy
        curIm = (im4D(:,:,sx,sy));
        for pkInd = 1:length(x)
            rr = (xx - x(pkInd)).^2 + (yy - y(pkInd)).^2;
            curIm( rr<r_mask2 ) = min(pacbed( rr< r_mask2 ));   
        end
        im4D(:,:,sy,sx) = curIm;
    end
    disp(sx)
end




%%



%e = e.rebin4D(8);
%clear e

pca_input = zeros(nsx*nsy, nx*ny);
for sx = 1: nsx
    for sy = 1: nsy
        ind = sub2ind([nsy,nsx],sy,sx);
        
        pca_input(ind,:) = reshape(im4D(:,:,sx,sy),[1,nx*ny]);
        
        
    end
end

[coeff,score,latent] = pca(pca_input','Algorithm','svd','Centered',false);

%c = datacube(reshape(coeff,[nsx,nsy,nx,ny]));
%%
s = datacube(reshape(score, [ny, nx, ny, nx]));
s.vis4D;
c = datacube(reshape(coeff,[nsy,nsx,ny,nx]));
c.vis4D;