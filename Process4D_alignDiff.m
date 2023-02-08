%% DataIO
datadir = '/Users/sung/Desktop/Data/20230207_1T-TaS2_Protochips/acquisition_12';

fname = 'scan_x128_y128.raw';
im4D = ( read_empad( fullfile(datadir,fname),128));

%%
Bragg = [64, 63];
wd = 20;
wd_fit = wd;

[nky, nkx, nsy, nsx] = size(im4D);
im4D_aligned = zeros(size(im4D));

gaus2D = @(x, xdata) x(1)*exp(-0.5*( (xdata(:,:,1)-x(2)).^2+(xdata(:,:,2)-x(3)).^2)/(x(4)^2))+x(5);

%circ = @(x, xdata) x(1)*double( (xdata(:,:,1)-x(2)).^2+(xdata(:,:,2)-x(3)).^2<x(4)^2 ) +x(5);

center = nky/2 + 1;
[xx,yy] = meshgrid( 1:nky, 1:nkx );
xdata = cat(3,xx,yy);


figure
subplot(1,2,1)
im1 = imagesc( zeros(2*wd+1));
axis image
subplot(1,2,2)
im2 = imagesc( zeros(2*wd+1));
axis image
t_h = title( '' );
for sx = 1:nsx
    for sy = 1:nsy
        diff_cur = im4D( :,:,sy,sx );

        xfit = ( Bragg(1)+(-wd_fit:wd_fit) );
        yfit = ( Bragg(2)+(-wd_fit:wd_fit) );
    
        xdatafit = xdata( yfit, xfit, :);        
        subIm = diff_cur( yfit, xfit );
    
        x0 = Bragg(1); y0 = Bragg(2);

        A0 = max(subIm(:));
        B0 = min(subIm(:));
    
        param_guess = [ A0, x0, y0, 3, B0];
        lb = [ A0/2, x0-wd/2, y0-wd/2, 3, B0/2];
        ub = [ A0*2, x0+wd/2, y0+wd/2, 3, B0*2];
        param_fit = lsqcurvefit( gaus2D, param_guess, xdatafit,subIm, lb, ub );
    
        im_align  = imtranslate( diff_cur, -[param_fit(2)-center, param_fit(3)-center],'bilinear');

        im4D_aligned(:,:, sy,sx) = im_align;

        im1.CData = subIm;
        im2.CData = gaus2D( param_fit, xdatafit);
        t_h.String = sprintf( '%d %d', sx, sy);
        drawnow

    end
end