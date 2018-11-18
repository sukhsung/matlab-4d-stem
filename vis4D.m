function vis4D(varargin)
    im4D = varargin{1};
    if nargin > 1
        searchDim = varargin{2};
    else
        searchDim = 'scan';
    end
            

    switch searchDim
        case 'scan'
            im_ave = squeeze( mean( mean( im4D, 1), 2) );
            im_init = squeeze(im4D(:,:,1,1));
        case 'detector'
            im_ave = squeeze( mean( mean( im4D, 3), 4) );            
            im_init = squeeze(im4D(1,1,:,:));
        otherwise
            error('Wrong Input')
    end
    
    
    f = figure;
    ax1 = subplot(1,2,1);
    ax2 = subplot(1,2,2);
    
    imagesc(ax1,im_ave)
    colormap(f,parula(65536))
    axis(ax1,'equal','off')
    h1 = drawpoint(ax1,'Deletable',false,'Position',[1 1],'DrawingArea',[1,1,size(im_ave)-1]);
    im2 = imagesc(ax2,im_init);    
    axis(ax2,'equal','tight','off')
    colorbar(ax2)

    
    % Find default min, max
    cmin = min(im4D(:));
    cmax = max(im4D(:)); 
    
    sl1 = uicontrol(f,'style','slider','position',[10 60 20 300],'min', cmin, 'max', cmax,'Value', cmin);
    sl2 = uicontrol(f,'style','slider','position',[35 60 20 300],'min', cmin, 'max', cmax,'Value', cmax);
    
    addlistener(h1,'MovingROI',@(src,evnt) draw4D(evnt,im4D,im2,ax2,searchDim));
    % Listen to slider values and change B & C
    addlistener(sl1, 'Value', 'PostSet',@(hObject,eventdata) caxis([get(sl1,'Value'), get(sl2,'Value')]));
    addlistener(sl2, 'Value', 'PostSet',@(hObject,eventdata) caxis([get(sl1,'Value'), get(sl2,'Value')]));

end

function draw4D(evenData,im4D,im,ax,searchDim)
    
    xy = round(evenData.CurrentPosition);
    x = xy(1); y = xy(2);
    switch searchDim
        case 'scan'
            sup_im = squeeze(im4D(:,:,y,x));
        case 'detector'
            sup_im = squeeze(im4D(y,x,:,:));
    end
    set(im,'CData',sup_im)
    colorbar(ax)

end

