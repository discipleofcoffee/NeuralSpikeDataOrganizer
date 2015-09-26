function spike_density = sdf(raster,sigma)

if nargin  == 1 || isempty(sigma);   sigma = 7;   end  %if size isn't specified


center_mean = 0;
sigma = 7;
factor = 3;
range = sigma*factor;
% figure
kernel = normpdf(-range:range,center_mean,sigma);
kernel = kernel/sum(kernel);
kernel  = kernel.*1000;
% plot(-range:range,kernel)
spike_density = convn(mean(raster),kernel,'same');



