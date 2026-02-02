function MP_loc = place_MPs(AoI_dim, num_MPs)
    MP_loc = zeros(num_MPs, 2);
    MP_separation = AoI_dim/sqrt(num_MPs); 
    k=1; 
    
    x_mov=MP_separation/2; %To place MPs at the center of each zone
    for i=1:sqrt(num_MPs),  
        y_mov=MP_separation/2;
        for j=1:sqrt(num_MPs),
            MP_loc(k,:)=[x_mov, y_mov];
            y_mov = y_mov + MP_separation;
            k=k+1;
        end
        x_mov = x_mov + MP_separation;
    end

end
