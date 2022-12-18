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
    crange_r = cmax_r - cmin_r;
    cmin_k = min(im_init_k(:));
    cmax_k = max(im_init_k(:)); 
    crange_k= cmax_k - cmin_k; 

    nedge = 256;
    edges_r = linspace( cmin_r, cmax_r, nedge);
    edges_k = linspace( cmin_k, cmax_k, nedge);
    bins_r  = histcounts( im_init_r, edges_r );
    bins_k  = histcounts( im_init_k, edges_k );


    f = figure("Name", "4D Viewer by SSH", "Position", [100 100 950 650]);

    % Image Axes
    ax(1) = axes( f, "Units", "normalized", "Position", [50/950  50/650 400/950 400/650], "XLimitMethod", "Tight");%, "XLim", [1,nkx], "YLim", [1,nky] );
    ax(2) = axes( f, "Units", "normalized", "Position", [500/950 50/650 400/950 400/650], "XLimitMethod", "Tight");%"XLim", [1,nx], "YLim", [1,ny] );
    
    im(1) = imagesc(ax(1), im_init_r);
    im(2) = imagesc(ax(2), im_init_k);
    axis( ax(1:2), 'equal','off')
    colormap( ax(1), gray(65535) )
    colormap( ax(2), gray(65535) )

    % B&C
    ax(3) = axes( f, "Units", "normalized", "Position", [ 50/950  500/650 400/950 100/650], "XLimitMethod", "Tight");
    ax(4) = axes( f, "Units", "normalized", "Position", [ 500/950 500/650 400/950 100/650], "XLimitMethod", "Tight");
    im(3) = area( ax(3), edges_r(1:(nedge-1)), bins_r, 'edgecolor','none');% histogram( ax(3), im_init_r(:) );
    im(4) = area( ax(4), edges_k(1:(nedge-1)), bins_k, 'edgecolor','none');% histogram( ax(3), im_init_r(:) );
    ax(3).XLim = [ cmin_r-crange_r/40, cmax_r+crange_r/40 ];
    ax(4).XLim = [ cmin_k-crange_k/40, cmax_k+crange_k/40 ];
    ax(3).YLim = [ 0, max(bins_r) ];
    ax(4).YLim = [ 0, max(bins_k) ];
    ax(3).Toolbar.Visible = 'off';
    ax(4).Toolbar.Visible = 'off';
    disableDefaultInteractivity(ax(3))
    disableDefaultInteractivity(ax(4))

    bt_r = uicontrol(f, "Style","togglebutton","String", "Auto B & C", "Units","Normalized","Position",[370/950 573/650 80/950 25/650]);
    bt_k = uicontrol(f, "Style","togglebutton","String", "Auto B & C", "Units","Normalized","Position",[820/950 573/650 80/950 25/650]);

    % Real Space Selector
    selector_r = uicontrol(f, "Style", "popupmenu", ...
        "String", ["Point", "Rectangle", "Full"],...
        "Units","normalized", "Position",[50/950 0 100/950 40/650] );

    % UI setup    
    roi_r(1) = drawpoint(ax(1),'Deletable',false,'Position',[1 1],...
        'DrawingArea',[1, 1, nsy-1, nsx-1],'Visible','on');
    roi_r(2) = drawrectangle(ax(1),'Deletable',false,'Position',[1, 1, round(nsx/5), round(nsx/5)],...
        'DrawingArea',[1, 1, nsy-1, nsx-1],'Visible','off');
    roi_r(3) = drawrectangle(ax(1),'Deletable',false,'Position',[1, 1, nsy-1, nsx-1],...
        'DrawingArea',[1, 1, nsy-1, nsx-1],'Visible','off','InteractionsAllowed','none',...
        'FaceAlpha',0);

    % K Space Selector
    selector_k = uicontrol(f, "Style", "popupmenu", ...
        "String", ["Point", "Rectangle", "Full"],...
        "Units","normalized", "Position",[500/950 0 100/950 40/650] );
    selector_k.Value = 3;

    % UI setup    
    roi_k(1) = drawpoint(ax(2),'Deletable',false,'Position',[1 1],...
        'DrawingArea',[1, 1, ny-1, nx-1],'Visible','off');
    roi_k(2) = drawrectangle(ax(2),'Deletable',false,'Position',[1, 1, round(nx/5), round(nx/5)],...
        'DrawingArea',[1, 1, ny-1, nx-1],'Visible','off');
    roi_k(3) = drawrectangle(ax(2),'Deletable',false,'Position',[1, 1, ny-1, nx-1],...
        'DrawingArea',[1, 1, ny-1, nx-1],'Visible','on','InteractionsAllowed','none',...
        'FaceAlpha',0);

    sl_r(1) = drawline( ax(3), 'Position', [cmin_r -1; cmin_r, nx*ny], ...
        'InteractionsAllowed','translate','color','r');
    sl_r(2) = drawline( ax(3), 'Position', [cmax_r -1; cmax_r, nx*ny], ...
        'InteractionsAllowed','translate','color','r');
    sl_k(1) = drawline( ax(4), 'Position', [cmin_k -1; cmin_k, nsx*nsy], ...
        'InteractionsAllowed','translate','color','r');
    sl_k(2) = drawline( ax(4), 'Position', [cmax_k -1; cmax_k, nsx*nsy], ...
        'InteractionsAllowed','translate','color','r');

    addlistener( roi_r(1),'MovingROI',@(src,evnt) roi_r_1_moved( roi_r,im4D,im, ax, sl_k, bt_k) );
    addlistener( roi_r(2),'MovingROI',@(src,evnt) roi_r_2_moved( roi_r,im4D,im, ax, sl_k, bt_k) );
    addlistener( roi_r(3),'MovingROI',@(src,evnt) roi_r_3_moved( roi_r,im4D,im, ax, sl_k, bt_k) );
    selector_r.Callback = @(src,evt) select_roi_r(src, roi_r, im4D, im, ax, sl_k, bt_k);

    addlistener( roi_k(1),'MovingROI',@(src,evnt) roi_k_1_moved( roi_k,im4D,im, ax, sl_r, bt_r) );
    addlistener( roi_k(2),'MovingROI',@(src,evnt) roi_k_2_moved( roi_k,im4D,im, ax, sl_r, bt_r) );
    addlistener( roi_k(3),'MovingROI',@(src,evnt) roi_k_3_moved( roi_k,im4D,im, ax, sl_r, bt_r) );
    selector_k.Callback = @(src,evt) select_roi_k(src, roi_k, im4D, im, ax, sl_r, bt_r);


    addlistener( bt_r, 'Value','PostSet', @(src, evt) bt_pressed( bt_r, im(1), sl_r, ax(1) ) );
    addlistener( bt_k, 'Value','PostSet', @(src, evt) bt_pressed( bt_k, im(2), sl_k, ax(2)) );

    addlistener( sl_r,'MovingROI',@(src,evnt) set_contrast( ax(1), sl_r ) );
    addlistener( sl_k,'MovingROI',@(src,evnt) set_contrast( ax(2), sl_k ) );

