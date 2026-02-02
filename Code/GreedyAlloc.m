function [RESULTS, MCS_Data, EV_Data, MCS_chgPt_occupied, MCS_chgPt_freeTime, chgPt_utilizationTime] = ...
    GreedyAlloc(MP_loc, MCS_Data, EV_Data, max_rounds, disp_flag_frames, disp_flag_results, EV_zone, time_slots, fig_num_rows)

% GreedyAlloc - greedy baseline: assign each candidate EV to nearest available MCS

num_MCS = size(MCS_Data, 1);
num_EVs  = size(EV_Data, 1);
num_MPs  = size(MP_loc, 1);
MP_dim1  = sqrt(num_MPs);

AoI_dim = 20;
z = AoI_dim / MP_dim1;
MCS_avg_spd = 50;    % km/h
col_list = ['r','g'];

% move_history expected by DisplayFrame
move_history = zeros(num_EVs, 1);

% Preallocate state matrices
MCS_chgPt_occupied    = zeros(num_MCS, 4);
MCS_chgPt_freeTime    = zeros(num_MCS, 4);
chgPt_utilizationTime = zeros(num_MCS, 4);
MCS_distTravelled = zeros(num_MCS, max_rounds);
MCS_SoC = zeros(num_MCS, max_rounds+1);
MCS_SoC(:,1) = MCS_Data(:,13);

EV_roundServed = zeros(num_EVs,1);
servedEVs = [];
num_satisfied_customers = zeros(max_rounds,1);

netDemand    = zeros(max_rounds,1);
netRevenue   = zeros(max_rounds,1);
roundRevenue = zeros(max_rounds,1);
netDist      = zeros(max_rounds,1);
batt_stat    = zeros(num_MCS, max_rounds);
chgPt_utilization = zeros(num_MCS, max_rounds);

total_init_demand = sum(EV_Data(:,9));

% Plotting setup
if disp_flag_frames
    frames = figure;
    xlim([0 AoI_dim]); ylim([0 AoI_dim]); axis square;
    frames.Position = [1310 20 600 600];
    for i=1:size(MP_loc,1)
        rectangle('Position',[MP_loc(i,:)-1 2 2], 'Curvature',[0 0], 'FaceColor',[0 .5 .5], 'EdgeColor','k', 'LineStyle', ':', 'LineWidth', 1.5); hold on;
    end
    e = plot(EV_Data(:,2), EV_Data(:,3), 'o', 'MarkerSize',5, 'MarkerFaceColor','b', 'MarkerEdgeColor','b'); hold on;
    h = plot(MCS_Data(:,2), MCS_Data(:,3), 'o', 'MarkerSize',13, 'MarkerFaceColor','k', 'MarkerEdgeColor','k');

    MCS_coord_change = zeros(num_MCS,4);
    EV_coord_change  = zeros(num_EVs,4);
    MCS_coord_change(:,1:2) = MCS_Data(:,2:3);
    EV_coord_change(:,1:2) = EV_Data(:,2:3);

    f2 = figure; f2.Position = [0 100 1045 600];
    subplot(3,2,1); title('Number of Requests in the AoI'); xlabel('Time (minutes)'); ylabel('Number of EV Requests'); xlim([0 time_slots(end)]);
    subplot(3,2,2); title('Demand in the AoI (kWh)'); xlabel('Time (minutes)'); ylabel('Demand (kWh)'); xlim([0 time_slots(end)]);
    subplot(3,2,3); title('Net Distance Travelled (km)'); xlabel('Time (minutes)'); ylabel('Distance (km)'); xlim([0 time_slots(end)]);
    subplot(3,2,4); title('Net Revenue (AED)'); xlabel('Time (minutes)'); ylabel('Revenue'); xlim([0 time_slots(end)]);
    subplot(3,2,5); heatmap(zeros(num_MCS,1)); title('MCS Battery Status'); xlabel('MCS ID'); ylabel('Battery (kWh)');
    subplot(3,2,6); heatmap(zeros(num_MCS,1)); title('MCS utilization'); xlabel('MCS ID'); ylabel('Number of chg pts occupied');
end

