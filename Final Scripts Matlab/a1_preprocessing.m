%% all analysis performed on Matlab R2021b

% Requirements:
% eeglab2019_0
% eye-eeg-master


%% merge EEG, BD and ET data, epoch and remove trials with bad ET

% creates tables with all, behavioral and neurophysiological data: 
% full_tab - light version - only 6 centro-parietal channels
% full_tab_topo - contains data from all channels (18 GB)

% Runs the code twice: 
% 1. Without baseline correction (data for linear mixed models)
% 2. With baseline correction (data for plots)

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
%% path for saving
% creates path to save final tables of this script
data_path = fullfile(prefix, 'methlab\Students\Oliver\script');


%% EEGlab
%adds eeglab
addpath(fullfile(prefix, '\methlab\4marius_bdf\eeglab'))
eeglab
close()

%% prepare to load ET data
% creates table with path for ET data of each subject

% using * to consider all folders in EEG-ET (every sub has one folder)
dataDirET = fullfile(prefix, 'methlab_data/HBN/EEG-ET/*/');

% select path to file that contains: _vis_learn_bothEyes_ET.mat
a = dir([dataDirET, '/*_vis_learn_bothEyes_ET.mat']);
pathET = struct2table(a);

%% prepare to load EEG data 
% creates table with path for EEG data of each subject
dataDir = fullfile(prefix,'methlab_data/HBN/EEG-ET_Joelle_MA_results/*/');

% select path to file that contains: ip and .map 
% only relevant files have ip and mat in name (gip, bip, oip)
a2 = dir([dataDir, '*ip*.mat']); 
pathEEG = struct2table(a2);



%% prepare to load BD data
% creates table with path for Behavioral data of each subject
dataDirBD = fullfile(prefix,'methlab_data/HBN/EEG-ET/*/');

% select path to file that contains: _vis_learn.mat
a3 = dir([dataDirBD, '/*_vis_learn.mat']);
pathBD = struct2table(a3);

%% make sure, pathET and pathEEG have the same subject in each row
% these loops go through every row of tables and extracts the name of each
% individual from the file path
for i = 1:size(pathET, 1)
    pathET.short_name{i} = pathET.name{i}(1:12);
end

for i = 1:size(pathEEG, 1)
    pathEEG.short_name{i} = pathEEG.folder{i}(end-11:end); 
end

for i = 1:size(pathBD, 1)
    pathBD.short_name{i} = pathBD.name{i}(1:12);
end

% keeps only unique. deletes duplicates
[C,ia] = unique(pathET.short_name);
pathET = pathET(ia,:);

[C,ia] = unique(pathEEG.short_name);
pathEEG = pathEEG(ia,:);

[C,ia] = unique(pathBD.short_name);
pathBD = pathBD(ia,:);

% join both tables by 
path = outerjoin(pathEEG, pathET, 'Keys',{'short_name','short_name'}, 'MergeKeys',true);
path = outerjoin(path, pathBD, 'Keys',{'short_name','short_name'}, 'MergeKeys',true);

% add command second time to make it work
path = outerjoin(path, pathBD, 'Keys',{'short_name','short_name'}, 'MergeKeys',true);

% table has 2763 subjects 
%% delete with subjects with nan
% some subjects don't have EEG or Behavioral data -> delete
% since main focus was not on ET data only behavioral and EEG was checked
idx = ismember(path.folder_pathEEG,'')| ismember(path.folder_pathBD,'');
path(idx,:) = []; % table has 2203 subjects (560 subjects deleted)


