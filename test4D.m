function test4D(im4D)

%     thisObj = varargin{1};
%     
%     if nargin > 1
%         searchDim = varargin{2};
%     else
%         searchDim = 'scan';
%     end

    im_init_r = squeeze( mean( im4D, [1, 2]) );
    im_init_k = squeeze( im4D(:,:,1,1) );%mean( im4D, [1, 2]) );
    [nx, ny, nsx, nsy] = size( im4D );

    % Find default min, max
    cmin_r = min(im_init_r(:));
    cmax_r = max(im_init_r(:)); 
    cmin_k = min(im_init_k(:));
    cmax_k = max(im_init_k(:)); 

    cmin = min(im4D(:));
    cmax = max(im4D(:));

    nedge = 256;
    edges_r = linspace( cmin_r, cmax_r, nedge);
    edges_k = linspace( cmin_k, cmax_k, nedge);
    bins_r  = histcounts( im_init_r, edges_r );
    bins_k  = histcounts( im_init_k, edges_k );



    f = figure("Name", "4D Viewer by SSH", "Position", [100 100 950 620]);

%     ax(1) = uiaxes( f, "Position", [ 50 50 400 400], "XLimitMethod", "Tight");%, "XLim", [1,nkx], "YLim", [1,nky] );
%     ax(2) = uiaxes( f, "Position", [450 50 400 400], "XLimitMethod", "Tight");%"XLim", [1,nx], "YLim", [1,ny] );
    ax(1) = axes( f, "Units", "Points", "Position", [ 50 50 400 400], "XLimitMethod", "Tight");%, "XLim", [1,nkx], "YLim", [1,nky] );
    ax(2) = axes( f, "Units", "Points", "Position", [500 50 400 400], "XLimitMethod", "Tight");%"XLim", [1,nx], "YLim", [1,ny] );

    ax(3) = axes( f, "Units", "Points", "Position", [ 50  500 400 100], "XLimitMethod", "Tight");
    ax(4) = axes( f, "Units", "Points", "Position", [ 500 500 400 100], "XLimitMethod", "Tight");

    im(1) = imagesc(ax(1), im_init_r);
    im(2) = imagesc(ax(2), im_init_k);
    % B&C
    im(3) = plot( ax(3), edges_r(1:(nedge-1)), bins_r);% histogram( ax(3), im_init_r(:) );
    im(4) = plot( ax(4), edges_k(1:(nedge-1)), bins_k);% histogram( ax(3), im_init_r(:) );
    ax(3).XLim = [ cmin_r, cmax_r ];
    ax(4).XLim = [ cmin_k, cmax_k ];

    ax(3).YLim = [ 0, max(bins_r) ];
    ax(4).YLim = [ 0, max(bins_k) ];

    hold( ax(3:4), 'on')
    cr_r(1) = plot( ax(3), cmin_r*[1 1], max(bins_r)*[0 1], 'r-');
    cr_r(2) = plot( ax(3), cmax_r*[1 1], max(bins_r)*[0 1], 'r-');
    cr_k(1) = plot( ax(4), cmin_k*[1 1], max(bins_k)*[0 1], 'r-');
    cr_k(2) = plot( ax(4), cmax_k*[1 1], max(bins_k)*[0 1], 'r-');

    axis( ax(1:2), 'equal','off')
    colormap( ax(1), gray(65535) )
    colormap( ax(2), gray(65535) )

    % Real Space Selector
    selector_r = uicontrol(f, "Style", "popupmenu", ...
        "String", ["Point", "Rectangle", "Full"],...
        "Position",[50 0 100 40] );

    % UI setup    
    roi_r(1) = drawpoint(ax(1),'Deletable',false,'Position',[1 1],...
        'DrawingArea',[1, 1, nsy-1, nsx-1],'Visible','on');
    roi_r(2) = drawrectangle(ax(1),'Deletable',false,'Position',[1, 1, round(nsx/5), round(nsx/5)],...
        'DrawingArea',[1, 1, nsy-1, nsx-1],'Visible','off');
    roi_r(3) = drawrectangle(ax(1),'Deletable',false,'Position',[1, 1, nsy-1, nsx-1],...
        'DrawingArea',[1, 1, nsy-1, nsx-1],'Visible','off','InteractionsAllowed','none',...
        'FaceAlpha',0);

    addlistener( roi_r(1),'MovingROI',@(src,evnt) roi_r_1_moved( roi_r,im4D,im, ax) );
    addlistener( roi_r(2),'MovingROI',@(src,evnt) roi_r_2_moved( roi_r,im4D,im, ax) );
    addlistener( roi_r(3),'MovingROI',@(src,evnt) roi_r_3_moved( roi_r,im4D,im, ax) );
    selector_r.Callback = @(src,evt) select_roi_r(src, roi_r, im4D, im, ax);

    % K Space Selector
    selector_k = uicontrol(f, "Style", "popupmenu", ...
        "String", ["Point", "Rectangle", "Full"],...
        "Position",[500 0 100 40] );
    selector_k.Value = 3;

    % UI setup    
    roi_k(1) = drawpoint(ax(2),'Deletable',false,'Position',[1 1],...
        'DrawingArea',[1, 1, ny-1, nx-1],'Visible','off');
    roi_k(2) = drawrectangle(ax(2),'Deletable',false,'Position',[1, 1, round(nx/5), round(nx/5)],...
        'DrawingArea',[1, 1, ny-1, nx-1],'Visible','off');
    roi_k(3) = drawrectangle(ax(2),'Deletable',false,'Position',[1, 1, ny-1, nx-1],...
        'DrawingArea',[1, 1, ny-1, nx-1],'Visible','on','InteractionsAllowed','none',...
        'FaceAlpha',0);


    addlistener( roi_k(1),'MovingROI',@(src,evnt) roi_k_1_moved( roi_k,im4D,im, ax) );
    addlistener( roi_k(2),'MovingROI',@(src,evnt) roi_k_2_moved( roi_k,im4D,im, ax) );
    addlistener( roi_k(3),'MovingROI',@(src,evnt) roi_k_3_moved( roi_k,im4D,im, ax) );
    selector_k.Callback = @(src,evt) select_roi_k(src, roi_k, im4D, im, ax);
