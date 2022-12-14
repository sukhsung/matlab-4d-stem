classdef datacube
    properties
        im4D
        nsx
        nsy
        nx
        ny
    end
    
    methods
        function obj = datacube( im4D )
            % Read 4D STEM data from EMPAD
            % Tested only for 128 x 128 x 128 x 128 data set
            % fname : Input file path
            % ns    : Number of scan points Assuming equal sampling along x & y
            % Oct. 27 2018 by Suk Hyun Sung @ hovden lab
            % sukhsung@umich.edu
            % Nov. 18 2018 refactored by Noah Schnitzer from empad.m
            input_size = size(im4D);
            obj.nx = input_size(2);
            obj.ny = input_size(1);
            obj.nsy = input_size(3);
            obj.nsx = input_size(4);
            obj.im4D = im4D;
        end
        
        function pacbed = getPacbed(obj)
           pacbed = squeeze(mean(mean(obj.im4D, 3),4)); 
        end
        function scan = getScan(obj)
            scan = squeeze(mean(mean(obj.im4D,1),2));
        end
        
        function singleDiff = getSingleDiff(obj,x,y)
            singleDiff  = squeeze(obj.im4D(:,:,y,x));
        end
        function singleIm = getSingleImage(obj,x,y)
            singleIm  = squeeze(obj.im4D(y,x,:,:));
        end
        
        function vis4D(obj)

            im_init_r = squeeze( mean( obj.im4D, [1, 2]) );
            im_init_k = squeeze( obj.im4D(:,:,1,1) );%mean( im4D, [1, 2]) );
            %[nx, ny, nsx, nsy] = size( obj.im4D );
        
            % Find default min, max
            cmin_r = min(im_init_r(:));
            cmax_r = max(im_init_r(:)); 
            cmin_k = min(im_init_k(:));
            cmax_k = max(im_init_k(:)); 
        
            cmin = min(obj.im4D(:));
            cmax = max(obj.im4D(:));
        
            nedge = 256;
            edges_r = linspace( cmin_r, cmax_r, nedge);
            edges_k = linspace( cmin_k, cmax_k, nedge);
            bins_r  = histcounts( im_init_r, edges_r );
            bins_k  = histcounts( im_init_k, edges_k );
        
        
        
            f = figure("Name", "4D Viewer by SSH", "Position", [100 100 950 620]);
            ax(1) = axes( f, "Units", "Points", "Position", [ 50 50 400 400], "XLimitMethod", "Tight");
            ax(2) = axes( f, "Units", "Points", "Position", [500 50 400 400], "XLimitMethod", "Tight");        
            ax(3) = axes( f, "Units", "Points", "Position", [ 50  500 400 100], "XLimitMethod", "Tight");
            ax(4) = axes( f, "Units", "Points", "Position", [ 500 500 400 100], "XLimitMethod", "Tight");
            hold( ax(3:4), 'on')
        
            im(1) = imagesc(ax(1), im_init_r);
            im(2) = imagesc(ax(2), im_init_k);
            im(3) = plot( ax(3), edges_r(1:(nedge-1)), bins_r);
            im(4) = plot( ax(4), edges_k(1:(nedge-1)), bins_k);

            ax(3).XLim = [ cmin_r, cmax_r ];
            ax(3).YLim = [ 0, max(bins_r) ];

            ax(4).XLim = [ cmin_k, cmax_k ];        
            ax(4).YLim = [ 0, max(bins_k) ];
        
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
                'DrawingArea',[1, 1, obj.nsy-1, obj.nsx-1],'Visible','on');
            roi_r(2) = drawrectangle(ax(1),'Deletable',false,'Position',[1, 1, round(obj.nsx/5), round(obj.nsx/5)],...
                'DrawingArea',[1, 1, obj.nsy-1, obj.nsx-1],'Visible','off');
            roi_r(3) = drawrectangle(ax(1),'Deletable',false,'Position',[1, 1, obj.nsy-1, obj.nsx-1],...
                'DrawingArea',[1, 1, obj.nsy-1, obj.nsx-1],'Visible','off','InteractionsAllowed','none',...
                'FaceAlpha',0);
        
            addlistener( roi_r(1),'MovingROI',@(src,evnt) roi_r_1_moved( roi_r,obj.im4D,im, ax) );
            addlistener( roi_r(2),'MovingROI',@(src,evnt) roi_r_2_moved( roi_r,obj.im4D,im, ax) );
            addlistener( roi_r(3),'MovingROI',@(src,evnt) roi_r_3_moved( roi_r,obj.im4D,im, ax) );
            selector_r.Callback = @(src,evt) select_roi_r(src, roi_r, obj.im4D, im);
        
            % K Space Selector
            selector_k = uicontrol(f, "Style", "popupmenu", ...
                "String", ["Point", "Rectangle", "Full"],...
                "Position",[500 0 100 40] );
            selector_k.Value = 3;
        
            % UI setup    
            roi_k(1) = drawpoint(ax(2),'Deletable',false,'Position',[1 1],...
                'DrawingArea',[1, 1, obj.ny-1, obj.nx-1],'Visible','off');
            roi_k(2) = drawrectangle(ax(2),'Deletable',false,'Position',[1, 1, round(obj.nx/5), round(obj.nx/5)],...
                'DrawingArea',[1, 1, obj.ny-1, obj.nx-1],'Visible','off');
            roi_k(3) = drawrectangle(ax(2),'Deletable',false,'Position',[1, 1, obj.ny-1, obj.nx-1],...
                'DrawingArea',[1, 1, obj.ny-1, obj.nx-1],'Visible','on','InteractionsAllowed','none',...
                'FaceAlpha',0);
        
        
            addlistener( roi_k(1),'MovingROI',@(src,evnt) roi_k_1_moved( roi_k,obj.im4D,im, ax) );
            addlistener( roi_k(2),'MovingROI',@(src,evnt) roi_k_2_moved( roi_k,obj.im4D,im, ax) );
            addlistener( roi_k(3),'MovingROI',@(src,evnt) roi_k_3_moved( roi_k,obj.im4D,im, ax) );
            selector_k.Callback = @(src,evt) select_roi_k(src, roi_k, obj.im4D, im, ax);
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
        end

        function obj = rebin4D( obj, varargin )
            % bin by binFactor along scan directions
            % binFactor must be a power of 2     
            % bin dimension along scan or detector
            binFactor = varargin{1};    
            if rem(log(binFactor)/log(2),1) ~= 0
                error( 'Bin Factor must be a power of 2' )
            end
            if nargin > 2
                binDim = varargin{2};
            else
                binDim = 'scan';
            end
            
            switch binDim
                case 'scan'
                    sxs = 1:binFactor:obj.nsx;
                    sys = 1:binFactor:obj.nsy;

                    obj.nsx = obj.nsx/binFactor;
                    obj.nsy = obj.nsy/binFactor;
                    im4D_rebin = zeros(obj.nx,obj.ny,obj.nsx,obj.nsy);
                    for sx = 1:length(sxs)
                        for sy = 1:length(sys)
                            im4D_rebin(:,:,sy,sx) = mean(mean(obj.im4D(:,:, sys(sy):sys(sy)+binFactor-1, sxs(sx):sxs(sx)+binFactor-1),4),3);
                        end
                    end
                    obj.im4D = im4D_rebin;
                case 'detector'
                    xs = 1:binFactor:obj.nx;
                    ys = 1:binFactor:obj.ny;

                    obj.nx = obj.nx/binFactor;
                    obj.ny = obj.ny/binFactor;
                    im4D_rebin = zeros(obj.nx,obj.ny,obj.nsx,obj.nsy);
                    for x = 1:length(xs)
                        for y = 1:length(ys)
                            im4D_rebin(y,x,:,:) = mean(mean(obj.im4D( ys(y):ys(y)+binFactor-1,xs(x):xs(x)+binFactor-1, :,:),2),1);
                        end
                    end
                    obj.im4D = im4D_rebin;
                otherwise
                    error('Wrong bin dimension argument')
            end
        end
        
        function obj = crop4D( obj, cropInd, cropDim )
            % bin by binFactor along scan directions
            % cropInd = [xmin xmax ymin ymax];
            
            xmin = cropInd(1);
            xmax = cropInd(2);
            ymin = cropInd(3);
            ymax = cropInd(4);
            
            switch cropDim
                case 'scan'
                    sxs = xmin:1:xmax;
                    sys = ymin:1:ymax;

                    obj.nsx = xmax-xmin+1;
                    obj.nsy = ymax-ymin+1;
                    
                    obj.im4D = obj.im4D(sys,sxs,:,:);
                    
                case 'detector'            
                    xs = xmin:1:xmax;
                    ys = ymin:1:ymax;
                    
                    obj.nx = xmax-xmin+1;
                    obj.ny = ymax-ymin+1;
                    
                    obj.im4D = obj.im4D(ys,xs,:,:);
                    
                otherwise
                    error('Wrong bin dimension argument')
            end
        end

        function mask = generateRadialMask( obj, x0, y0, ri, ro )
            [xx, yy, ~, ~] = ndgrid(1:obj.nx, 1:obj.ny,1:obj.nsx,1:obj.nsy);
            rr = (yy - y0).^2 + (xx - x0).^2;
            
            if ri == 0
                %BF
                mask = ( rr <= ro^2 );
            else
                %ADF
                mask = ( rr <= ro^2 & rr >= ri^2);
            end
        end
        
        function obj = applyDetector(obj, x0, y0, ri, ro)
            obj.im4D = obj.im4D.*obj.generateRadialMask(x0,y0,ri,ro);
        end
        
        function mask = generateRadialWedgeMask(obj, x0, y0, ri, ro, ti, to)
            [xx, yy, ~, ~] = ndgrid(1:obj.nx, 1:obj.ny,1:obj.nsx,1:obj.nsy);
            rr = (yy - y0).^2 + (xx - x0).^2;
            tt = atan2d(yy-y0,xx-x0);
            if ri == 0
                %BF
                mask = ( rr <= ro^2 );
            else
                %ADF
                mask = ( rr <= ro^2 & rr >= ri^2);
            end
            mask = mask .* (tt <= to & tt >= ti);
        end
        function obj = applyWedgeDetector(obj, x0, y0, ri, ro, ti, to)
            obj.im4D = obj.im4D.*obj.generateRadialWedgeMask(x0,y0,ri,ro,ti,to);
        end
        % defines a mask which selects a hexagonal lattice of points with
        % given origin (x0, y0), parameter a, rotation angle theta, size n
        function [mask,pos] = generateHexagonalLatticeMask(obj,x0,y0,a,theta,n)
            %[xx, yy, ~, ~] = ndgrid(1:obj.nx, 1:obj.ny,1:obj.nsx,1:obj.nsy);
            imsz = size(obj.im4D);
            phi = -30*pi/180;
            theta = theta*pi/180;
            a1 = [cos(phi+theta) -sin(phi+theta); sin(phi+theta) cos(phi+theta)]*[1;0];
            a2 = [cos(theta) -sin(theta); sin(theta) cos(theta)]*[0;1];
            grid = linspace(-n,n,2*n+1);
            [h, k] = meshgrid(grid,grid);
            h = h(:);
            k = k(:);
            pos_x = a1*h';
            pos_y = a2*k';
            pos = pos_x+pos_y;
            pos = pos*a;
            pos(1,:) = pos(1,:)+x0;
            pos(2,:) = pos(2,:)+y0;
            pos = round(pos);
            
            pos(:,pos(1,:) <= 0) = [];
            pos(:,pos(2,:) <= 0) = [];
            pos(:,pos(1,:) > imsz(1)) = [];
            pos(:,pos(2,:) > imsz(2)) = [];
            
            mask = zeros(size(obj.im4D));
            %mask(pos(1,:),pos(2,:),:,:) = 1;
            for it = 1:size(pos,2)
               mask(pos(1,it),pos(2,it),:,:) = 1; 
            end
            %figure; scatter(pos(1,:),pos(2,:))
            %axis equal;
            
           
        end
        
        function obj = removeOutlier(obj, sgMul)
            % remove outlier within detector
            % outlier outside sg value are thresholded
            for sy = 1:obj.nsx
                for sx = 1:obj.nsx
                    curIm = obj.im4D(:,:,sy,sx);
                    av = mean(curIm(:));
                    st = std(curIm(:));
                    lb = av - sgMul*st;
                    ub = av + sgMul*st;
                    curIm( curIm < lb ) = lb;
                    curIm( curIm > ub ) = ub;
                    
                    obj.im4D(:,:,sy,sx) = curIm;
                end
            end
        end
        
        function obj = translateDetector(obj,dx,dy)
            
            im4D_K = fft2(obj.im4D);

            kx1 = mod( 1/2 + (0:(obj.nx-1))/obj.nx , 1 ) - 1/2;
            ky1 = mod( 1/2 + (0:(obj.ny-1))/obj.ny , 1 ) - 1/2;

            [KX,KY] = meshgrid(kx1,ky1);

            pha = exp( -2i*pi*(KX*dx + KY*dy) );

            for sy = 1:obj.nsy
                for sx = 1:obj.nsx
                    im4D_K(:,:,sy,sx) = im4D_K(:,:,sy,sx) .* pha;
                end
            end

            obj.im4D = abs(ifft2(im4D_K));
        end
        
        
    end
end