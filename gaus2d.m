function g = gaus2d(param, indep)
    
    xx = indep(:,:,1);
    yy = indep(:,:,2);

    x0 = param(1);
    y0 = param(2);
    sg = param(3);
    a0 = param(4);
    b0 = param(5);
    
    rr = (xx-x0).^2 + (yy-y0).^2;
    
    g = a0*exp(-rr/(2*sg^2)) + b0;
end