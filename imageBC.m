function imageBC(im)
    % Brightness & Contrast enabled imagesc
    % by Suk Hyun Sung @ hovdenlab
    % sukhsung@umich.edu
    
    % Create new figure and perform imagesc,
    % return figure, imagesc handle
    f = figure;
    h = imagesc(im);
    colormap('gray')
    % Find default min, max
    cmin = min(im(:));
    cmax = max(im(:)); 
    
    % Add sliders
    sl1 = uicontrol('style','slider','position',[10 60 20 300],'min', cmin, 'max', cmax,'Value', cmin);
    sl2 = uicontrol('style','slider','position',[35 60 20 300],'min', cmin, 'max', cmax,'Value', cmax);
    
    % filename box
    txtbox = uicontrol('style','edit','position',[50 5 80 20],'String','File Name');
    % Add button
    btApply = uicontrol('style','pushbutton','position',[10 5 30 20],'String','Apply','CallBack', @(hObject,eventdata) appliedIm(im,get(sl1,'Value'),get(sl2,'Value')));
    btSave = uicontrol('style','pushbutton','position',[140 5 30 20],'String','Save','CallBack', @(hObject,eventdata) saveIm(im,sl1,sl2,txtbox));
    
    
    % Listen to slider values and change B & C
    addlistener(sl1, 'Value', 'PostSet',@(hObject,eventdata) setCaxis(sl1,sl2));
    addlistener(sl2, 'Value', 'PostSet',@(hObject,eventdata) setCaxis(sl1,sl2));
end

function appliedIm(im,cmin,cmax)
    figure
    imagesc(im,[cmin, cmax])
end

function saveIm(im,sl1,sl2,txtbox)
    cmin = get(sl1,'Value');
    cmax = get(sl2,'Value');
    
    im( im<cmin ) = cmin;
    im( im>cmax ) = cmax;
    
    im = im - cmin;
    im = uint16(65535 * im / max(im(:)));
    
    imwrite(im, [txtbox.String,'.tif'])

end

function setCaxis(sl1,sl2)
    cmin = get(sl1,'Value');
    cmax = get(sl2,'Value');
    caxis([cmin, cmax]);
    title(sprintf('min = %f, max = %f', cmin, cmax));
end