end

function bt_pressed( bt, im, sl, ax)

    if bt.Value

        cmin = min( im.CData(:));
        cmax = max( im.CData(:));
    
        sl(1).Position([1 2]) = cmin;
        sl(2).Position([1 2]) = cmax;
        set_contrast( ax, sl )
    end
end

function set_contrast( ax, sl )
    crange = [sl(1).Position(1); sl(2).Position(2)];

    if crange(1) > crange(2)
        crange = crange(2:-1:1);
    end

    ax.CLim = crange;
end

function select_roi_r( selector_r, roi_r, im4D, im, ax, sl_k, bt_k )
    for i = 1:3
        roi_r(i).Visible = 0;
    end
    roi_r(selector_r.Value).Visible = 1;

    if roi_r(1).Visible
        roi_r_1_moved( roi_r, im4D, im, ax, sl_k, bt_k );
    elseif roi_r(2).Visible
        roi_r_2_moved( roi_r, im4D, im, ax, sl_k, bt_k );
    elseif roi_r(3).Visible
        roi_r_3_moved( roi_r, im4D, im, ax, sl_k, bt_k );
    end
end

function select_roi_k( selector_k, roi_k, im4D, im, ax, sl_r, bt_r )
    for i = 1:3
        roi_k(i).Visible = 0;
    end
    roi_k(selector_k.Value).Visible = 1;

    if roi_k(1).Visible
        roi_k_1_moved( roi_k, im4D, im, ax, sl_r, bt_r );
    elseif roi_k(2).Visible
        roi_k_2_moved( roi_k, im4D, im, ax, sl_r, bt_r );
    elseif roi_k(3).Visible
        roi_k_3_moved( roi_k, im4D, im, ax, sl_r, bt_r);
    end
