function vis4D(im_4d)
   % load im_4d_3PLD.mat
    im_ave = squeeze( mean( mean( im_4d, 1), 2) );
    im_ave_log = log(im_ave + 1);
    
    [nA1,nA2,ny,nx] = size(im_4d);
    
    A1_inds = 1:nA1;
    A2_inds = 1:nA2;
    

    f = figure;
    ax1 = subplot(1,2,1);
    ax2 = subplot(1,2,2);
    
    
    imagesc(ax1,im_ave_log)
    imagesc(ax2,zeros(ny,nx))
    %colormap(f,'inferno')
    
    axis(ax1,'equal','off')
    h1 = impoint(ax1,[10,10]);
    draw34D([10,10],im_4d,ax2);
    
    h1.addNewPositionCallback(@(p) draw34D(p,im_4d,ax2));
      

end

function draw34D(xy,im_4d,ax)
    xy = round(xy);
    x = xy(1); y = xy(2);
     
    sup_im = squeeze(im_4d(:,:,y,x));
    imagesc(ax,sup_im)
    axis(ax,'equal','tight')
    colorbar(ax)
end
