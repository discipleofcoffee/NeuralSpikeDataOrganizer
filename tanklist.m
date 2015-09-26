function file_list = tanklist(path)
%TANKLIST Retrieves path of each data tank block
%TANKLIST(), accepts a folder path as input argument, but instead retrieves all the blocks...
%in all data tanks available in a prespecified folder. Returns the output
%as a cell list.

% path = 'C:\Users\kchawla\WORK\LAB_DATA\Stein_Lab\data_tanks\';
dirinfo = dir(path);
dirinfo(~[dirinfo.isdir]) = [];  %remove non-directories
remove_fields = {'date';'bytes';'isdir';'datenum'};
dirinfo = rmfield(dirinfo,remove_fields);
dirinfo = struct2cell(dirinfo);
dirinfo =dirinfo';
dirinfo = dirinfo(3:end);
folders = cell(length(dirinfo),1);
folders(:,1) = {path};
folders = [folders dirinfo];
all_paths =  cell(length(folders),1);
file_list = {};
% file_list = cell(length(folders),1);
x=0;

file_error_count = 0;
file_error_list = {};
timestamp = datestr(now);

data_one = {};
temporal_profile_data = {};
data_for_analysis_all = {};
% data_for_analysis_all_struc 
  %%  
for k = 1:length(folders)
    all_paths(k,1) = cellstr([folders{k,1},[folders{k,2},'\']]);
    dirinfo(k,1) = cellstr([folders{k,1},[folders{k,2}],'\*.m']);
    
    dir_files = dir(cell2mat(dirinfo(k)));
    path = all_paths(k);
    for loop_count = 1:length(dir_files)
        x = x+1;
        
        if ~isempty(dir_files(loop_count).name)
            block = dir_files(loop_count).name;
            file_list(x) = strcat(path,block);
        end
    end
    
end
% clear folders
file_list = file_list';
%%


% files_data_written_count = 0;
% all_info = cell('');
% next_row =1;
% % all_info(1:length(file_list),1) = struct('unit_name', {}, 'stim_tag', {}, 'mean_impulse', {},'error',{},'msip', {},'sig', {})
% for data_block_file_count = 1:length(file_list)
%    
%     temp_name = cell2mat(file_list(data_block_file_count));
%     PathName =  temp_name(1:end-9);
%     find_dirmark = find(temp_name == '\');
%     data_tank = temp_name(find_dirmark(end-1)+1:find_dirmark(end)-1);
%     block_name = temp_name(find_dirmark(end)+1:end-2);
%     % FileName = 'Block3.m';
%     file =  cell2mat(file_list(data_block_file_count));
%     
%     run(file)
%     data_tank(data_tank == '-') = '_';
% figure_name = [data_tank '_' block_name];
% end