end

function roi_r_1_moved( roi_r, im4D, im, ax, sl_k, bt_k )
    %xy = round(eventData.CurrentPosition);
    xy = round( roi_r(1).Position);
    x = xy(1); y = xy(2);
    imData = squeeze(im4D(:,:,y,x));
    
    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(2).CData = imData;
    im(4).XData = edges(1:end-1);
    im(4).YData = histcounts( imData, edges );
    crange = cmax-cmin;
    ax(4).XLim = [cmin-crange/40 cmax+crange/40];

    if bt_k.Value
        sl_k(1).Position([1 2]) = cmin;
        sl_k(2).Position([1 2]) = cmax;
    end
end
function roi_r_2_moved( roi_r, im4D, im, ax, sl_k, bt_k )
    xywh = round(roi_r(2).Position);
    x = xywh(1); y = xywh(2); w = xywh(3); h = xywh(4);
    imData = squeeze( mean(im4D(:,:,y:(y+h),x:(x+w)),[3 4]) );

    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(2).CData = imData;
    im(4).XData = edges(1:end-1);
    im(4).YData = histcounts( imData, edges );
    crange = cmax-cmin;
    ax(4).XLim = [cmin-crange/40 cmax+crange/40];

    if bt_k.Value
        sl_k(1).Position([1 2]) = cmin;
        sl_k(2).Position([1 2]) = cmax;
    end
end
function roi_r_3_moved( roi_r, im4D, im, ax, sl_k, bt_k )
    imData = squeeze( mean(im4D,[3 4]) );

    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(2).CData = imData;
    im(4).XData = edges(1:end-1);
    im(4).YData = histcounts( imData, edges );
    crange = cmax-cmin;
    ax(4).XLim = [cmin-crange/40 cmax+crange/40];

    if bt_k.Value
        sl_k(1).Position([1 2]) = cmin;
        sl_k(2).Position([1 2]) = cmax;
    end
end

function roi_k_1_moved( roi_k, im4D, im, ax, sl_r, bt_r )
    xy = round( roi_k(1).Position);
    x = xy(1); y = xy(2);
    imData = squeeze(im4D(y,x,:,:));

    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(1).CData = imData;
    im(3).XData = edges(1:end-1);
    im(3).YData = histcounts( imData, edges );
    crange = cmax-cmin;
    ax(3).XLim = [cmin-crange/40 cmax+crange/40];

    if bt_r.Value
        sl_r(1).Position([1 2]) = cmin;
        sl_r(2).Position([1 2]) = cmax;
    end
end
function roi_k_2_moved( roi_k, im4D, im, ax, sl_r, bt_r )
    xywh = round(roi_k(2).Position);
    x = xywh(1); y = xywh(2); w = xywh(3); h = xywh(4);
    imData = squeeze( mean(im4D(y:(y+h),x:(x+w),:,:),[1 2]) );

    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(1).CData = imData;
    im(3).XData = edges(1:end-1);
    im(3).YData = histcounts( imData, edges );
    crange = cmax-cmin;
    ax(3).XLim = [cmin-crange/40 cmax+crange/40];

    if bt_r.Value
        sl_r(1).Position([1 2]) = cmin;
        sl_r(2).Position([1 2]) = cmax;
    end
end
function roi_k_3_moved( roi_k, im4D, im, ax, sl_r, bt_r)
    imData = squeeze( mean(im4D,[1 2]) );

    cmin = min( imData(:)); cmax = max( imData(:) );
    edges = linspace( cmin, cmax, 256);

    im(1).CData = imData;
    im(3).XData = edges(1:end-1);
    im(3).YData = histcounts( imData, edges );
    crange = cmax-cmin;
    ax(3).XLim = [cmin-crange/40 cmax+crange/40];

    if bt_r.Value
        sl_r(1).Position([1 2]) = cmin;
        sl_r(2).Position([1 2]) = cmax;
    end
end
    