% Main loop
for round = 1:max_rounds
    fprintf('\nGreedyAlloc: Round %d\n', round);
    time_now = time_slots(round);

    % Update charge-point occupancies and availability
    for m = 1:num_MCS
        for c = 1:4
            if MCS_chgPt_freeTime(m,c) ~= 0 && MCS_chgPt_freeTime(m,c) <= time_now
                MCS_chgPt_occupied(m,c) = 0;
                MCS_chgPt_freeTime(m,c) = 0;
            end
        end
        if MCS_Data(m,5) ~= 0 && MCS_Data(m,5) <= time_now
            MCS_Data(m,end) = 1; MCS_Data(m,14) = 0;
        end
        if MCS_Data(m,13) < 10
            MCS_Data(m,end) = 0;
        end
    end

    % Candidate EVs
    candidate_mask = (EV_Data(:,13) <= time_now) & (EV_Data(:,4) ~= 0) & (EV_roundServed == 0) & (EV_Data(:,9) > 0);
    candidate_idx = find(candidate_mask);

    if isempty(candidate_idx)
        batt_stat(:,round) = MCS_Data(:,13);
        netDemand(round) = sum(EV_Data(EV_Data(:,4)~=0,9));
        netRevenue(round) = sum(MCS_Data(:,15));
        if round == 1
            roundRevenue(round) = netRevenue(round);
        else
            roundRevenue(round) = netRevenue(round) - netRevenue(round-1);
        end
        netDist(round) = sum(MCS_Data(:,11));
        for m=1:num_MCS, chgPt_utilization(m,round)=nnz(MCS_chgPt_occupied(m,:)); end

        if disp_flag_frames
            tvec = time_slots(1:round);
            figure(f2);
            subplot(3,2,1); bar(tvec, netDemand(1:round));
            subplot(3,2,2); bar(tvec, netRevenue(1:round));
            subplot(3,2,3); bar(tvec, roundRevenue(1:round));
            subplot(3,2,4); bar(tvec, netDist(1:round));
            subplot(3,2,5); heatmap(batt_stat(:,1:round));
            subplot(3,2,6); heatmap(chgPt_utilization(:,1:round));
            drawnow;
        end

        if numel(unique(servedEVs)) == num_EVs, break; end
        continue;
    end

    % Greedy: for each EV, try nearest MCS
    for ev = candidate_idx(:)'
        ev_xy = EV_Data(ev, 2:3);
        if isnan(ev_xy(1)) || isnan(ev_xy(2)), continue; end

        dists = sqrt(sum((MCS_Data(:,2:3) - ev_xy).^2, 2));
        [~, order] = sort(dists, 'ascend');

        for idx = order'
            if MCS_Data(idx, end) ~= 1, continue; end
            if all(MCS_chgPt_occupied(idx,:) ~= 0), continue; end
            req_kwh = EV_Data(ev,9);
            if MCS_Data(idx,13) < req_kwh, continue; end

            cp_idx = find(MCS_chgPt_occupied(idx,:) == 0, 1, 'first');
            if isempty(cp_idx), continue; end

            zone = EV_Data(ev,4);
            old_zone = MCS_Data(idx,4);
            if zone>0 && zone<=num_MPs && old_zone ~= zone
                dist = distanceTravelled(old_zone, zone, MP_dim1, z);
                MCS_Data(idx,11) = MCS_Data(idx,11) + dist;
                MCS_distTravelled(idx, round) = dist;
                MCS_Data(idx,12) = MCS_Data(idx,12) + 1;
            else
                dist = 0;
            end

            serviceTime = (60*dist / MCS_avg_spd) + EV_Data(ev, 11);

            % assign EV to cp
            MCS_chgPt_occupied(idx, cp_idx) = ev;
            MCS_chgPt_freeTime(idx, cp_idx) = time_now + serviceTime;
            chgPt_utilizationTime(idx, cp_idx) = chgPt_utilizationTime(idx, cp_idx) + EV_Data(ev, 11);

            % update MCS state
            MCS_Data(idx,13) = MCS_Data(idx,13) - req_kwh;
            if zone>0 && zone<=num_MPs
                MCS_Data(idx,2:3) = MP_loc(zone,:);
                MCS_Data(idx,4) = zone;
            end
            MCS_Data(idx,5) = time_now + serviceTime;
            MCS_Data(idx,14) = 1; % mark as serving (allocated flag)

            % update availability only when full or low SoC
            numOccupied = nnz(MCS_chgPt_occupied(idx,:));
            maxCP = MCS_Data(idx,7);
            if numOccupied >= maxCP || MCS_Data(idx,13) < 10
                MCS_Data(idx,end) = 0;
            else
                MCS_Data(idx,end) = 1;
            end

            % payments
            travel_rate = MCS_Data(idx,10);
            energy_rate = MCS_Data(idx,8);
            pay = (dist * travel_rate) + (req_kwh * energy_rate);
            MCS_Data(idx,15) = MCS_Data(idx,15) + pay;
            EV_Data(ev,12) = EV_Data(ev,12) - pay;

            % update EV
            EV_Data(ev,9) = 0;
            EV_Data(ev,10) = time_now;
            EV_roundServed(ev) = round;
            servedEVs = unique([servedEVs; ev]);

            break; % proceed to next EV
        end
    end

    % Per-round metrics
    still_there = find(EV_Data(:,4) ~= 0 & EV_Data(:,9) > 0);
    netDemand(round) = sum(EV_Data(still_there, 9));
    netRevenue(round) = sum(MCS_Data(:, 15));
    if round == 1
        roundRevenue(round) = netRevenue(round);
    else
        roundRevenue(round) = netRevenue(round) - netRevenue(round-1);
    end
    for m = 1:num_MCS, chgPt_utilization(m, round) = nnz(MCS_chgPt_occupied(m,:)); end
    netDist(round) = sum(MCS_Data(:,11));
    batt_stat(:, round) = MCS_Data(:,13);
    num_satisfied_customers(round) = numel(unique(servedEVs));

    % Plot / DisplayFrame
    if disp_flag_frames
        MCS_coord_change(:,3:4) = MCS_Data(:,2:3);
        EV_coord_change(:,3:4)  = EV_Data(:,2:3);
        EV_coord_change(find(EV_Data(:,4)==0), 1:4) = -1;
        figure(frames);
        title(sprintf('Time = %d', time_now), 'FontSize', 15);
        try
            [MCS_loc2, xvals, yvals, xvals2, yvals2] = DisplayFrame(MP_loc, MCS_Data(:,4), MCS_coord_change, MCS_Data(:,end), MCS_Data(:,14), EV_coord_change, EV_Data(:,4), 0, time_now+5, frames, col_list, move_history);
            if ~isempty(MCS_loc2), MCS_coord_change(:,1:2) = MCS_loc2; else MCS_coord_change(:,1:2) = MCS_Data(:,2:3); end
            EV_coord_change(:,1:2) = EV_Data(:,2:3);
            if exist('xvals','var') && ~isempty(xvals)
                for i=2:size(xvals,2)
                    set(h, 'XData', xvals(:,i), 'YData', yvals(:,i)); drawnow;
                end
            end
            if exist('xvals2','var') && ~isempty(xvals2)
                for j=1:size(xvals2,2)
                    set(e, 'XData', xvals2(:,j), 'YData', yvals2(:,j), 'MarkerFaceColor','b','MarkerEdgeColor','b'); drawnow;
                end
            end
        catch ME
            warning('DisplayFrame failed (%s). Falling back to scatter update.', ME.message);
            set(h, 'XData', MCS_Data(:,2), 'YData', MCS_Data(:,3));
            set(e, 'XData', EV_Data(:,2), 'YData', EV_Data(:,3));
            drawnow;
        end

        tvec = time_slots(1:round);
        figure(f2);
        subplot(3,2,1); bar(tvec, netDemand(1:round)); title('Demand in the AoI');
        subplot(3,2,2); bar(tvec, netRevenue(1:round)); title('Net Revenue Earned');
        subplot(3,2,3); bar(tvec, roundRevenue(1:round)); title('Revenue earned per round');
        subplot(3,2,4); bar(tvec, netDist(1:round)); title('MCS Distance travelled');
        subplot(3,2,5); heatmap(batt_stat(:,1:round)); title('MCS Battery Status');
        subplot(3,2,6); heatmap(chgPt_utilization(:,1:round)); title('MCS charge point utilization');
        subplot(3,2,1); title('Demand in the AoI');  xlabel('Time (minutes)'); ylabel('Demand (kWh)');
        subplot(3,2,2);title('Net Revenue Earned');  xlabel('Time (minutes)'); ylabel('Revenue');
        subplot(3,2,3); title('Revenue earned per round'); xlabel('Time (minutes)'); ylabel('Revenue');
        subplot(3,2,4); title('MCS Distance travelled'); xlabel('Time (minutes)'); ylabel('Distance (km)');
        subplot(3,2,5);  title('MCS Battery Status'); xlabel('MCS ID'); ylabel('Battery (kWh)');
        subplot(3,2,6);  title('MCS charge point utilization'); xlabel('MCS ID'); ylabel('Number of chg pts occupied');


        drawnow;
    end

    % Early stopping
    if num_satisfied_customers(round) == num_EVs
        fprintf('Stop reason: All EVs satisfied\n'); break;
    end
    if round > 2
        if num_satisfied_customers(round) == num_satisfied_customers(round-1) && num_satisfied_customers(round) == num_satisfied_customers(round-2)
            fprintf('Stop reason: No change in state\n'); break;
        end
    end
