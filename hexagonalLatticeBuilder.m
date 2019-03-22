function [] = hexagonalLatticeBuilder(datacube)
    bkg = datacube.getPacbed();
    f = figure;
    ax_im = axes;
    imagesc(bkg);
    imsz = size(bkg);
    dcsz = size(datacube.im4D);
    colormap(gray);
    hold on;
    cmin = min(bkg(:));
    cmax = max(bkg(:));
    scat = scatter([],[],10,'red');
    axis equal;
    p1 = uipanel(f,'Position',[0 0 0.1 1]);
    p2 = uipanel(f,'Position',[0.9 0.1 0.1 .9]);
    sl_c1 = uicontrol(p1,'style','slider','Units','normalized','position',[0 0 0.5 1], 'min', cmin, 'max', cmax, 'Value', cmin);
    sl_c2 = uicontrol(p1,'style','slider','Units','normalized','position',[0.5 0 0.5 1], 'min', cmin, 'max', cmax, 'Value', cmax);
    addlistener(sl_c1,'Value','PostSet',@(hObject,eventdata) caxis(ax_im,[get(sl_c1,'Value'),get(sl_c2,'Value')]));
    addlistener(sl_c2,'Value','PostSet',@(hObject,eventdata) caxis(ax_im,[get(sl_c1,'Value'),get(sl_c2,'Value')]));
    
    h1 = drawpoint(ax_im,'Deletable',false,'Position',[1 1],'DrawingArea',[1,1,size(bkg,2)-1,size(bkg,1)-1],'Color','green');
    
    sl_a = uicontrol(p2,'style','slider','Units','normalized','position',[0 0 0.33 1], 'min', .1, 'max', max(imsz), 'Value', 10);
    sl_theta = uicontrol(p2,'style','slider','Units','normalized','position',[0.33 0 0.33 1], 'min', -60, 'max', 60, 'Value', 0);
    sl_n = uicontrol(p2,'style','slider','Units','normalized','position',[0.66 0 0.33 1], 'min', 0, 'max', 50, 'Value', 50);
    addlistener(h1,'MovingROI',@(src,evnt) handleLatticeParams(imsz,scat,h1,sl_a,sl_theta,sl_n) );
    addlistener(sl_a,'Value','PostSet',@(src,evnt) handleLatticeParams(imsz,scat,h1,sl_a,sl_theta,sl_n) );
    addlistener(sl_theta,'Value','PostSet',@(src,evnt) handleLatticeParams(imsz,scat,h1,sl_a,sl_theta,sl_n) );
    addlistener(sl_n,'Value','PostSet',@(src,evnt) handleLatticeParams(imsz,scat,h1,sl_a,sl_theta,sl_n) );
    
    
    txtbox = uicontrol('style','edit','Units','normalized','position',[.6 0 .3 .07],'String','File Name');
    btSave = uicontrol('style','pushbutton','Units','normalized','position',[.9 0 .1 .07],'String','Save Mask','CallBack', @(hObject,eventdata) saveMask(txtbox,dcsz,imsz,scat,h1,sl_a,sl_theta,sl_n));

    
    handleLatticeParams(imsz,scat,h1,sl_a,sl_theta,sl_n);
end

function saveMask(txtbox,dcsz,imsz,scat,h1,sl_a,sl_theta,sl_n)
    pos = handleLatticeParams(imsz,scat,h1,sl_a,sl_theta,sl_n);
    pos = round(pos);
    fname = get(txtbox,'String');
    mask = zeros(dcsz);
    for it = 1:size(pos,2)
        mask(pos(2,it),pos(1,it),:,:) = 1; 
    end
    save([fname '.mat'],'mask','pos');

end

function pos = handleLatticeParams(imsz,scat,pointer,sl_a,sl_theta,sl_n)
    posn = get(pointer,'Position');
    x0 = round(posn(1));
    y0 = round(posn(2));
    a = get(sl_a,'Value');
    theta = get(sl_theta,'Value');
    n = round(get(sl_n,'Value'));
    pos = drawHexagonalLattice(imsz,scat,x0,y0,a,theta,n);
end

function pos = drawHexagonalLattice(imsz,scat,x0,y0,a,theta,n)
            
            phi = -30*pi/180;
            theta = theta*pi/180;
            a1 = [cos(phi+theta) -sin(phi+theta); sin(phi+theta) cos(phi+theta)]*[1;0];
            a2 = [cos(theta) -sin(theta); sin(theta) cos(theta)]*[0;1];
            grid = linspace(-n,n,2*n+1);
            if n > 0
            [h, k] = meshgrid(grid,grid);
            h = h(:);
            k = k(:);
            rem = h+k==0;
            h(rem) = [];
            k(rem) = [];
            pos_x = a1*h';
            pos_y = a2*k';
            pos = pos_x+pos_y;
            else
               pos = [0;0]; 
            end
            pos = pos*a;
            pos(1,:) = pos(1,:)+x0;
            pos(2,:) = pos(2,:)+y0;
            pos = round(pos);
            
            pos(:,pos(1,:) < 1) = [];
            pos(:,pos(2,:) < 1) = [];
            pos(:,pos(1,:) > imsz(1)) = [];
            pos(:,pos(2,:) > imsz(2)) = [];
            set(scat,'XData',pos(1,:));
            set(scat,'YData',pos(2,:));
            title(['x0:' num2str(x0) ', y0: ' num2str(y0) ', a:' num2str(a) ', theta: ' num2str(theta*180/pi) ', n:' num2str(n)]);
            
            %s = scatter(pos(1,:),pos(2,:));
end