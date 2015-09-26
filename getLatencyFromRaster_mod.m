% getLatencyFromRaster_mod.m
% This function computes the estimated onset and offsets of the response
% from an impulse raster using the three-step geometric method of Rowland et al. (2007,2008).
%
% Requires ttest.m for the significance test.
%
% Three input parameters:
%       raster - the trialXtime binary matrix of the impulse raster
%       stimon - the stimulus onset time
%       maxoff - maximum time for the response offset
%
% Returns 3 outputs:
%       on  - estimate of the response onset
%       p   - estimate of the pvalue for the response (t-test stim driven vs. spontaneous)
%       off - estimate of the response offset
%
%%% Created by B. A. Rowland 08/2005 (browland@wfubmc.edu)

function [on,p,off,qsumovertime,qsumtilltime] = getLatencyFromRaster_mod(raster,stimon,maxoff)
on=stimon;
p=1;
off=[];
if(sum(sum(raster))==0) return; end %If the raster is blank, return
[trials spikes] = find(raster);     %Recover trials and spikes from raster.  Used to find nearest impulse 
qsum = cumsum(sum(raster));         %Compute cumulative impulse count
MAXTIME = length(qsum);             %The maximum time is the length of the raster

%Step 1 of method: bracket response onset.
%   1.1: compute qsum(t)/t and find maximum.  This is the estimated offset (E)
%   1.2: bracket the response onset by reflecting E around the stimulus onset to B
qsumovertime = [zeros(1,stimon) ones(1,MAXTIME-stimon)].*qsum./[1:MAXTIME]; %compute the function qsum(t)/t
qsumtilltime = [zeros(1,stimon) ones(1,MAXTIME-stimon)].*qsum; %compute the function qsum(t)
E = min([find(qsumovertime==max(qsumovertime)) maxoff]);                    %compute E - finds whether the time at which qsumovertime is max is within the window or is it the end of the window
B = max([1 2*stimon - E]);                                                  %compute B - the time span from stimon to max(qsumovertime) is computed 
if(B>=E) return; end                %error checking.  If B is somehow ==E then fail

%Step 2 of method: form a triangle by drawing a line between qsum(B) and qsum(E)
slope = (qsum(E)-qsum(B))/(E-B);        %The slope of the line. A negative slope or zero would indicate suppression of or no stim driven activity resp
if(slope<=0) return; end;               %error checking. If slope is <=0 then fail (only excitatory responses)

%Step 3 of method: find maximum plumb line from drawn line to qsum (perp. to drawn line)
F = (qsum(B:E) - qsum(B) + slope*([B:E]+B))/(2*slope); %Location of plumb line intercept w/ drawn line
X = sqrt( ([B:E]-F).^2 + (slope*([B:E]-B) + qsum(B) -qsum(B:E)).^2 ).*([zeros(1,max(0,stimon-B + 1)) ones(1,E-stimon)]); %Length of plumb line
R = B + min(find(X==max(X)));                          %Location on qsum generating plumb line w/ max length
on = min(spikes(find(spikes>=R)));              %That's the response onset

%Improve estimate of response offset by inverting qsum, using E and response onset to bracket, and repeating steps 2-3
G = min(length(raster(1,:)),2*E - R);%The start point (i.e., the new "B")   
if(G==R) return; end                 %error checking.  If G is somehow == R then fail                       
slope = (qsum(G) - qsum(R))/(G-R);   %new slope
if(slope<=0) return; end             %error checking.  If slope is <=0 then fail. 
F = (qsum(R:G) + slope*((R:G)+R) - qsum(R))/(2*slope);                  %New plumb line intercept
X = sqrt(  ([R:G]-F).*2 + (slope*([R:G]-R) + qsum(R) - qsum(R:G)).^2 ); %New plumb line length
E = R + min(find(X==max(X)))+1;      %New estimate of response offset
if(E==R) return; end                 %error checking.  If E==R then fail.
off=max(spikes(find(spikes<=E)));    %update improved response offset estimate

%Now compute the significance value of impulse counts using a t-test (requires t-test.m) - change as desired
D0=(E-R)*sum(raster(:,1:stimon)')/stimon;   %Scaled spontaneous activity
D1=sum(raster(:,R:E)');                     %Stimulus-driven activity
p = ttest(D0,D1);                   %And here's the t-test