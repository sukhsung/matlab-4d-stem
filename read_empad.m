% By SSH adapted by NS 2018-11-18
% takes in file name, scan dimension
% returns empad_data, 4D matrix with dimensions: 
%   [detectorx, detectory,scanx, scany]
function [empad_data] = read_empad(fname, ns, empad_old)
    fid = fopen( fname );

    nsx = ns;
    nsy = ns;
    nx = 128;
    ny = 128;


    if nargin == 2 || empad_old == false
        A = fread(fid, nx*(ny+2)*nsx*nsy,'long',0,'l');
        A = reshape(A,[ny, nx+2,nsx,nsy]);
    
        empad_data = A(:,1:end-2,:,:);
    else
        A = fread(fid, nx*(ny)*nsx*nsy,'long',0,'l');
        A = reshape(A,[ny, nx,nsx,nsy]);
    
        empad_data = A(:,1:end,:,:);
    end
end