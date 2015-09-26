function units_data = responsepeaks(units_data,process_count)
% Calculates the peaks and troughs in the SPike Density Function of the
% raster within the response window and throughout the response window.

if units_data.mean_trial_impulse_count(process_count) < 1
    %     disp('Insufficient spikes');
    no_spikes = units_data.unit(process_count);
    
    units_data.peaks_all_val_loc{process_count} = [NaN NaN];
    units_data.peaks_response_val_loc{process_count} = [NaN NaN];
    
    units_data.troughs_all_val_loc{process_count} = [NaN NaN];
    units_data.troughs_response_val_loc{process_count} = [NaN NaN];
    return
else
    [peaks_all_loc,peaks_all_val] = findpeaks(units_data.spike_density{process_count}); %findpeaks function for the actual finding.
    [troughs_all_loc,troughs_all_val] = findpeaks(units_data.spike_density{process_count},'v');
    
    %all, indicates during entire trial duration, response indicates during
    %response window. val indicates the SDF value on y-axis, loc indicates
    %location in time along x-axis, i.e. time of peak.
    %So peaks_all_val_loc{1} = 1st peak in entire trial duration, 1x2 matrix
    %containing the value and location(time of peak) resp.
    units_data.peaks_all_val_loc{process_count} = [peaks_all_val peaks_all_loc];
    units_data.troughs_all_val_loc{process_count} = [troughs_all_val,troughs_all_loc,];
    
    [peaks_response_loc,peaks_response_val] = findpeaks(units_data.spike_density{process_count}(units_data.response_onset(process_count):units_data.response_off(process_count)));
    [troughs_response_loc,troughs_response_val] = findpeaks(units_data.spike_density{process_count}(units_data.response_onset(process_count):units_data.response_off(process_count)),'v');
    
    units_data.peaks_response_val_loc{process_count} = [peaks_response_val units_data.response_onset(process_count)+peaks_response_loc-1];
    units_data.troughs_response_val_loc{process_count} = [troughs_response_val units_data.response_onset(process_count)+troughs_response_loc-1];
    peak_first_max =  max(peaks_response_val);
    exclude_peak_1 = find(peaks_response_val == peak_first_max);
end
% If no peaks or troughs are found then NaN is inserted, else we get
% errors.
if isempty(units_data.peaks_all_val_loc) == 1
    units_data.peaks_response_val_loc{process_count} = [NaN NaN];
end
if isempty(units_data.peaks_response_val_loc) == 1
    units_data.peaks_response_val_loc{process_count} = [NaN NaN];
end
if isempty(units_data.troughs_response_val_loc) == 1
    units_data.troughs_response_val_loc{process_count} = [NaN NaN];
end
if isempty(units_data.troughs_all_val_loc) == 1
    units_data.peaks_response_val_loc{process_count} = [NaN NaN];
end

end