end

% Results vector (RSMB-compatible)
res_auctionRounds = min(round, max_rounds);
res_percentSatisfied = max(num_satisfied_customers) / num_EVs;
res_demandSatisfied = (num_MCS * MCS_Data(1,6) - sum(MCS_Data(:,13))) / total_init_demand;
res_total_MCS_Disp = sum(MCS_Data(:,11));
res_total_MCS_revenue = sum(MCS_Data(:,15));
res_EV_avg_waitingTime = mean(EV_Data(:,10), 'omitnan');
if total_init_demand > 0
    res_EV_avg_PayPerkWH = res_total_MCS_revenue / total_init_demand;
else
    res_EV_avg_PayPerkWH = 0;
end
res_MCS_avg_chgPtUtilizationTime = mean(mean(chgPt_utilizationTime));
starvedEvs = find(isnan(EV_Data(:,10)));
if isempty(starvedEvs)
    res_EV_avg_starvationTime = 0;
else
    starvation_times = EV_Data(starvedEvs,14) - EV_Data(starvedEvs,13);
    res_EV_avg_starvationTime = mean(starvation_times);
end

RESULTS = [res_auctionRounds, res_percentSatisfied, res_demandSatisfied, res_total_MCS_Disp, res_total_MCS_revenue, res_EV_avg_PayPerkWH, res_EV_avg_waitingTime, res_EV_avg_starvationTime, res_MCS_avg_chgPtUtilizationTime];

end
