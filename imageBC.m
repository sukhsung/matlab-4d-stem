function [f,h] = imageBC(im)
    % Brightness & Contrast enabled imagesc
    % by Suk Hyun Sung @ hovdenlab
    % sukhsung@umich.edu
    
    % Create new figure and perform imagesc,
    % return figure, imagesc handle
    f = figure;
    h = imagesc(im);

    % Find default min, max
    cmin = min(im(:));
    cmax = max(im(:)); 
    
    % Add sliders
    sl1 = uicontrol('style','slider','position',[10 60 20 300],'min', cmin, 'max', cmax,'Value', cmin);
    sl2 = uicontrol('style','slider','position',[35 60 20 300],'min', cmin, 'max', cmax,'Value', cmax);
    
    % Add button
    bt = uicontrol('style','pushbutton','String','Apply','CallBack', @(hObject,eventdata) appliedIm(im,get(sl1,'Value'),get(sl2,'Value')));
    
    % Listen to slider values and change B & C
    addlistener(sl1, 'Value', 'PostSet',@(hObject,eventdata) caxis([get(sl1,'Value'), get(sl2,'Value')]));
    addlistener(sl2, 'Value', 'PostSet',@(hObject,eventdata) caxis([get(sl1,'Value'), get(sl2,'Value')]));
end

function appliedIm(im,cmin,cmax)
    figure
    imagesc(im,[cmin, cmax])
end