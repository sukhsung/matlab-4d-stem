%% Read Empad Data

data_dir = 'data/';
fname = 'tas2microprobe_06_1150kx_cl1p5m_ap50_0p44mrad_spot8_mono60_80kV_93K_50x_50y_100z_432step_x128_y128.raw';
fid = fopen([data_dir, fname]);

nsx = 128;
nsy = 128;
nx = 128;
ny = 128;


A = fread(fid, nx*(ny+2)*nsx*nsy,'long',0,'l');
A = reshape(A,[ny, nx+2,nsx,nsy]);

im4D = A(:,3:nx,:,:);

%% Get Average CBED;
CBED_ave = squeeze( mean( mean( im4D, 3), 4) );

%% Manually choose disk positions
imageBC(CBED_ave)
title('Adjust Contrast and Hit Apply, then Return')
pause
[x0, y0] = em_clickAddRemove([], [], CBED_ave, false);
x0 = round(x0);
y0 = round(y0);
%%
numDisk = length(x0);
padding = 8;
centers = zeros(numDisk,nsx,nsy,2);
radii = zeros(numDisk,nsx,nsy,1);


for sx = 1:nsx
            disp(sx)
    for sy = 1:nsy
        for disk_ind = 1:numDisk

            cur_subIm = squeeze(im4D( y0(disk_ind)-padding:y0(disk_ind)+padding,x0(disk_ind)-padding:x0(disk_ind)+padding,sx,sy));
            
            max_subIm = max(cur_subIm(:));

            BW_subIm = imbinarize(cur_subIm,max_subIm*0.979);

            imagesc(BW_subIm)

            [center, radius] = imfindcircles(BW_subIm,[3,6],'ObjectPolarity','bright','Sensitivity',0.98);

            centers(disk_ind,sx,sy,:) = center + [x0(disk_ind)-padding-1, y0(disk_ind)-padding-1];
            radii(disk_ind,sx,sy) = radius;
        end
    end
end