% i = ~ismember(path.name_pathEEG, '') & ~ismember(path.name_pathBD, '') & ~ismember(path.name_pathET, '') 
% length(find(i)) % 2040 have all data 
%% do all preprocessing steps with and without baseline correction
all_ind = {};
for i_base = 1 : 2 

    %% baseline correction?
    BASE_CORR = i_base;

    if BASE_CORR == 1
        base_choice = 'base_corr'; %for folder in data path
    else
        base_choice = 'nobase_corr'; %for folder in data path
    end

    %% run over all participants and sequences
    seq_tot = size(path, 1);

    noisy_chan = [1 8 14 17 21 25 32 48 49 56 63 68 73 81 88 94 99 107 113 119 125 126 127 128];

    full_tab = table;
    full_tab_topo = table; 

    for index = 1: seq_tot

        try

            % find ID of the subject
            id = path.folder_pathEEG{index}(end-11:end);
            % print ID
            fprintf(1, 'Now reading %s\n', id);

            % load EEG data
            load([char(path.folder_pathEEG(index)),'/', char(path.name_pathEEG(index))]);

            % reduce channels number to 105
            EEG = pop_select(EEG,'nochannel',noisy_chan );

            EEG.icaact = [];
            EEG.icaweights = [];
            EEG.icasphere = [];

            % load BD data
            load([char(path.folder_pathBD(index)),'/', char(path.name_pathBD(index))]);

            % merge EEG and BD data
            EEG.BD = par;

            % length of sequence
            len_response = length(EEG.BD.sequence);
            % different triggers
            if len_response == 7
                trigger = [11,12,13,14,15,16];
            else
                trigger = [11,12,13,14,15,16,17,18]; % ,21,22,23,24,25,26,27,28
            end
            
            % block
            block = EEG.BD.numrepet;
            
            % create Categories
            % 1 = NL, 2 = UN, 3 = K, 4 = F
            for idx = 1 : block
                for idx2 = 1 : len_response
                    
                    %for first block (only NL or UN)
                    if idx == 1
                        if EEG.BD.resp_click(idx, idx2) == EEG.BD.sequence(idx2)
                            EEG.BD.categories(idx, idx2) = 1; % NL
                      
                        else 
                            EEG.BD.categories(idx, idx2) = 2; % UN
                        end
                     
                     %for all other blocks
                     elseif idx > 1
                            if  EEG.BD.resp_click(idx, idx2) == EEG.BD.sequence(idx2) & EEG.BD.resp_click(idx-1, idx2) == EEG.BD.sequence(idx2) % K
                                EEG.BD.categories(idx, idx2) = 3; % K                   
                            elseif EEG.BD.resp_click(idx, idx2) == EEG.BD.sequence(idx2) & EEG.BD.resp_click(idx-1, idx2) ~= EEG.BD.sequence(idx2) % NL
                                EEG.BD.categories(idx, idx2) = 1; % NL                      
                            elseif EEG.BD.resp_click(idx, idx2) ~= EEG.BD.sequence(idx2) & EEG.BD.resp_click(idx-1, idx2) ~= EEG.BD.sequence(idx2) % UN
                                EEG.BD.categories(idx, idx2) = 2; % UN
                            elseif EEG.BD.resp_click(idx, idx2) ~= EEG.BD.sequence(idx2) & EEG.BD.resp_click(idx-1, idx2) == EEG.BD.sequence(idx2) % F
                                EEG.BD.categories(idx, idx2) = 4; % F
                            end                   
                     end
                end  
          
           

            end
            
            

            % accuracy, 0 incorrect, 1 correct
            EEG.BD.accuracy = zeros(block, len_response); 
            i = EEG.BD.categories(:, :) == 1 | EEG.BD.categories(:, :) == 3;
            EEG.BD.accuracy(i) = 1;
      
          
            % this wasn't used in my thesis 
            % distance categories to the point of first accurat recall in
            % blocks (computed based on: 1 = NL, 2 = UN, 3 = K, 4 = F)
            EEG.BD.distance = NaN(block,len_response);
            i = EEG.BD.categories == 1; % find all NL => distance = 0
            EEG.BD.distance(i) = 0;
            
            for col = 1 : len_response    
                nl = find(EEG.BD.distance(:, col) == 0, 1); % position of NL in a column
                if sum(nl) < 1 % if no NL, set to high number
                    nl = 9;
                end
                s = sum(EEG.BD.distance(:, col) == 0);
                for row = 1 : block
                    if s > 1 % if F in a column (more than one 0), remove trial (NaN)
                        EEG.BD.distance(row, col) = NaN;
                    else
                        EEG.BD.distance(row, col) = row - nl;  
                    end
                end
            end


            % filtering
            EEG = pop_eegfiltnew(EEG,[],45);

            % re-referencing, [] is average reference
            EEG = pop_reref(EEG, [], 'keepref', 'on');
  

        


            % Segmentation
        
            if len_response == 7
                EEG = pop_epoch(EEG, {11,12,13,14,15,16}, [-0.1 0.8]); 
            else
                 EEG = pop_epoch(EEG, {11,12,13,14,15,16,17,18}, [-0.1 0.8]); 
            end



            % baseline correction
            if BASE_CORR == 1
                EEG = pop_rmbase(EEG, [-100 0]);
            end


            % create tables
            rating = path.name_pathEEG{index}(1:3); %EEG rating
            seq_len = len_response; %sequence length (7/10)
            full_table = table;
            stimuli = 1:(len_response*block);
            block = sort(reshape(repmat(1:block,1,len_response), [], 1));
            seq = [EEG.BD.sequence EEG.BD.sequence  EEG.BD.sequence  EEG.BD.sequence  EEG.BD.sequence];

            for idx3 = 1:size(EEG.data, 3)
                  full_table(idx3, 1) =  {id};
                  full_table(idx3, 2) =  {seq_len}; 
                  full_table(idx3, 3) =  table(stimuli(idx3));
                  full_table(idx3, 4) =  table(block(idx3));  
                  full_table(idx3, 5) = {EEG.data(1:105,:,idx3)};
                  full_table(idx3, 6) = {rating};
                  full_table(idx3, 7) = table(seq(idx3));
                  full_table(idx3, 8) = table(ETscreen(idx3));
            end

            an = table(reshape(EEG.BD.resp_click',[], 1));
            cat = table(reshape(EEG.BD.categories',[], 1));
            dist = table(reshape(EEG.BD.distance',[], 1));
            acc = table(reshape(EEG.BD.accuracy',[], 1));
          

            full_table(:, 9) = an(1:size(EEG.data, 3),1);
            full_table(:, 10) = cat(1:size(EEG.data, 3),1);     
            full_table(:, 11) = dist(1:size(EEG.data, 3),1);
            full_table(:, 12) = acc(1:size(EEG.data, 3),1);

            % artifact rejection - only on baseline corrected data
            % not baseline corrected data will have the same indices
            % removed
            if BASE_CORR == 1
                thresh = 90;
                ind = 0;
                for idx4 = 1 : size(full_table, 1)
                    ind(idx4, 1) = squeeze(sum(sum([(full_table.Var5{idx4}(1:105, :) > thresh) | (full_table.Var5{idx4}(1:105, :) < -thresh)],1),2) == 0);
                end
                all_ind{index} = logical(ind);
            end
            full_table = full_table(all_ind{index},:);

            reject{1, index} = id;
            reject{2, index} = sum(all_ind{index});
            reject{3, index} = length(all_ind{index});

            % full_tab for topo:
            full_tab_topo = [full_tab_topo; full_table];


            % full_tab for other analysis:

            % select channels and create big table
            chan = {EEG.chanlocs.labels};
            E54 = ismember(chan, 'E54');
            E55 = ismember(chan, 'E55');
            E61 = ismember(chan, 'E61');
            E62 = ismember(chan, 'E62');
            E78 = ismember(chan, 'E78');
            E79 = ismember(chan, 'E79');
            ECz = ismember(chan, 'Cz');
            E55 = ismember(chan, 'E55');

            channels = logical(E54 + E55 + E61 + E62 + E78 + E79 + ECz);
            channels = channels(1, 1:105);

            % take only the 7 centro-parietal channels            
            for idx5 = 1:size(full_table, 1)
                full_table.Var5{idx5}(~channels, :) = [];
            end

            full_tab = [full_tab; full_table];


        catch ME
            warning('Error')
            error_id{index} = id;
            ME.message
        end
    end



    %% save the tables
    result_folder = fullfile(data_path, base_choice, 'raw/');

    save([result_folder, 'full_tab.mat'],'full_tab','-v7.3') 
    save([result_folder, 'full_tab_topo.mat'],'full_tab_topo','-v7.3') 
    save([result_folder, 'reject.mat'],'reject','-v7.3') 


end