%     roi_ht = drawrectangle( ax(3), "Position", [cmin_r, 0, cmax_r-cmin_r, max(ht(1).Values)],...
%         "Deletable", false, "InteractionsAllowed", "all");

    sl_r(1) = uicontrol(f,'style','slider',...
        'Units','points','position',[10, 50, 10, 400],...
        'min', cmin_r, 'max', cmax_r,'Value', min( im_init_r(:)) );
    sl_r(2) = uicontrol(f,'style','slider',...
        'Units','points','position',[30, 50, 10, 400],...
        'min', cmin_r, 'max', cmax_r,'Value', max( im_init_r(:)) );
    sl_k(1) = uicontrol(f,'style','slider',...
        'Units','points','position',[915, 50,10, 400],...
        'min', cmin_k, 'max', cmax_k,'Value', min( im_init_k(:)) );
    sl_k(2) = uicontrol(f,'style','slider',...
        'Units','points','position',[935, 50,10, 400],...
        'min', cmin_k, 'max', cmax_k,'Value', max( im_init_k(:)) );
%     
%     %cboxLog = uicontrol('style','checkbox','position',[],'String','Log data', 'Callback', @(hObject,eventdata) );
% 
%     % Listen to slider values and change B & C
    addlistener(sl_r, 'Value', 'PostSet',@(hObject,eventdata) set_contrast(ax(1),sl_r, cr_r));
    addlistener(sl_k, 'Value', 'PostSet',@(hObject,eventdata) set_contrast(ax(2),sl_k, cr_k));
end

function set_contrast( ax, sl, cr )
    cmin = sl(1).Value;
    cmax = sl(2).Value;

    if cmin > cmax
        cmin = cmax-eps;
        sl(1).Value = cmin;
    end

    ax.CLim = [cmin, cmax];
    cr(1).XData = [cmin, cmin];
    cr(2).XData = [cmax, cmax];
end

function select_roi_r( selector_r, roi_r, im4D, im, ax )
    for i = 1:3
        roi_r(i).Visible = 0;
    end
    roi_r(selector_r.Value).Visible = 1;

    if roi_r(1).Visible
        roi_r_1_moved( roi_r, im4D, im, ax );
    elseif roi_r(2).Visible
        roi_r_2_moved( roi_r, im4D, im, ax );
    elseif roi_r(3).Visible
        roi_r_3_moved( roi_r, im4D, im, ax );
    end
end

function select_roi_k( selector_k, roi_k, im4D, im, ax )
    for i = 1:3
        roi_k(i).Visible = 0;
    end
    roi_k(selector_k.Value).Visible = 1;

    if roi_k(1).Visible
        roi_k_1_moved( roi_k, im4D, im, ax );
    elseif roi_k(2).Visible
        roi_k_2_moved( roi_k, im4D, im, ax );
    elseif roi_k(3).Visible
        roi_k_3_moved( roi_k, im4D, im, ax);
    end
end

function roi_r_1_moved( roi_r, im4D, im, ax )
    %xy = round(eventData.CurrentPosition);
    xy = round( roi_r(1).Position);
    x = xy(1); y = xy(2);
    imData = squeeze(im4D(:,:,y,x));
    
    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(2).CData = imData;
    im(4).XData = edges(1:end-1);
    im(4).YData = histcounts( imData, edges );
    ax(4).XLim = [cmin cmax];
end
function roi_r_2_moved( roi_r, im4D, im, ax )
    xywh = round(roi_r(2).Position);
    x = xywh(1); y = xywh(2); w = xywh(3); h = xywh(4);
    imData = squeeze( mean(im4D(:,:,y:(y+h),x:(x+w)),[3 4]) );

    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(2).CData = imData;
    im(4).XData = edges(1:end-1);
    im(4).YData = histcounts( imData, edges );
    ax(4).XLim = [cmin cmax];
end
function roi_r_3_moved( roi_r, im4D, im, ax )
    imData = squeeze( mean(im4D,[3 4]) );

    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(2).CData = imData;
    im(4).XData = edges(1:end-1);
    im(4).YData = histcounts( imData, edges );
    ax(4).XLim = [cmin cmax];
end

function roi_k_1_moved( roi_k, im4D, im,ax )
    xy = round( roi_k(1).Position);
    x = xy(1); y = xy(2);
    imData = squeeze(im4D(y,x,:,:));

    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(1).CData = imData;
    im(3).XData = edges(1:end-1);
    im(3).YData = histcounts( imData, edges );
    ax(3).XLim = [cmin cmax];
end
function roi_k_2_moved( roi_k, im4D, im,ax )
    xywh = round(roi_k(2).Position);
    x = xywh(1); y = xywh(2); w = xywh(3); h = xywh(4);
    imData = squeeze( mean(im4D(y:(y+h),x:(x+w),:,:),[1 2]) );

    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(1).CData = imData;
    im(3).XData = edges(1:end-1);
    im(3).YData = histcounts( imData, edges );
    ax(3).XLim = [cmin cmax];
end
function roi_k_3_moved( roi_k, im4D, im, ax)
    imData = squeeze( mean(im4D,[1 2]) );

    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(1).CData = imData;
    im(3).XData = edges(1:end-1);
    im(3).YData = histcounts( imData, edges );
    ax(3).XLim = [cmin cmax];
end
    