%%
data_dir = 'data/';
wdir = '/Users/noahschnitzer/Documents/projects/hlab/data/4d/';
%wdir = '/Volumes/gcc73/20181115_TaS2_Heating/';
fname = '13_TaS2_300C_80keV_80kx_CL1p9m_10um_0_2mrad_spot6_shiftdiff_50x_50y_100z_432step_x128_y128.raw';
dim = 128;
e = empad( [wdir, fname], dim );
vis4D(e.im4D)

%%
e_2 = e.rebin4D(2);
vis4D(e_2.im4D)


%%
CBED_ave = e.pacbed;
imageBC(CBED_ave);

%% fanning
x0 = 26;
y0 = 39;
com_image = zeros(128,128,6);
max_image = zeros(128,128,6);
std_image = zeros(128,128,6);

wedges = -180:60:120;
for wedge_no = 1:6
    wedge_no
    masked_4d = e.applyWedgeDetector(x0,y0,5,15,wedges(wedge_no), wedges(wedge_no)+60);
    scans_x = size(masked_4d.im4D,3);
    scans_y = size(masked_4d.im4D,4);
    %final_img_max = zeros(scans_x,scans_y);
    %final_img_com = zeros(scans_x,scans_y);
    for it = 1:scans_x
        for jt = 1:scans_y
            scan_im = squeeze(masked_4d.im4D(:,:,it,jt));
            [max_1, ind_1] = max(scan_im);
            [max_2,ind_2] = max(max_1);
            xmax = ind_1(ind_2);
            ymax = ind_2;
            dx = xmax-x0;
            dy = ymax-y0;
            theta = atan2d(dy,dx);
            max_image(it,jt,wedge_no) = theta;
            %final_img_max(it, jt) = theta;
            [ycom, xcom]  = centerOfMass(scan_im);
            %final_img_com(it,jt) = atan2d(ycom-y0, xcom-x0);
            com_image(it,jt,wedge_no) = atan2d(ycom-y0, xcom-x0);
            %std_image(it,jt,wedge_no) = std(scan_im(:));


            %figure;
            %imageBC(masked_4d.im4D(:,:,it,jt));
        end
        it
    end

end
%%
figure;
for it = 1:6
subplot(2,3,it)
imagesc(com_image(:,:,it))
end

%%
figure;
for it = 1:6
subplot(2,3,it)
imagesc(max_image(:,:,it))
end

%% circle

x0 = 26;
y0 = 39;
std_image = zeros(128,128);
masked_4d = e.applyDetector(x0,y0,5,15);
scans_x = size(masked_4d.im4D,3);
scans_y = size(masked_4d.im4D,4);
%final_img_max = zeros(scans_x,scans_y);
%final_img_com = zeros(scans_x,scans_y);
for it = 1:scans_x
    for jt = 1:scans_y
        scan_im = squeeze(masked_4d.im4D(:,:,it,jt));
        %[max_1, ind_1] = max(scan_im);
        %[max_2,ind_2] = max(max_1);
        %xmax = ind_1(ind_2);
        %ymax = ind_2;
        %dx = xmax-x0;
        %dy = ymax-y0;
        %theta = atan2d(dy,dx);
        %max_image(it,jt,wedge_no) = theta;
        %final_img_max(it, jt) = theta;
        %[ycom, xcom]  = centerOfMass(scan_im);
        %final_img_com(it,jt) = atan2d(ycom-y0, xcom-x0);
        %com_image(it,jt,wedge_no) = atan2d(ycom-y0, xcom-x0);
        std_image(it,jt) = std(scan_im(:));
        

        %figure;
        %imageBC(masked_4d.im4D(:,:,it,jt));
    end
    it
end

%%
figure;
imagesc(std_image);

%%
x0 = 26;
y0 = 39;
%masked_4d = e.applyDetector(x0, y0, 5, 15);
%masked_4d = e.applyWedgeDetector(x0, y0, 5, 15,-150,-110);
masked_4d = e.applyWedgeDetector(x0, y0, 5, 15,-180,180);
%vis4D(masked_4d.im4D);
%%
%vis4D(masked_4d.im4D);
%kx, ky, scanx, scany
scans_x = size(masked_4d.im4D,3);
scans_y = size(masked_4d.im4D,4);
final_img_max = zeros(scans_x,scans_y);
final_img_com = zeros(scans_x,scans_y);
for it = 1:scans_x
    for jt = 1:scans_y
        [max_1, ind_1] = max(squeeze(masked_4d.im4D(:,:,it,jt)));
        [max_2,ind_2] = max(max_1);
        xmax = ind_1(ind_2);
        ymax = ind_2;
        dx = xmax-x0;
        dy = ymax-y0;
        theta = atan2d(dy,dx);
        final_img_max(it, jt) = theta;
        [ycom, xcom]  = centerOfMass(squeeze(masked_4d.im4D(:,:,it,jt)));
        final_img_com(it,jt) = atan2d(ycom-y0, xcom-x0);
        
        
        %figure;
        %imageBC(masked_4d.im4D(:,:,it,jt));
    end
    it
end
%%
imageBC(final_img_max);
%%
imageBC(final_img_com);


%%
[cm, csd] = circStat(final_img_max(:));
%%
function [cm, cstd]= circStat(phis)
    rho = sum(exp(1i*phis))/length(phis);
    cm = angle(rho);
    cstd = sqrt(-2*log(abs(rho)));
end

function [xc, yc] = centerOfMass(im)
    M = sum(im(:));
    [xx,yy] = meshgrid(1:size(im,1), 1:size(im,2));
    
    xc = sum(xx(:).*im(:))/M;
    yc = sum(yy(:).*im(:))/M;

end




