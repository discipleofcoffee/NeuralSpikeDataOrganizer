% Searches for processed data tank files, and extracts and organizes information from
% them, for use in analysis using independent scripts.
%{
::Experimental Context::

The program was writen for an experiments with the goal of generating
neuronal response for a large variety of stimulus conditions. To that end,
stimuli with 1 LED, 3 LEDs, Left to Right and Right to Left Apparent motion
LEDs at different brightness intensities and different SOAs were
implemented.
As the experimental paradigms evolved, more variety of stimuli were added,
so some initial units have fewer conditions than later ones. As much as
possible the program works around the discrepancies, in a manner that will
minimize the effect on analysis.

::Data structure::

The data is stored in a structure of arrays. The basic structure is thus:
    units_data.(fieldname)(index) or {index}(subscript) for cells.

units_data = the structure holding all the data.

Fieldname = the kind of value being stored in them, for example,
    trial_length, visual stimulus onset, etc.

index = different case numbers. This merits some explanation. Index is referred to
as 'Case' or 'Process' in subsequent comments. Using an example:
if we have 2 neurons aka units, with the first neuron exposed to 12
stimulus conditions and the second one exposed to 5 stimulus condition, each field of 
units_data will be an array or cell array of size 17. So the cases are arranged as one big
sequence and not seggregated based on which unit they belong to (to do
that, use the unit_num field and logical subscripting).
 
So to access case 1, use units_data.(fieldname)(1), example
units_data.msi(1) will give msi of case 1.

::Notes::

The place_num field is useful because is assigns a unique number to each case,
which stays the same even a subset of the unit was assigned to another
variable. Due to this reason,instead of directly accessing using array
indices, in most place, place_num is used as an indirect access mechanism.

Initially an object oriented approach was used :
units_data(index).(fieldname) 
This made logical sense and units_data(1) would give all the info of case
1. But it seems Matlab, atleast the version is not very efficient in
handling such constructs (array of structures) and consumed so much RAM
that the computer would just freeze while loading the file. So the new
configuration (structure of arrays) was chosen.

The program is still pretty modular, and it's easy to write new function
and insert them at appropriate location in this script if something new
needs to be included.

Also, to conserve memory, doubles are not used anywhere, instead singles
are used. Some fields could have used ints for further reduced memory
footprint, but I wanted to use NaN for missing values, which only floats
support. Also,It was a big mess trying to typecast some variable on the fly
at multiple places because int didn't support one operation or another.

The commented out code is for several other things that I was calculating
and storing. Eventually some were more useful than others and so I didn't
return the unneeded values. Should be simple enough to reactivate. Or
delete.

There are also a few variables which collect some other data, which was
useful in the initial days for debugging and keeping track of program
execution, such as the error field and file_error_list etc. They are not
saved anymore to minimize memory consumption on reloading. They weren't
being used for any other purpose.

::Variable naming scheme ::

(Generally speaking), variables with _(following)_ in their names indicate:

'key' = logical arrays for subscripting or actual indices within a subset
    of arrays.
'place' = global indices of the relevant value.
'uni' = unimodal condition related.
'av' = multimodal condition related.
'count' = counter for a specific value in for loops.
'rel' = relative
%}




tic

clear

% Preallocating the data structure for speed. Also contains explanation of
% each field.
units_data = units_data_creator();


% the function response_offset generates polynomial not unique warning so to silence that.
% If you can fix the reason for the warning, then great. More power to you.
poly_warn = 'MATLAB:polyfit:PolyNotUnique'; 
warning('off',poly_warn );
%% checks the system on which it is being run, and loads data from different
% paths accordingly. This was for when I worked from my home computer
% instead of my laptop.
% ====================Modify this path according to your file structure.
!hostname > hostname.txt
system_name = textread('hostname.txt','%s');

if strcmp(system_name,'HomeDesktop')
    path = 'Z:\Not Backup\Work\Data_tanks\';
    stored_data_path = 'C:\Users\Kshitij\OneDrive\MATLAB\PSTH code\Data\units_data.mat';
else
    path = 'C:\Users\kchawla\WORK\LAB_DATA\Stein_Lab\data_tanks\';
end
stored_data_path = 'C:\Users\Kshitij\SkyDrive\MATLAB\Documented_final_code\Data\units_data.mat';

%%

% Concerned with extracting the names of data files within data tanks.
% Each Data tank has mutiple blocks, each block file represents seoarate
% recording sessions, each recording session can have 1 or more neurons aka
% units indicated by different sort codes (sorts)and each data tank is the recording
% from a single day. There are some data tanks and block files which don't
% work proeprly, either due to recording error or due to premature
% recording termination.

