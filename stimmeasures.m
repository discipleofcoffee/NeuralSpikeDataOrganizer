function units_data = stimmeasures(units_data,process_count,varargin)
% Calculates response on and off times, per trial and mean trial impulse
% counts and initial response slope.


% the variable argument in feature can be used to supply a stimon time. By
% default, the stimon time is calculated by which ever stimulus turns on
% first.
if nargin == 3
    stimon = varargin{1};
else
    stimon = min(units_data.aud_onset(process_count),units_data.vis_onset(process_count));
end
maxoff = 2* stimon;

%Uses Ben's script tofigure out response onset time. Modified from the
%original to return some more stuff than Ben originally wrote for. The
% modified function also returned the response off time, but that is not
% used in lieu of the better function I wrote later.
[on,p,~,~,qsumtilltime] = getLatencyFromRaster_mod(units_data.raster{process_count},stimon,maxoff);
qsumtilltime = full(qsumtilltime);
    units_data.response_onset(process_count) = single(on);

% figures out the response off time.
units_data = response_offset(units_data,process_count);
off = units_data.response_off(process_count);


% If the response duration is greater than the pre stim onset
% time/spontaneous activity time, then to ensure the greater spontaneous
% time period doesn't over-normalize the shorter response period, the
% spontaneous activity levels measured are scaled down.
if abs(on-off) > on
    scale = abs(on-off)/500; %this needs verification
    units_data.per_trial_impulse_count = full(sum(units_data.raster(:,on:off),2) - scale*sum(units_data.raster(:,1:on),2));
else
    scale = 1;
    units_data.per_trial_impulse_count{process_count}  = sum(units_data.raster{process_count}(:,on:off),2) - sum(units_data.raster{process_count}(:,on-abs(on-off):on),2);
end

units_data.mean_trial_impulse_count(process_count) = single(mean(units_data.per_trial_impulse_count{process_count}));

%calculates the slope of line subtended from unit activity at response
%onset time to unit activity at response off time. It gives an indication
%of how quickly the unit reaches max response.
units_data.init_resp_slope(process_count) = abs((qsumtilltime(off) - qsumtilltime(on))/(on - off));



% Again, used to serve debugging purpose originally, alerted me which cases
% had gone wrong or ned to be looked at.
if units_data.mean_trial_impulse_count(process_count) < 1

    units_data.error(process_count) = single(1);
else
    units_data.error(process_count) = single(0);
end



