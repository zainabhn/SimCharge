function [MCS_loc2, xvals, yvals, xvals2, yvals2] = DisplayFrame(MP_loc, MCS_zone, MCS_locs, MCS_Avail, MCS_Alloc, EV_locs, EV_zone, init_disp, round, fig_handle, col_list, move_history)
    size(MCS_locs)
    MCS_loc = MCS_locs(:, 1:2);
    MCS_loc2 = MCS_locs(:, 3:4);

    EV_loc = EV_locs(:, 1:2);
    EV_loc2 = EV_locs(:, 3:4);
    num_steps = 300;    

    xvals2 = zeros(size(EV_loc, 1), num_steps+2);
    yvals2 = zeros(size(EV_loc, 1), num_steps+2);

    % DISPLAYING MCS
    pos_adjustment = 0.5*[-1, 1;   1, 1;    -1, -1;     1, -1];
    MP_position_num = zeros(size(MP_loc,1), 1);   

    col=zeros(size(MCS_loc, 1), 3);
    %MCS_loc2 = zeros(size(MCS_loc));
    for i=1:size(MCS_loc,1),
        % Determining final location
        if MP_position_num(MCS_zone(i))<4, %MCS_Avail(i)==1 || MCS_Alloc(i)==1,
            MP_position_num(MCS_zone(i)) = MP_position_num(MCS_zone(i)) +1;
            MCS_loc2(i, :) = MCS_loc2(i,:) + pos_adjustment(MP_position_num(MCS_zone(i)),:);   
        else, MCS_loc2(i, :) = MCS_loc2(i,:) + pos_adjustment(1,:);  
        end

        % Determining color

        if MCS_Alloc(i)==1,
            col(i, :) = 	[1 0 0]; %col_list(1);
        elseif MCS_Avail(i)==1,
            col(i, :) = 	[0 1 0]; %col_list(2);
        elseif MCS_Avail(i)==0,
            col(i, :) = [0.6627    0.6627    0.6627]; %[169,169,169]./255;       
        end

        xvals(i, :) = linspace(MCS_loc(i, 1), MCS_loc2(i, 1), num_steps+2);
        yvals(i, :) = linspace(MCS_loc(i, 2), MCS_loc2(i, 2), num_steps+2);
    end
    for j=1:size(EV_loc, 1)
        xvals2(j, :) = linspace(EV_loc(j, 1), EV_loc2(j, 1), num_steps+2);
        yvals2(j, :) = linspace(EV_loc(j, 2), EV_loc2(j, 2), num_steps+2);
    end

    




            


