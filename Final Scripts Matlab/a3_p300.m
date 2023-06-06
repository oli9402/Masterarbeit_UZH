%% load table generated in a2_demo_exclusion and add P300 amplitude value
% input full_tab_a2
% output full_tab_a3

%% local or cloud

% if script run individual then uncommented next two lines!
%local  = '\\psyger-stor02.d.uzh.ch\';
%s_cloud = 0;


if s_cloud
    prefix = '/mnt/methlab-drive/'; % ubuntu
    prefix = fullfile('\\130.60.169.45\') % windows
else
    prefix = local;
end
%% save path 
% creates path to save final table of this script
data_path = fullfile(prefix, 'methlab\Students\Oliver\script\nobase_corr\Mat_Files');
%% load table
load(fullfile(prefix, '\methlab\Students\Oliver\script\nobase_corr\Mat_Files\full_tab_a2.mat'));

%% load single EEG file for P300 time window
load(fullfile(prefix, 'methlab_data\HBN\EEG-ET_Joelle_MA_results\NDARAA075AMK\gip_vis_learn_EEG.mat'));



%% table with individual ERPs and Agegroup index
% tables for individual ERP and group ERP are created
% all trials all included (NL, K, UN, F)

id =unique(full_tab.ID);


% create wide format table: each row = one subject with ERP
data_individual = table;
data_individual.ID = unique(full_tab.ID);

for i = 1:size(id,1)
    idx = string(full_tab.ID) == id{i};
    %create average EEG ERP waveform for each individual
    eegAvgData = cat(3,full_tab.data{idx});
    eegAvgData =  mean(eegAvgData,3);
    data_individual.erp{i} = eegAvgData;
    % add agegroup information for group ERP
    data_individual.agegroup(i) = unique(full_tab.agegroup(idx));
    clear eegAvgData
end



%% peak and time window for age groups
truePeakMs = [];

for ageGroupIndex = 1: 7
    clear eegAvgData 
    eegAvgData = cat(3,data_individual.erp{data_individual.agegroup == ageGroupIndex});
    eegAvgData = mean(eegAvgData,3);

    % find max in 300-500ms (+100, because start = 0 and not -100 --> 400 - 600)
    %(400)+2/2 = 201
    %(600+2)/2 = 301
    %set all other than window to zero -> easier index later (timepeak)
    index_time = EEG.times >= 400 & EEG.times <= 600;
    eegAvgData(~index_time) = 0;
    
    [~ ,timePeak] = max(eegAvgData);


    %eegAvgData = cat(3,full_tab.data{full_tab.agegroup == ageGroupIndex});
    %eegAvgData = mean(eegAvgData,3);
    %plot(eegAvgData)
    %xline(timePeak)
    peakMS = EEG.times(timePeak);

    
    %array with logical values for each age group (time window for P300
    %calulation)
    idxTimeWindow(ageGroupIndex,:) = EEG.times >=  peakMS -50 & EEG.times <= peakMS +50;
    
    %subtract 100 because of -100
    truePeakMs(ageGroupIndex) = peakMS-100; 

end


% calculate p300 in each trial with age appropriat time window 
for row = 1 :size(full_tab,1)
    aG = full_tab.agegroup(row); % what agegroup
    full_tab.P300(row) = mean(full_tab.data{row}(idxTimeWindow(aG,:)));
end




%% save

cd(fullfile(prefix, 'methlab\Students\Oliver\script\nobase_corr\Mat_Files'));

save truePeakMs.mat truePeakMs
save full_tab_a3.mat full_tab