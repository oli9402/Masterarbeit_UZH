%% create table for R 

%% local or cloud

% if script run individual then uncommented next two lines!
local  = '\\psyger-stor02.d.uzh.ch\';
%s_cloud = 0;


if s_cloud
    prefix = '/mnt/methlab-drive/'; % ubuntu
    prefix = fullfile('\\130.60.169.45\') % windows
else
    prefix = local;
end

%load file
load(fullfile(prefix, 'methlab\Students\Oliver\script\nobase_corr\Mat_Files\full_tab_a4.mat'))

%delete EEG data 
full_t = full_tab;
full_t.data = [];
full_t.databaseline = [];

% save table to
cd(fullfile(prefix,'methlab\Students\Oliver\script\Final Scripts R\Data'))
writetable(full_t,'full_t.csv')