file_list = {};        %Declaring some variables for later use.
file_error_list = {};  %Helped with troubleshooting, but can be discarded after succesful organization of data
unit_error_list = {};  %Helped with troubleshooting, but can be discarded after succesful organization of data
unit_names = {};
trial_length_ms_limit = 1000;

fprintf('\n\nRetreiving Data tanks List...\n');
file_list = tanklist(path);
file_list_length = length(file_list);
fprintf('%d potenital data tanks found.\n',file_list_length);

units_data = [];
file_error_count = (0);
unit_count = (0);
process_count = (0);
fprintf('Processing...\n')
tank_number = (0);
%%
for data_block_file_count = 1:file_list_length
    
    msg = (fprintf('%d/%d\r',data_block_file_count,file_list_length));
    tank_number = msg;
    
    
    %% Extracts paths and names of the individual block files and runs them.
    temp_name = cell2mat(file_list(data_block_file_count));
    PathName =  temp_name(1:end-9);
    find_dirmark = find(temp_name == '\');
    data_tank = temp_name(find_dirmark(end-1)+1:find_dirmark(end)-1);
    block_name = temp_name(find_dirmark(end)+1:end-2);
    file =  cell2mat(file_list(data_block_file_count));
    
    run(file)
    % computes the number of trials in a given stim condition:
    % total number of trials/number of unique stim conditions
    % if num of trials per condition is below 15 then it is likely that
    % block file has errors and is not useful.
    if length(stimOrder)/length(unique(stimOrder(:,2))) < 15
        %adds the names of such files to a list for later review and
        %possible troubleshooting, and increments count of erred files by
        %1.
        
        file_error_count = file_error_count +1;
        file_error_list{file_error_count,1} = {file};
        data_tank(data_tank == '-') = '_';
        unit_error_list{file_error_count,2} = [data_tank '_' block_name '_sort_' num2str(current_sort)];
        unit_error_list{file_error_count,1} = file_error_count;
        
    else
        % number of different neurons (sorts) the electrode picked up
        unique_sorts = (unique(spikeData(:,2)));
        unique_sorts(unique_sorts == 31) = [];      % removes conditions 0 and 31
        unique_sorts(unique_sorts == 0) = [];       % sinec they don't mean anything.
        
        % loop runs for each 'sort' i.e. neuron/unit
        for sort_count = 1:length(unique_sorts)
            unit_count = unit_count +1;
            
            current_sort = unique_sorts(sort_count);
            data_tank(data_tank == '-') = '_';
            figure_name = [data_tank '_' block_name '_sort_' num2str(current_sort)];
            
            unit_names{unit_count,1} = unit_count;
            unit_names{unit_count,2} = figure_name;
            
            trial_length_ms = (stimOrder(2,1) - stimOrder(1,1));
            
            %Find unique stims and their total number
            num_unique_stims = (size(unique(stimOrder(:,2)),1));
            
            loop_count = (1);
            
            % for each unique stimulus condition
            for stim_condition = 1:num_unique_stims
                
                % process here means each stimulus condition across the
                % entirety of data set. For example, if we have 10 units
                % with 10 conditions each, the last process would be
                % numbered 100. Also referred to as case. process_count
                % is stored in the place_num field and serves as indices of
                % the case. Doing it this way makes it more versatile to
                % access the structure later on.
                process_count = process_count + 1;
                
                %retrieves data only pertaining to the current sort
                spikeData_current_sort = spikeData(spikeData(:,2) == current_sort,:);
                
                % Determines the conditions of the stimulus
                units_data = conditionparams(units_data,stimParams,stimOrder,...
                    spikeData_current_sort,stim_condition,figure_name,process_count,unit_count);
                
                % Computes the normalized raster, sdf and cumsum
                units_data = raster(stimParams,stimOrder,spikeData_current_sort,...
                    stim_condition,figure_name, units_data,trial_length_ms_limit,process_count);
                
                %
                units_data = stimmeasures(units_data,process_count);  % measures a bunch of parameters.
                units_data = responsepeaks(units_data,process_count); % finds out the peaks and troughs within the response time window
                units_data = significantpeaks(units_data,process_count); % an improvised way to find peaks, use with caution if at all.

            end
            [units_data] = uniplacesmsi(units_data,unit_count);
        end
    end
    fprintf(repmat('\b',1,tank_number));
    
end

save(([stored_data_path]),'units_data')
            
toc


