classdef empad
    properties
        im4D
        nsx
        nsy
        nx
        ny
        pacbed
    end
    
    methods
        function obj = empad( fname, ns )
            % Read 4D STEM data from EMPAD
            % Tested only for 128 x 128 x 128 x 128 data set
            % fname : Input file path
            % ns    : Number of scan points Assuming equal sampling along x & y
            % Oct. 27 2018 by Suk Hyun Sung @ hovden lab
            % sukhsung@umich.edu

            fid = fopen( fname );
            obj.nsx = ns;
            obj.nsy = ns;
            obj.nx = 128;
            obj.ny = 128;


            A = fread(fid, obj.nx*(obj.ny+2)*obj.nsx*obj.nsy,'long',0,'l');
            A = reshape(A,[obj.ny, obj.nx+2,obj.nsx,obj.nsy]);

            obj.im4D = A(:,1:end-2,:,:);
            obj.pacbed = squeeze( mean( mean( obj.im4D, 3), 4) );
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
                            im4D_rebin(:,:,sx,sy) = mean(mean(obj.im4D(:,:, sxs(sx):sxs(sx)+binFactor-1, sys(sy):sys(sy)+binFactor-1),4),3);
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
                            im4D_rebin(x,y,:,:) = mean(mean(obj.im4D( xs(x):xs(x)+binFactor-1, ys(y):ys(y)+binFactor-1,:,:),2),1);
                        end
                    end
                    obj.im4D = im4D_rebin;
                otherwise
                    error('Wrong bin dimension argument')
            end
            obj.pacbed = squeeze( mean( mean( obj.im4D, 3), 4) );
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
    end
end