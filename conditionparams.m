function [all_data,units_sort] = conditionparams(all_data,stimParams,stimOrder,~,stim_condition,figure_name,process_count,unit_count);
% Extracts various parameters of the stimulus condition such as name,
% brightness, onset, duration, type etc.
%{
Extracts and assigns parameters:
unit_num = the numerical designation of a neuron.
place_num = the numerical designation of the indices of the ctimulus condition across the entire data set.
unit = string designation of the unit, stays the same across different
    condition for a single neuron.Can be used as figure title.
stim = string designation of the stimulus condition, gives at a glance
    info, useful in figures, also later used to determine which AV stimuli has
    which corresponding Vis stim
cat_num = animal number, needs to be entered manually.
    rearing condition = Dark-reared, normal reared or noise reared. Needs
    manual entry.
type_num = Aud only = 0, Visual only = 1. Aud-Vis = 10
leds = 1 led, static; 3 leds, static; 13 left to right apparent motion; 31 right to left apparent motion.
aud_onset, vis_onset, soa, trial_length - self-explanatory.
intensity = LED intensity. 1,2,3 for low,med,high resp.

Some older code which was abandoned has been commented out, in case it
needs to be reused (unlikely but it's there if you need it. Initially
string designations were used, later on numeric designations replaced them.
String designations are now retained only in the stim field, due to ease of readability and 
the purpose it serves later.
%}
stim_vis_data_key = stimParams(:,1)==stim_condition & stimParams(:,2)==1;
stim_aud_data_key = stimParams(:,1)==stim_condition & stimParams(:,2)==0;

% Labelling the stim condition starts =====================================
mag = '0'; led_count = '0'; direc = 's'; leds = uint8(0); intensity = uint8(0);

if sum(stim_aud_data_key) ~= 0
    type = 'A'; type_num = (0); mag = '0'; led_count = '0'; direc = 's'; aud_onset = (stimParams(stim_aud_data_key,3)); aud_present = 'n';
    vis_onset = NaN; leds = 0;
    
end


if sum(stim_vis_data_key) ~= 0
    type = 'V';
    type_num = 1;
    aud_onset = NaN;
    
    
    stim_vis_mag = unique(stimParams(stimParams(:,2)==1,5));
    if stimParams(stim_vis_data_key,5) == min(stim_vis_mag)
        mag = 'L';
        intensity = 1;
    elseif stimParams(stim_vis_data_key,5) == max(stim_vis_mag)
        mag = 'H';
        intensity = 3;
    else
        mag = 'M';
        intensity = 2;
    end
    
    vis_onset = (min(stimParams(stim_vis_data_key,3)));
    
    if sum(stim_vis_data_key) == 1
        led_count = '1';
        leds = 1;
    end
    
    if sum(stim_vis_data_key) > 1
        if length(unique(stimParams(stim_vis_data_key,3))) == 1
            led_count = '3';
            leds = 3;
        elseif length(unique(stimParams(stim_vis_data_key,3))) > 1
            current_trial_stim_info = stimParams(stim_vis_data_key,:);
            [light_pos_first_x_key,y] = find(current_trial_stim_info(:,6) == min(unique(current_trial_stim_info(:,6))));
            [light_pos_first_y_key,y] = find(current_trial_stim_info(:,7) == min(unique(current_trial_stim_info(:,7))));
            
            if length(light_pos_first_x_key) == 1
                motion = 'horiz';
                left_right = find(current_trial_stim_info(:,3) == min(current_trial_stim_info(:,3))) == find(current_trial_stim_info(:,3) == current_trial_stim_info(light_pos_first_x_key,3));
                right_left = find(current_trial_stim_info(:,3) == max(current_trial_stim_info(:,3))) == find(current_trial_stim_info(:,3) == current_trial_stim_info(light_pos_first_x_key,3));
                
                if left_right
                    direc = 'LR';
                    leds = 13;
                elseif right_left
                    direc = 'RL';
                    leds = 31;
                else
                    direc = 'error';
                    leds = NaN;
                end
            elseif length(light_pos_first_y_key) == 1
                motion = 'vert';
                up_down = find(current_trial_stim_info(:,3) == min(current_trial_stim_info(:,3))) == find(current_trial_stim_info(:,3) == current_trial_stim_info(light_pos_first_y_key,3));
                down_up = find(current_trial_stim_info(:,3) == max(current_trial_stim_info(:,3))) == find(current_trial_stim_info(:,3) == current_trial_stim_info(light_pos_first_y_key,3));
                if up_down
                    direc = 'UD';
                    leds = NaN;
                elseif down_up
                    direc = 'DU';
                    leds = NaN;
                else
                    direc = 'error';
                    leds = NaN;
                end
            else
                motion = 'error';
                direc = 'error';
                
            end
        end
    end
    if sum(stim_aud_data_key) ~= 0
        type = 'AV';
        type_num = 10;
        aud_onset = (stimParams(stim_aud_data_key,3));
    end
end

%         Writing stim labels to analysis cell


trial_length_ms = stimOrder(2,1) - stimOrder(1,1);

if numel(aud_onset) > 1
	aud_onset = aud_onset(1);
end

soa = [];
if ~isempty(aud_onset) && ~isempty(vis_onset)
    soa = num2str(abs(vis_onset - aud_onset));
end

if soa == '0'
    soa = '00';
end

all_data.unit_num(process_count) = single(unit_count);
all_data.place_num(process_count) = single(process_count);
all_data.unit{process_count} = figure_name;
all_data.stim{process_count} = [type '_' mag '_' led_count '_' direc '_' soa];
all_data.cat_num{process_count} = '';
all_data.rearing{process_count} = '';
all_data.type_num(process_count) = single(type_num);  %Auditory only stims are 0, visual only 1, Av are 10
all_data.leds(process_count) = single(leds); % Number of static  LEDs or direction of LEDs in moving: 1,3, or 13 (LR) and 31 (RL)
all_data.aud_onset(process_count) = aud_onset; 
all_data.vis_onset(process_count) = vis_onset;
all_data.soa(process_count) = (str2double(soa)); 
all_data.trial_length_ms(process_count) = single(trial_length_ms);
all_data.intensity(process_count) = single(intensity); %1,2,3 for low, medium, high
