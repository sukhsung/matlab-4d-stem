function [xc, yc] = centerOfMass(im)
    M = sum(im(:));
    [xx,yy] = meshgrid(1:size(im,1), 1:size(im,2));
    
    xc = sum(xx(:).*im(:))/M;
    yc = sum(yy(:).*im(:))/M;

end