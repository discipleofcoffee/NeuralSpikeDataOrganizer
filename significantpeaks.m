function all_data = significantpeaks(all_data,process_count)
% An ad-hoc, improvised attempt to find significant peaks in response
% window. Wouldn't use it for much if anything. Keeping around just in
% case. I hate regrets.

on = all_data.response_onset(process_count);                                               %Extracts the time of response onset
off = all_data.response_off(process_count);                                                %Extracts the time of response offset

spike_density = all_data.spike_density{process_count};                                     % Extracts the spike density data

spike_density_peak_pos_key = zeros(size(spike_density));                    % Preallocates memory space for a logical array indicating the locations of discovered peaks
response_mean = mean(spike_density(on:off));                                % Finds the mean activity of the unit during the response window.
spont_std = std(spike_density(1:on));                                       % Finds the standard deviation of the spontaneous activity of the unit.
spont_mean = mean(spike_density(1:on));                                     % Finds the mean spontaneous activity of the unit.


outlier_limit = spont_std * 3;                                              % Finds the minimum value to be an outlier, saves it.
all_data.outlier_limit{process_count} = outlier_limit;


suprathreshold_peaks_key = spike_density > outlier_limit;                   % Logical array storing position of all spike density values above the outlier limit.

if sum(suprathreshold_peaks_key) == 0                                       % If there are no spike density values above the outlier threshold the sum of its location array would be zero
    all_data.sig_peaks{process_count} = [NaN NaN];                                         % returns a NaN array, for concatenation and other compatibility issues, and exits the function, preventing further processing.
%     sig_peaks_exceptions = {all_data.unit all_data.stim exception_count}
    return
    
end
suprathreshold_peaks_pos = find(suprathreshold_peaks_key);                  % Finds the actual array subscript/location  of the spike density values.
suprathreshold_peaks_pos_adjacency = diff(suprathreshold_peaks_pos);        % Calculates the difference between one location and the next one for all locations except last. For the places where it's 1, indicates 2 spike density values adjacent to one another.

suprathreshold_peaks_pos_adjacency_key = suprathreshold_peaks_pos_adjacency == 1; % stores the logical position of the location of adjacent spike density values.
suprathreshold_peaks_pos_nonadjacency_key = suprathreshold_peaks_pos_adjacency ~= 1; % stores the logical position of the location of nonadjacent spike density values.


peaks_adjacent = suprathreshold_peaks_pos(suprathreshold_peaks_pos_adjacency_key); %actual subscript/locaton of adjacent spike density values
peaks_nonadjacent = suprathreshold_peaks_pos(suprathreshold_peaks_pos_nonadjacency_key); %actual subscript/locaton of nonadjacent spike density values

response_peaks_adj_pos = peaks_adjacent(peaks_adjacent >= on & peaks_adjacent <= off); % Finds location of adjacent spike density values within the response window.

if isempty(response_peaks_adj_pos) == 1                                     % Checks to see if there are any adjacent spike density values within the response window if there aren't the value is empty
    all_data.sig_peaks{process_count} = [NaN NaN];                                         % if its empty/there are no spike density values, returns NaN value and exits the function.
    return
end

if isempty(peaks_nonadjacent) == 1
    peaks_nonadjacent = response_peaks_adj_pos(end) + 1;                    % If there are no nonadjacent spike density values, sets the position of the nonadjacent spike density values to the one next to the location of the last adjacent spike density value.
end                                                                         % This is cuz empty non_adj aray leaves nothing to compare to and program gives an error.

response_peaks_nonadj_pos = peaks_nonadjacent(peaks_nonadjacent >= on & peaks_nonadjacent <= off); 

if isempty(response_peaks_nonadj_pos) == 1                                   % If there are no nonadjacent spike density values, sets the position of the nonadjacent spike density values to the one next to the location of the last adjacent spike density value.
    response_peaks_nonadj_pos = response_peaks_adj_pos(end) + 1;            % This is cuz empty non_adj aray leaves nothing to compare to and program gives an error.
end

peaks_pos_groups{1} = response_peaks_adj_pos(response_peaks_adj_pos < response_peaks_nonadj_pos(1)); % sorts & stores different clusters of adjacent spike density values.
for peak_pos_grp_count = 2:length(response_peaks_nonadj_pos)
    peaks_pos_groups{peak_pos_grp_count} = response_peaks_adj_pos(response_peaks_adj_pos > ...
        response_peaks_nonadj_pos(peak_pos_grp_count-1)& response_peaks_adj_pos < response_peaks_nonadj_pos(peak_pos_grp_count));
end

peaks_val = [];
peaks_val_pos = [];

for peaks_val_count = 1:length(response_peaks_nonadj_pos)
    
    max_peak = max(spike_density(peaks_pos_groups{peaks_val_count}));
    
    max_peak_pos = peaks_pos_groups{peaks_val_count}(find(spike_density(peaks_pos_groups{peaks_val_count}) == max_peak));
    
    size_multiple_pos =   size(max_peak_pos);
    max_peak = repmat(max_peak,size_multiple_pos);
    
    max_peak = max_peak';
    max_peak_pos = max_peak_pos';

    
        peaks_val = [peaks_val; max_peak];
    peaks_val_pos = [peaks_val_pos; max_peak_pos];
    
end
sig_peaks = [peaks_val peaks_val_pos];

if isempty(sig_peaks) == 1
    sig_peaks = [NaN NaN];
end

    all_data.sig_peaks{process_count} = sig_peaks;

    
    
end



