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
        
        function vis4D(varargin)
            thisObj = varargin{1};
            
            if nargin > 1
                searchDim = varargin{2};
            else
                searchDim = 'scan';
            end

            switch searchDim
                case 'scan'
                    im_ave = squeeze( mean( mean( thisObj.im4D, 1), 2) );
                    im_init = squeeze(thisObj.im4D(:,:,1,1));
                case 'detector'
                    im_ave = squeeze( mean( mean( thisObj.im4D, 3), 4) );            
                    im_init = squeeze(thisObj.im4D(1,1,:,:));
                otherwise
                    error('Wrong Input')
            end


            f = figure;
            ax1 = subplot(1,2,1);
            ax2 = subplot(1,2,2);

            im1 = imagesc(ax1,im_ave);           
            im2 = imagesc(ax2,im_init);   
            colormap(f,gray(65536))
            axis(ax1,'equal','off') 
            axis(ax2,'equal','tight','off')
            colorbar(ax2)

            % Find default min, max
            cmin1 = min(thisObj.im4D(:));
            cmax1 = max(thisObj.im4D(:)); 

            % UI setup
            
            h1 = drawpoint(ax1,'Deletable',false,'Position',[1 1],...
                'DrawingArea',[1,1,size(im_ave,2)-1,size(im_ave,1)-1]);
            
            p1 = uipanel(f,'Position',[0,0,0.1,1]);
            p2 = uipanel(f,'Position',[0.9,0,0.1,1]);
            p3 = uipanel(f,'Position',[0.1,0,0.8,0.05]);
    
            sl1_min = uicontrol(p1,'style','slider',...
                'Units','normalized','position',[0,0,0.5,1],...
                'min', cmin1, 'max', cmax1,'Value', min(im_ave(:)));
            sl1_max = uicontrol(p1,'style','slider',...
                'Units','normalized','position',[0.5,0,0.5,1],...
                'min', cmin1, 'max', cmax1,'Value', max(im_ave(:)));
            sl2_min = uicontrol(p2,'style','slider',...
                'Units','normalized','position',[0,0,0.5,1],...
                'min', cmin1, 'max', cmax1,'Value', min(im_init(:)));
            sl2_max = uicontrol(p2,'style','slider',...
                'Units','normalized','position',[0.5,0,0.5,1],...
                'min', cmin1, 'max', cmax1,'Value', max(im_init(:)));
            
             % filename box
            txtbox1 = uicontrol(p3,'style','edit',...
                'Units','Normalized','position',[0 0 0.2 1],...
                'String','File Name');
            txtbox2 = uicontrol(p3,'style','edit',...
                'Units','Normalized','position',[0.7 0 0.2 1],...
                'String','File Name');
            bt1 =    uicontrol(p3,'style','pushbutton',...
                'Units','Normalized','position',[0.2 0 0.1 1],...
                'String','Save',...
                'CallBack', @(src,evnt) saveIm(im1,sl1_min,sl1_max,txtbox1));
            bt2 =    uicontrol(p3,'style','pushbutton',...
                'Units','Normalized','position',[0.9 0 0.1 1],...
                'String','Save',...
                'CallBack', @(src,evnt) saveIm(im2,sl2_min,sl2_max,txtbox2));
            %cboxLog = uicontrol('style','checkbox','position',[],'String','Log data', 'Callback', @(hObject,eventdata) );
    
            addlistener(h1,'MovingROI',@(src,evnt) draw4D(evnt,thisObj.im4D,im2,ax2,searchDim));
            % Listen to slider values and change B & C
            addlistener([sl1_min,sl1_max], 'Value', 'PostSet',@(hObject,eventdata) setContrast(ax1,sl1_min,sl1_max));
            addlistener([sl2_min,sl2_max], 'Value', 'PostSet',@(hObject,eventdata) setContrast(ax2,sl2_min,sl2_max));

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
            
            function saveIm(im,sl_min,sl_max,txtbox)
                cmin = sl_min.Value;
                cmax = sl_max.Value;
                
                im2Save = im.CData;
                im2Save( im2Save<cmin ) = cmin;
                im2Save( im2Save>cmax ) = cmax;

                im2Save = im2Save - cmin;
                im2Save = uint16(65535 * im2Save / max(im2Save(:)));

                imwrite(im2Save, [txtbox.String,'.tif'])
            end
            
            function setContrast(ax,sl_min,sl_max)
                caxis(ax,[sl_min.Value, sl_max.Value])
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