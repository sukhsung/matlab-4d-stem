%% DataIO
datadir = 'data/';

fname = 'tas2_06_14mx_cl380mm_ap70_30mrad_spot8_mono60_80kV_93K_50x_50y_100z_432step_x128_y128.raw';
%fname = 'tas2microprobe_06_1150kx_cl1p5m_ap50_0p44mrad_spot8_mono60_80kV_93K_50x_50y_100z_432step_x128_y128.raw';
e = datacube( read_empad([datadir,fname],64));
%e = e.rebin4D(32);

pacbed = e.pacbed;
im4D = e.im4D;

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
        im4D(:,:,sx,sy) = curIm;
    end
    disp(sx)
end




%%



%e = e.rebin4D(8);
%clear e

pca_input = zeros(nsx*nsy, nx*ny);
for sx = 1: nsxz
    for sy = 1: nsy
        ind = sub2ind([nsy,nsx],sy,sx);
        
        pca_input(ind,:) = reshape(im4D(:,:,sx,sy),[1,nx*ny]);
        
        
    end
end

[coeff,score,latent] = pca(pca_input','Algorithm','eig');

score_im =reshape(score, [ny, nx, nsx, nsy]);
vis4D(score_im)
vis4D(reshape(coeff,[nsx,nsy,nsx,nsy]));