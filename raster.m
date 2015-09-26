function all_data = raster(~,stimOrder,spikeData_current_sort,stim_condition,~, all_data,~,process_count)
% Extracts and calculates the normalized raster,spike density function and qsum of the
% response.

trial_length_ms = stimOrder(2,1) - stimOrder(1,1);


current_stim_trials_condition_key = stimOrder(:,2) == stim_condition;
current_stim_trials_info = stimOrder(current_stim_trials_condition_key,1);
max_num_trials = length(current_stim_trials_info);
spikes_per_trial_cell = cell(max_num_trials,1);

all_data.num_trial(process_count) = max_num_trials;
stim_rel_spikes = [];
max_size_spike_array = 0;
current_stim_spikes = zeros(max_num_trials,trial_length_ms);
for current_stim_trials = 1:max_num_trials
    
    current_trial = stimOrder(current_stim_trials_condition_key);
    current_stim_trials_spikes_key = spikeData_current_sort(:,3) >= current_trial(current_stim_trials,1) & spikeData_current_sort(:,3) < current_trial(current_stim_trials,1) + trial_length_ms;
    rel_spike_time_in_trial = spikeData_current_sort(current_stim_trials_spikes_key,3) - current_trial(current_stim_trials,1);
    stim_rel_spikes  = [stim_rel_spikes;rel_spike_time_in_trial];
    
    
    
    spike_times = ceil(rel_spike_time_in_trial);
    spike_times(spike_times == 0) = 1;
    current_stim_spikes(current_stim_trials,spike_times) = 1;
    
    if max_size_spike_array < length(spike_times)
        max_size_spike_array = length(spike_times);
    end
    
    spikes_per_trial_cell{current_stim_trials} = spike_times;
    
    err = length(rel_spike_time_in_trial);
    if  err ~= 0
        error = 0;
    else
        error = 1;
    end
    
end
spikes_per_trial_array = NaN(max_num_trials,max_size_spike_array);


for count = 1:max_num_trials
 spikes_per_trial_array(count,1:length(spikes_per_trial_cell{count})) = spikes_per_trial_cell{count};
end

all_data.raster{process_count} = (current_stim_spikes) - mean(mean(current_stim_spikes(:,1:500)));
all_data.spike_density{process_count} = sdf((all_data.raster{process_count}));
all_data.qsum{process_count} = cumsum(mean((all_data.raster{process_count})));




