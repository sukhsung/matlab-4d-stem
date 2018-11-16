function g = gaus2d(param, indep)
    
    xx = indep(:,:,1);
    yy = indep(:,:,2);

    x0 = param(1);
    y0 = param(2);
    sx = param(3);
    sy = param(4);
    a0 = param(5);
    b0 = param(6);
    
    rr = ((xx-x0)/sx).^2 + ((yy-y0)/sy).^2;
    
    g = a0*exp(-rr/2) + b0;
end