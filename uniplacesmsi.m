function [units_data] = uniplacesmsi2(units_data,unit_count)
%Calculates the MSI values, and assigns each multimodal stimulus condition 
% its corresponding unimodal stimulus condition's indices, stored in the 
% fields uni_vis_place, uni_aud_place, uni_max_place.

current_unit_place = find([units_data.unit_num] == unit_count); % finds the places associated with the current unit


%Generally, place indicates the actual aray index of something, while key 
% represents a logical array, or index within a subset. 
aud_loc_key = (units_data.type_num(current_unit_place) == 0);
vis_loc_key = (units_data.type_num(current_unit_place) == 1);
av_loc_key = (units_data.type_num(current_unit_place) == 10);

% Determines the index of the Aud only stim condition in the current unit.
aud_loc_place = units_data.place_num(current_unit_place(aud_loc_key));

%Determines number of vis only and av stims for the 'for' loop.
vis_stims = (units_data.place_num(current_unit_place(vis_loc_key)));
av_stims = (units_data.place_num(current_unit_place(av_loc_key)));

% Goes through each vis only condition and finds out the associated av
% condition indices.
for vis_stim_count = 1:size(vis_stims,2)
    vis_loc_place = vis_stims(vis_stim_count);
    
    units_data.uni_aud_place(vis_loc_place)  = aud_loc_place;
    
       % Current unit's av condition indices    
    current_vis_av_key = ~cellfun('isempty',strfind({units_data.stim{av_stims}}...
        ,units_data.stim{vis_loc_place}(1:end-3)));
    
    current_vis_av = av_stims(current_vis_av_key);
    
   
    
    for count = 1:size(current_vis_av,2)
        units_data.uni_vis_place(current_vis_av(count)) = vis_loc_place;
        units_data.uni_aud_place(current_vis_av(count)) = aud_loc_place;

  %%      
        %         contrast_index
		units_data.contrast_index(current_vis_av(count)) =...
			(units_data.mean_trial_impulse_count(vis_loc_place) - units_data.mean_trial_impulse_count(aud_loc_place))...
			/(units_data.mean_trial_impulse_count(vis_loc_place) + units_data.mean_trial_impulse_count(aud_loc_place));
		
		% Writes the greater impulse count between aud and vis unimodal
		% response/
        max_uni = max(units_data.mean_trial_impulse_count(vis_loc_place),units_data.mean_trial_impulse_count(aud_loc_place));
        msi = (units_data.mean_trial_impulse_count(current_vis_av(count)) -  max_uni)/max_uni .* 100;
        units_data.msi(current_vis_av(count)) = single(full(msi));
        units_data.max_uni(current_vis_av(count)) =  single(full(max_uni));
        
        % Figures out which unimodal response is greater
        idx_uni_choice = [1,0];
        place_uni_choice = [vis_loc_place,aud_loc_place];
        
        
        [~,idx_uni_q] = max([units_data.mean_trial_impulse_count(vis_loc_place),units_data.mean_trial_impulse_count(aud_loc_place)]);
        units_data.max_uni_type(current_vis_av(count)) = idx_uni_choice(idx_uni_q);
        
        % Absolute index/place of the max UNimodal response
        max_uni_place = place_uni_choice(idx_uni_q);
        units_data.max_uni_place(current_vis_av(count)) = max_uni_place;
        
        % Wheteher the MSI is significant or not, per trial and overall
        units_data.msi_sig_pertrial(current_vis_av(count)) = ttest2(full(units_data.per_trial_impulse_count{current_vis_av(count)}),full(units_data.per_trial_impulse_count{(max_uni_place)}));
        
        time_range_av_calc = units_data.response_onset(current_vis_av(count)):units_data.response_off(current_vis_av(count));
        time_range_uni_calc = units_data.response_onset(max_uni_place):units_data.response_off(max_uni_place);
       
        
        units_data.msi_sig_calc(current_vis_av(count)) = ttest2(units_data.qsum{(current_vis_av(count))}(time_range_av_calc),units_data.qsum{(max_uni_place)}(time_range_uni_calc));
        
        % Assigns the type of integration, enhancement or depression
        if units_data.msi(current_vis_av(count))   > 0        
            units_data.integ(current_vis_av(count)) = 1;
        else if units_data.msi(current_vis_av(count)) < 0
                units_data.integ(current_vis_av(count)) = -1;
            else
                units_data.integ(current_vis_av(count)) = 0;
            end
        end
    end
    
end

