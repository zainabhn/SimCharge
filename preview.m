function preview(sz1, sz2, numMPs, f_handle)

MP_loc = place_MPs(sz1, numMPs);

% DISPLAYING MPs
for i=1:size(MP_loc,1)
  rectangle(f_handle, 'Position', [MP_loc(i, :)-1 2 2], 'Curvature', [0 0], 'FaceColor', 'w', 'EdgeColor','k', 'FaceColor',[0 .5 .5], 'LineStyle', ':', 'LineWidth', 1.5); %hold on
end

xlim(f_handle, [0 sz1]); ylim(f_handle, [0 sz2]);  %axis square
