function imDisk = drawDisk(param, indep)
    
    xx = indep(:,:,1);
    yy = indep(:,:,2);

    x0 = param(1);
    y0 = param(2);
    r0 = param(3);
    a0 = param(4);
    b0 = param(5);
    
    rr = (xx-x0).^2 + (yy-y0).^2;
    
    imDisk = a0*ones(size(xx)).* (rr< r0^2) + b0;
end