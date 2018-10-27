function im4D = empadRead(fname,ns)
    % Read 4D STEM data from EMPAD
    % Tested only for 128 x 128 x 128 x 128 data set
    % fname : Input file path
    % ns    : Number of scan points Assuming equal sampling along x & y
    % Oct. 27 2018 by Suk Hyun Sung @ hovden lab
    % sukhsung@umich.edu
    
    fid = fopen( [data_dir, fname] );
    nsx = ns;
    nsy = ns;
    nx = 128;
    ny = 128;


    A = fread(fid, nx*(ny+2)*nsx*nsy,'long',0,'l');
    A = reshape(A,[ny, nx+2,nsx,nsy]);

    im4D = A(:,3:nx,:,:);
end