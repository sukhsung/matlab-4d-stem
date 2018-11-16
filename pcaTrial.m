
wdir = 'data/';

fname = '21_TaS2_25C_80keV_57kx_CL1p9m_10um_0_2mrad_spot6_shiftdiff_50x_50y_100z_864step_x64_y64.raw';
%fname = 'tas2microprobe_06_1150kx_cl1p5m_ap50_0p44mrad_spot8_mono60_80kV_93K_50x_50y_100z_432step_x128_y128.raw';
e = empad( [wdir,fname],128);
%e2 = empad( [wdir, fname], 64 );
%vis4D(e.im4D)

e = e.rebin4D(8);
%clear e

pca_input = zeros(e.nsx*e.nsy, e.nx*e.ny);
for sx = 1: e.nsx
    for sy = 1: e.nsy
        ind = sub2ind([e.nsy,e.nsx],sy,sx);
        
        pca_input(ind,:) = reshape(e.im4D(:,:,sx,sy),[1,e.nx*e.ny]);
        
        
    end
end

[coeff,score,latent] = pca(pca_input');

score_im =reshape(score, [e.nx, e.ny, e.nsx, e.nsy]);
vis4D(score_im)