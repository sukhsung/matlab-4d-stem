%% DataIO
%datadir = 'data/20181115_TaS2_Heating/';
%fname = '14_TaS2_300C_80keV_450kx_CL1p9m_10um_0_2mrad_spot6_shiftdiff_50x_50y_100z_432step_x128_y128.raw';
datadir = 'data/20181116_TaS2_Heating/ROI1_Switching/';
fname = '50_25C_80keV_450kx_CL1p9m_10um_0_2mrad_spot6_sideDiff_q8_50x_50y_100z_432step_x128_y128.raw';


e = datacube( read_empad([datadir,fname],128));
imagesc(e.getPacbed);
pacbed = e.getPacbed;
%% Remove Outlier

e_thr = removeOutlier(e, 3);
imagesc(e_thr.getPacbed);
pacbed = e_thr.getPacbed;

%% Hand pick the Bragg peaks of interest
[x0, y0] = em_clickAddRemove([], [], pacbed, false);
x0 = round(x0);
y0 = round(y0);

%% Find maximum within window and correct hand picked peaks
wd = 3;

[cc,rr] = meshgrid(1:2*wd+1,1:2*wd+1);


for ind = 1:length(x0)
    curIm = pacbed(y0(ind)-wd:y0(ind)+wd, x0(ind)-wd:x0(ind)+wd);
    
    [r,c] = find( curIm == max(curIm(:)));
    
    y0(ind) = y0(ind) + (r -wd-1);
    x0(ind) = x0(ind) + (c -wd-1);

end


%%
wd = 14;
ec(1) = e.crop4D([x0(1)-wd,x0(1)+wd,y0(1)-wd,y0(1)+wd],'detector');
pacbeds = ec(1).getPacbed;

for ind = 1:length(x0)
    ec(ind) = e.crop4D([x0(ind)-wd,x0(ind)+wd,y0(ind)-wd,y0(ind)+wd],'detector');
    curPbed= ec(ind).getPacbed;
    ec(ind).im4D = ec(ind).im4D/curPbed(wd+1,wd+1);
    pacbeds(:,:,ind) = ec(ind).getPacbed;
end




%%

im4Dcrop = ec(1).im4D;

for ind = 2:length(x0)
    im4Dcrop = ec(ind).im4D + im4Dcrop;
end
eave = datacube(im4Dcrop);

%%
pacbed = eave.getPacbed;
im4D = eave.im4D;

[ny, nx, nsx ,nsy] = size(im4D);
%% Hand pick the peaks of interest
[x, y] = em_clickAddRemove([], [], pacbed, false);

%% Apply Mask



r_maskIn = 5 ^2;
r_maskOut = 15^2;
% Pre calculate meshgrid for mask generation

[xx, yy] = meshgrid(1:nx, 1:ny);
 
for sx = 1:nsx
    for sy = 1:nsy
        curIm = (im4D(:,:,sy,sx));
        for pkInd = 1:length(x)
            rr = (xx - x(pkInd)).^2 + (yy - y(pkInd)).^2;
            curIm( rr<r_maskIn ) = min(pacbed( rr< r_maskIn ));   
            %curIm( rr>r_maskOut ) = 0;% min(pacbed( rr>r_maskOut ));   
        end
        im4D(:,:,sy,sx) = curIm;
    end
    disp(sx)
end


e_m = datacube(im4D);
e_m.vis4D;
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

%%
s = datacube(reshape(score, [ny, nx, ny, nx]));
s.vis4D;

c = datacube(reshape(coeff,[nsy,nsx,ny,nx]));
c.vis4D;

