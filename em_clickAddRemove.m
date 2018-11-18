function [x_new, y_new] = em_clickAddRemove(x_old, y_old, im, bool_conjugate)
    % Enables mouse input to add or remove coordinates on a image
    % x_old, y_old   initial x,y point set
    % im             image to click on
    % bool_conjugate add conjugate pair (useful for reciprocal space)
    
    % September 11, 2018 by Suk Hyun Sung @Hovden lab
    % sukhsung@umich.edu
    
    if nargin == 3
        bool_conjugate = false;
    end
    
    lft = 1;
    figure
    imagesc(im) 
    axis equal off
    colormap(parula(65536))
    title('Left Click to Add, Right Click to Remove, Hit Return to end' ) 
    hold on
    scatter(x_old,y_old,5,'ro')
    
    x_new = x_old;
    y_new = y_old;
    while lft ~=2
        [xm, ym, lft] = ginput(1);
        
        xm_conj = size(im,2)-xm+1;
        ym_conj = size(im,2)-ym+1;
    

        if lft == 3
            dist = sqrt( (x_new-xm).^2 + (y_new-ym).^2 );
            ind_rmv = find( dist == min(dist) );

            if bool_conjugate
                dist = sqrt( (x_new-xm_conj).^2 + (y_new-ym_conj).^2 );
                ind_rmv = [ind_rmv, find( dist == min(dist) )];
            end

            x_new(ind_rmv) = [];
            y_new(ind_rmv) = [];

        elseif lft == 1
            x_new = [x_new, xm];
            y_new = [y_new, ym];
            if bool_conjugate
                x_new = [x_new, xm_conj];
                y_new = [y_new, ym_conj];
            end
        end
        cla
        imagesc(im) 
        axis equal off
        colormap(parula(65536))
        hold on
        scatter(x_new,y_new,5,'ro')
        
        
    end
    
end

