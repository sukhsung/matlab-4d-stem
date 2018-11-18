function vis4D(im_4d)

    im_ave = squeeze( mean( mean( im_4d, 3), 4) );
    
    f = figure;
    ax1 = subplot(1,2,1);
    ax2 = subplot(1,2,2);
    
    imagesc(ax1,im_ave)
    colormap(f,parula(65536));
    axis(ax1,'equal','off')
    h1 = drawpoint(ax1,'Deletable',false,'Position',[1 1]);
    im2 = imagesc(ax2,squeeze(im_4d(1,1,:, :)));    
    axis(ax2,'equal','tight','off')
    colorbar(ax2)

    
    % Find default min, max
    cmin = min(im_4d(:));
    cmax = max(im_4d(:)); 
    
    sl1 = uicontrol(f,'style','slider','position',[10 60 20 300],'min', cmin, 'max', cmax,'Value', cmin);
    sl2 = uicontrol(f,'style','slider','position',[35 60 20 300],'min', cmin, 'max', cmax,'Value', cmax);
    
    addlistener(h1,'MovingROI',@(src,evnt) draw4D(evnt,im_4d,im2,ax2));
    % Listen to slider values and change B & C
    addlistener(sl1, 'Value', 'PostSet',@(hObject,eventdata) caxis([get(sl1,'Value'), get(sl2,'Value')]));
    addlistener(sl2, 'Value', 'PostSet',@(hObject,eventdata) caxis([get(sl1,'Value'), get(sl2,'Value')]));

end

function draw4D(evenData,im_4d,im,ax)
    
    xy = round(evenData.CurrentPosition);
    x = xy(1); y = xy(2);
    sup_im = squeeze(im_4d(y,x,:,:));
    set(im,'CData',sup_im)
    colorbar(ax)

end

