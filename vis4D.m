function vis4D(im_4d)

    im_ave = squeeze( mean( mean( im_4d, 1), 2) );
    
    f = figure;
    ax1 = subplot(1,2,1);
    ax2 = subplot(1,2,2);
    
    imagesc(ax1,im_ave)
    colormap(f,'inferno')
    axis(ax1,'equal','off')
    h1 = drawpoint(ax1,'Deletable',false,'Position',[50 50]);
    im2 = imagesc(ax2,squeeze(im_4d(:,:,50, 50)));    
    axis(ax2,'equal','tight','off')
    colorbar(ax2)

    
   addlistener(h1,'MovingROI',@(src,evnt) draw4D(evnt,im_4d,im2,ax2));

end

function draw4D(evenData,im_4d,im,ax)
    
    xy = round(evenData.CurrentPosition);
    x = xy(1); y = xy(2);
    sup_im = squeeze(im_4d(:,:,y,x));
    set(im,'CData',sup_im)
    colorbar(ax)

end

