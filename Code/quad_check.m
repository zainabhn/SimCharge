function [rx1, rx2, ry1, ry2] = quad_check(point, mid, max)
    if point(1)<=mid && point(2)<=mid, 
        quad = 1;
        rx1 = 0; rx2 = mid; ry1 = 0; ry2 = mid;
  
    elseif point(1)<=mid && point(2)>mid, 
        quad = 4; 
        rx1 = 0; rx2 = mid; ry1 = mid; ry2 = max;
        
    elseif point(1)>mid && point(2)<=mid, 
        quad = 2; 
        rx1 = mid; rx2 = max; ry1 = 0; ry2 = mid;
       
    else 
        quad = 3;
        rx1 = mid; rx2 = max; ry1 = mid; ry2 = max;
        
    end
end



                
