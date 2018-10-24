function fit = fitDisk(im,x0,y0,r0)
    [ny, nx] = size(im);
    [xx, yy] = meshgrid(1:nx, 1:ny);
    
    indep(:,:,1) = xx;
    indep(:,:,2) = yy;
    
    
    lb = [1,1,1,0,0];
    ub = [nx,ny,nx,inf,inf];
    
    guess = [x0, y0, r0, max(im(:)), min(im(:))];
    
    tol = 1e-7;
    maxFunEvals = 1e6;
    maxIter = 1e3;
    opt = optimset('Display','Iter','TolFun',tol,'TolX',tol,'MaxFunEvals',maxFunEvals,'MaxIter',maxIter);
  
    fitted = lsqcurvefit(@drawDisk, guess, indep, im, lb, ub, opt);
    
    
    fit.x0 = fitted(1);
    fit.y0 = fitted(2);
    fit.r0 = fitted(3);
    fit.a0 = fitted(4);
    fit.b0 = fitted(5);
end
