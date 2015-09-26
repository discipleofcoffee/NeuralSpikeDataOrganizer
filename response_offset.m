function all_data = response_offset(all_data,process_count)
% Calculates the offset of neuron's response.
%{ 
To calculate the response off time point, the first max value of the raster 
cumsum was determined within 500(stim_onset)-1000(max_off)ms time window.
A line was fitted to the qsum form this time point until 1000ms. 
This fitted line was then extended backwards in time from max(qsum) time point to
stimonset (500ms).
The difference between this extended fitted line and the qsum values was
caluclated as fit_diff and then plotted.
A diverge line was then plotted on this fit_diff line from the start of the fit_diff line to 


%}
current_qsum = all_data.qsum{process_count};	

x_range = 500:1000;

% Finds the max qsum value between x_range (500-1000ms), and it's time point
max_qsum_val_place(1) = max(current_qsum(1,x_range),[],2); 
max_qsum_val_place(2) = find(max_qsum_val_place(1) == current_qsum(x_range),1,'first');
	
	% Fitting the line around qsum from max(qsum) till end of x_range.
	x_data = 499+max_qsum_val_place(2):x_range(end);
	y_data = current_qsum(499+max_qsum_val_place(2):x_data(end));
	fit1 = polyfit(x_data,y_data,1);

    % Extending the fitted line back in time until stimon at 500ms
	x_data_extended = [500:x_data(1) x_data(2:end)];
	y_plot_extended = polyval(fit1,x_data_extended);
	
	% Calculating the difference between the extended fitted line and qsum.
	fit_diff = y_plot_extended - current_qsum(x_data_extended);
	

    % determines the x,y values of start and end points of the diverge line
    % The _x_y in the variable name indicate the first index is for x coord
    % and second index for y coord of start or end.
    
    % response onset time as x coordinate of diverge line start and fit_diff value
	time_start = all_data.response_onset(process_count); 
	start_x_y = (time_start);
	if (start_x_y == 500) % since 500 will be subtracted from this value, 
		start_x_y = 501;     %if this value is 500, we'll get an index of zero , this code prevents that.
    end
        start_x_y(2) = fit_diff(start_x_y(1)-500); %value of start point y coord.
	
	end_x_y(1) = length(fit_diff) + 500;
	end_x_y(2) = fit_diff(end);
	
	
	% Diverge line plotted, it's slope calculated, and the slope of the
	% perpendicular plumb line calculated.
	diverge_line_points_x = start_x_y(1):end_x_y(1);
	diverge_line_points_y = linspace(start_x_y(2),end_x_y(2),length(diverge_line_points_x));
	diverge_line_coord_x_y = [transpose(diverge_line_points_x) transpose(diverge_line_points_y)];
	diverge_line_slope = (diverge_line_coord_x_y(end,2) - diverge_line_coord_x_y(1,2))/(diverge_line_coord_x_y(end,1) - diverge_line_coord_x_y(1,1));
	
	plumb_line_slope = -1/diverge_line_slope;
	%%


plumb_line_c = diverge_line_coord_x_y(:,2) - plumb_line_slope.*diverge_line_coord_x_y(:,1);
plumb_x_at_y_zero = -plumb_line_c/plumb_line_slope;

plumb_coord_start_x_y = [diverge_line_coord_x_y(:,1)  diverge_line_coord_x_y(:,2)];
plumb_coord_end_x_y = [plumb_x_at_y_zero  zeros(size( plumb_x_at_y_zero))];

plumb_qsum_diff_y= transpose(fit_diff(round(plumb_coord_end_x_y(:,1)) - 500));
plumb_qsum_diff_length = plumb_coord_start_x_y(:,2) - plumb_qsum_diff_y;

	%%
	[~,max_plumb_idx] = max(plumb_qsum_diff_length);
	
	all_data.response_off(process_count) = round(plumb_coord_end_x_y(max_plumb_idx,1));