%% Read Empad Data

wdir = 'data/';

fname = '21_TaS2_25C_80keV_57kx_CL1p9m_10um_0_2mrad_spot6_shiftdiff_50x_50y_100z_864step_x64_y64.raw';
%fname = '12_TaS2_250C_80keV_450kx_CL1p9m_10um_0_2mrad_spot6_shiftdiff_50x_50y_100z_864step_x64_y64.raw';
e = empad( [wdir,fname],64);
%e2 = empad( [wdir, fname], 64 );
vis4D(e.im4D)


%% Get Average CBED;
CBED_ave = e.pacbed;

%% Manually choose Q positions
imageBC(CBED_ave)
title('Adjust Contrast and Hit Apply, then Return')
pause
[x0, y0] = em_clickAddRemove([], [], CBED_ave, false);
x0 = round(x0);
y0 = round(y0);


%% Fit Gaussian to averaged CBED to estimate parameters
numDisk = length(x0);
padding = 4;

nsx = e.nsx;
nsy = e.nsy;

centers = zeros(numDisk,nsx,nsy,2);
radii = zeros(numDisk,nsx,nsy,1);
for disk_ind = 1:numDisk
[indep(:,:,1), indep(:,:,2)] = meshgrid(1:2*padding+1,1:2*padding+1);
subIm = CBED_ave( y0(disk_ind)-padding:y0(disk_ind)+padding,x0(disk_ind)-padding:x0(disk_ind)+padding);
param_guess = [padding+1, padding+1, padding,padding, max(subIm(:)), min(subIm(:))];
lb = [padding/2, padding/2, 0,0, 0, 0];
ub = [3*padding/2, 3*padding/2,inf,inf,inf,inf];

tol = 1e-15;
maxFunEvals = 1e6;
maxIter = 1e3;
opt = optimset('Display','Iter','TolFun',tol,'TolX',tol,'MaxFunEvals',maxFunEvals,'MaxIter',maxIter);
  
param_fit = lsqcurvefit(@gaus2d, param_guess, indep, subIm,lb,ub,opt);

x0(disk_ind) = x0(disk_ind)+round( param_fit(1) )-padding-1 ;
y0(disk_ind) = y0(disk_ind)+round( param_fit(2) )-padding-1 ;

subIm_cor =  CBED_ave( y0(disk_ind)-padding:y0(disk_ind)+padding,x0(disk_ind)-padding:x0(disk_ind)+padding);



figure
subplot(1,3,1)
imagesc(subIm);
subplot(1,3,2)
imagesc(gaus2d(param_fit,indep));
subplot(1,3,3)
imagesc(subIm_cor)

end
%%

m = median(subIm(:));
s = std(subIm(:));
param_guess = param_fit;
lb = [param_guess(1)-2, param_guess(2)-2, param_guess(3)*0.8, 0,0];
ub = [param_guess(1)+2, param_guess(2)+2, param_guess(3)*1.2, inf,inf];

progress= zeros(nsy,nsx);

% %             
subplot(1,3,1)
h_subim = imagesc(progress);
axis equal off
subplot(1,3,2)
h_fit = imagesc(progress);
axis equal off
subplot(1,3,3)
h_progress = imagesc(progress);
axis equal off
drawnow
for sx = 1:nsx
    disp(sx)
    for sy = 1:nsy
        for disk_ind = 1:numDisk
            % Get Sub Matrix
            cur_subIm = squeeze(e.im4D( y0(disk_ind)-padding:y0(disk_ind)+padding,x0(disk_ind)-padding:x0(disk_ind)+padding,sx,sy));
            
            [xc, yc] = centerOfMass(cur_subIm);
            
            centers(disk_ind,sx,sy,:) = [xc,yc] + [x0(disk_ind)-padding-1, y0(disk_ind)-padding-1];
         
            
            % remove outlier of image
%             cur_subIm( cur_subIm < m -s) = m-s;
%             cur_subIm( cur_subIm > m +s) = m+s;
%             
%             % Fit Gaussian
%             cur_param_fit = lsqcurvefit(@gaus2d, param_guess, indep, subIm,lb,ub,opt);
%             
% %            Save center and sigma
%            centers(disk_ind,sx,sy,:) = cur_param_fit(1:2) + [x0(disk_ind)-padding-1, y0(disk_ind)-padding-1];
%            radii(disk_ind,sx,sy) = cur_param_fit(3);
%             
%            set(h_subim, 'CData', cur_subIm);
%            set(h_fit, 'CData', gaus2d(cur_param_fit,indep));
%            drawnow;
        end
%         progress(:,sx) = ones(nsy,1);
%         set(h_progress, 'CData', progress);
%         drawnow
%         disp(sx)
    end
end


%% Analysis
% Choose reference point
dev = centers - centers(:,1,1,:);
dr =  sqrt( dev(:,:,:,1).^2 + dev(:,:,:,2).^2);
figure
for d = 1: numDisk
subplot(3,4,d)
imagesc(squeeze(dr(d,:,:,:)))
axis equal off
colormap('inferno')
end


