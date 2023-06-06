%% Main script
% this script calls all thesis relevant scripts
% in order to succesful execut choose correct path
% for script 1 and 3, cloud computer is recommended since they are
% computational heavy 
% to execute individual scripts without this main script: local =
% e.g., '\\psyger-stor02.d.uzh.ch\'; must be uncommented and correctly adjusted in each script



%% Set path: local or cloud 

% if executed local then change local to correct prefix of path!
local = '\\psyger-stor02.d.uzh.ch\'; 

s_cloud = 0;

% following code will be in all scripts
% if s_cloud
%     prefix = '/mnt/methlab-drive/'; % ubuntu
%     prefix = fullfile('\\130.60.169.45\') % windows
% else
%     prefix = local;
% end

%% CD to scripts
cd(fullfile(local, 'methlab\Students\Oliver\script\ScriptsMAT'));

%% Script 1: a1_preprocessing
s_cloud = 1; % change to 0 if not cloud 
disp('Reading script 1')
a1_preprocessing

%% Script 2: a2_demo_exclusion
s_cloud = 0; 
disp('Reading script 2')
a2_demo_exclusion

%% Script 3: a3_p300
s_cloud = 0; 
disp('Reading script 3')
a3_p300

%% Script 4: a4_topo
s_cloud = 1; % change to 0 if not cloud 
disp('Reading script 4')
a4_topo


%% script 5: a5_plots
s_cloud = 0; 
disp('Reading script 5')
a5_plot