function units_data = units_data_creator();
%Creates the varios fields used as part of units_data, preallocates them. Also holds their explanation.

float_fields = {'unit_num';'place_num';'type_num';'leds';'aud_onset';'vis_onset';'soa';'trial_length_ms';...
    'init_resp_slope';'error';'uni_aud_place';'uni_vis_place';'contrast_index';'msi';...
    'max_uni';'max_uni_type';'max_uni_place';'msi_sig_pertrial';'msi_sig_calc';'integ'};

cell_fields = {'unit';'stim';'cat_num';'rearing';'peaks_all_val_loc';'troughs_all_val_loc';'outlier_limit';'sig_peaks'};
total_process_count = 1865;
for float_f_count = 1:numel(float_fields)
    units_data.(float_fields{float_f_count})(1,1:total_process_count) = single(NaN);
end
for cell_f_count = 1:numel(cell_fields)
    units_data.(cell_fields{cell_f_count}) = cell(1,total_process_count);
end

%{
    'unit_num' = numerical designation of the neuron in the data set.
    'place_num' = numerical designation of the unique location of the case in the data set.
    'unit' = string designation of the unit contains date_block_sortcode of the unit. Handy as figure name for individual uunits.
    'stim' = string designation of the stimulus used in the case, type_intensity_#LEDs_SOA.
    'cat_num' = String designation of cat used . Present in the Excel sheet.
    'rearing' = String designation of rearing conditions- Dark, Normal, Noise. Present in the Excel sheet.
    'type_num' = numerical designation of stimulus type. 0 = aud, 1 = vis, 10 = aud-vis.
    'leds' = numerical designation of LEDs. 1 = 1 static LED, 3 = 3 Static
            LEDs, 13 = Apparent motion of LEDs from 1to 3 i.e. Left to Right, 31 =
            Right to LEft.
    'aud_onset' = Time of aud stim onset.
    'vis_onset' = Time of vis stim onset.
    'soa' = A-V soa.
    'trial_length_ms' = time duration of each trial.
    'intensity' = Numerical designation for intesnity of vis stim.  1,2,3 = Low,med,high.
    'num_trial' = number of trials in the case. usually 25 or 30.
    'raster' = binary matrix indicating spike positions across time (columns) and trials (rows). Normalized by subtraction.
    'spike_density' = SDF of the raster.
    'qsum' = Cumulative sum of raster.
    'response_onset' = Time at which neuron responds to stim.
    'response_off' = Time at which neuron stops responding to stim.
    'per_trial_impulse_count' 
    'mean_trial_impulse_count'
    'init_resp_slope' = Slope of the initial response.
    'error' =  for debugging, indicated a 1 when something went wrong in processing
    'peaks_all_val_loc' = Value & Location (time) of peaks of SDF across entire trial.
    'troughs_all_val_loc'  = Value & Location (time) of troughs of SDF across entire trial.
    'peaks_response_val_loc'  = Value & Location (time) of peaks of SDF during response window.
    'troughs_response_val_loc'  = Value & Location (time) of trouhgs of SDF during response window.
    'outlier_limit' = 3x std deviation of response magnitude
    'sig_peaks' = peaks considered significantly different from each other in response window.
    'uni_aud_place' = Unique location of corresponding aud stim for AV stims.
    'uni_vis_place' = Unique location of corresponding vis stim for AV stims.
    'contrast_index'
    'msi'
    'max_uni' =  mean impulse count of the larger unisensory repsonse.
    'max_uni_type' = it's type.
    'max_uni_place' = it's unique location.
    'msi_sig_pertrial' =  whether the MSI is significant or not based on ttest2, for each trial.
    'msi_sig_calc' =  whether the MSI is significant or not based on ttest2, overall.
    'integ' = type of integration. +1 = enhancement, -1 = depression, 0 = neither.
%}