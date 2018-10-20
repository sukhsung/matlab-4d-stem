function [f,h] = myImagesc(im)
    
    cmin = min(im(:));
    cmax = max(im(:));
    
    
    f = figure;
    h = imagesc(im);

    sl1 = uicontrol('style','slider','position',[10 0 10 300],'min', cmin, 'max', cmax,'Value', cmin);
    sl2 = uicontrol('style','slider','position',[30 0 10 300],'min', cmin, 'max', cmax,'Value', cmax);
    
    addlistener(sl1, 'Value', 'PostSet',@(hObject,eventdata) caxis([get(sl1,'Value'), get(sl2,'Value')]));
    addlistener(sl2, 'Value', 'PostSet',@(hObject,eventdata) caxis([get(sl1,'Value'), get(sl2,'Value')]));
    
end
