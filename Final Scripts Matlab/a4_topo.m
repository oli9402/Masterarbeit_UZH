%% topoplot 
%output: topo for all age groups 150-500ms + one topo row for all ages  
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
%% EEGlab
%adds eeglab
addpath(fullfile(prefix, '\methlab\4marius_bdf\eeglab'))
eeglab
close()

addpath("C:\Users\Oli\Desktop\topo")
%% load data
load(fullfile(prefix, 'methlab\Students\Oliver\script\old\full_tab_topo.mat')); %lighter version of full_tab_topo
load(fullfile(prefix, 'methlab\Students\Oliver\script\nobase_corr\Mat_Files\full_tab_a3.mat')); %for age groups only included subj.
load(fullfile(prefix, 'methlab_data\HBN\EEG-ET_Joelle_MA_results\NDARAA075AMK\gip_vis_learn_EEG.mat')); %EEG.times
load(fullfile(prefix, 'methlab\Students\Oliver\script\nobase_corr\Mat_Files\truePeakMs.mat')); %peak latency for each group

%% add path for colormap used in topoplots
addpath(fullfile(prefix, 'methlab\Students\Oliver\color_matlab'));
mycolormap = customcolormap_preset('red-white-blue');



%% find times

int = [];
%t = [200 250 300 350 400 450 500 550 600 650 700 750];
%t = [150 200 250 300 350 400 450 500]
t = [150 200 250 300 350 400 450 500] % which time points
for i = 1:size(t, 2)

    % +100 weil in topo tabelle 450 sample point mit -100:800 
    int(i, :) = EEG.times >= t(i)+100 & EEG.times <= t(i) + 150;
    
end


%% add infos to table
full_tab_topo.Properties.VariableNames{1} = 'ID';
full_tab_topo.Properties.VariableNames{2} = 'StimuliNr';
full_tab_topo.Properties.VariableNames{3} = 'BlockNr';
full_tab_topo.Properties.VariableNames{4} = 'data';
full_tab_topo.Properties.VariableNames{5} = 'Rating';
full_tab_topo.Properties.VariableNames{6} = 'Sequence';
full_tab_topo.Properties.VariableNames{7} = 'Answer';
full_tab_topo.Properties.VariableNames{8} = 'Category';

full_tab_topo(:,9) = []; % delete distance

full_tab_topo.Properties.VariableNames{9} = 'Correct';

%find ID in full tab add relevant information 
[id, ix] = unique(full_tab.ID);
full_tab_topo.age(:) = NaN;
full_tab_topo.in_tab(:) = 0;
for i =1: size(id,1)
    idx = id(i) == string(full_tab_topo.ID);
    full_tab_topo.age(idx) = full_tab.age(ix(i));
    full_tab_topo.in_tab(idx) = 1;
    full_tab_topo.agegroup(idx)= full_tab.agegroup(ix(i));
end
 
%% delete that are not in full_tab

length(unique(full_tab_topo.ID)) %1867

full_tab_topo(full_tab_topo.in_tab == 0, : ) = [];

length(unique(full_tab_topo.ID)) %1594. 



%% loop over all stimuli and compute average signal for each time point window 


% compute mean topo of time point window for each trial        
for idx = 1:size(full_tab_topo, 1)

    full_tab_topo.top1{idx} = squeeze(mean(full_tab_topo.data{idx}(1:105, logical(int(1,:))), 2));
    full_tab_topo.top2{idx} = squeeze(mean(full_tab_topo.data{idx}(1:105, logical(int(2,:))), 2));
    full_tab_topo.top3{idx} = squeeze(mean(full_tab_topo.data{idx}(1:105, logical(int(3,:))), 2));
    full_tab_topo.top4{idx} = squeeze(mean(full_tab_topo.data{idx}(1:105, logical(int(4,:))), 2));
    full_tab_topo.top5{idx} = squeeze(mean(full_tab_topo.data{idx}(1:105, logical(int(5,:))), 2));
    full_tab_topo.top6{idx} = squeeze(mean(full_tab_topo.data{idx}(1:105, logical(int(6,:))), 2));
    full_tab_topo.top7{idx} = squeeze(mean(full_tab_topo.data{idx}(1:105, logical(int(7,:))), 2));
    full_tab_topo.top8{idx} = squeeze(mean(full_tab_topo.data{idx}(1:105, logical(int(8,:))), 2));

end

%new table save top
tab_topo_small = full_tab_topo;
tab_topo_small.data = [];

%% save 
cd(fullfile(prefix, 'methlab\Students\Oliver\script\base_corr\Topo'));
save tab_topo_small.mat tab_topo_small
%% find channels to show

noisy_chan = [1 8 14 17 21 25 32 48 49 56 63 68 73 81 88 94 99 107 113 119 125 126 127 128];
EEG.chanlocs(noisy_chan) = [];

chan = {EEG.chanlocs.labels};
E54 = ismember(chan, 'E54');
E55 = ismember(chan, 'E55');
E61 = ismember(chan, 'E61');
E62 = ismember(chan, 'E62');
E78 = ismember(chan, 'E78');
E79 = ismember(chan, 'E79');

channels = logical(E54 + E55 + E61 + E62 + E78 + E79);

%% create average of electrodes and save in full_tab for plots 

for i = 1 :size(full_tab,1)
     idx = find(full_tab.ID(i) == string(full_tab_topo.ID) & full_tab.StimulusNr(i) == full_tab_topo.StimuliNr);
     if ~isempty(idx)
         avgData = full_tab_topo.data{idx};
         avgData = mean(avgData(channels,:),1);
         full_tab.databaseline(i) = {avgData};
     end
end


%% save full_tab
cd(fullfile(prefix, 'methlab\Students\Oliver\script\nobase_corr\Mat_Files'));
save full_tab_a4.mat full_tab

%% topo for each age group

i1 = tab_topo_small.agegroup == 1;
i2 = tab_topo_small.agegroup == 2;
i3 = tab_topo_small.agegroup == 3;
i4 = tab_topo_small.agegroup == 4;
i5 = tab_topo_small.agegroup == 5;
i6 = tab_topo_small.agegroup == 6;
i7 = tab_topo_small.agegroup == 7;
%table for age groups 
tab1 = tab_topo_small(i1,:);
tab2 = tab_topo_small(i2,:);
tab3 = tab_topo_small(i3,:);
tab4 = tab_topo_small(i4,:);
tab5 = tab_topo_small(i5,:);
tab6 = tab_topo_small(i6,:);
tab7 = tab_topo_small(i7,:);

%% create mean of topo values 
meanTopoValue = table;
%first row all subjects, other rows are age groups

% all subjects, 8 time points
for i = 1: 8
    a = eval(['tab_topo_small.top' num2str(i)]);
    topoall = cat(3,a{:});
    meanTopoValue(1,i) = {mean(topoall,3)};
end

%age groups 
for i = 1: 7
    %time points
    for ii = 1:8
        test = eval(['tab' num2str(i) '.top' num2str(ii)]);
        topoall = cat(3,test{:});
        meanTopoValue(i+1,ii) = {mean(topoall,3)};
    end
end

%% plot 1: electrode selection
% 3 parts, and manually saved and later combined with inkscape

% 1st Part:  4 row: all + g1 g2 g3
age_n = ["All Ages" "Age: 5-7" "Age: 7-9" "Age: 9-11" "Age: 11-13" "Age: 13-15" "Age: 15-17" "Age:17-22"];
t = [150 200 250 300 350 400 450 500];

hfig = figure;
a = 1 %index for age
sub = 1; %index for subplot

for row = 1 : 4 
    for col = 1:9 % add first col for names 
        subplot(4,9,sub)

        % for naming row: delete plot with inkscape 
        if col == 1
            pl = plot(rand(1))
            pl.Visible = 'off';
            axis off
            title(age_n(a))
            a = a + 1
            sub = sub  + 1 
            continue
        end
        topoplot(cell2mat(meanTopoValue{row,col-1}), EEG.chanlocs,'maplimits', [-1.5 1.5]); %col -1 since first index is for names: topotable has only 8 index      
        hold on
        topoplot([],EEG.chanlocs(channels), 'style','blank','electrodes','pts');
        hold off
        % add title with times 
        if row == 1 
           title ([num2str(t(col-1)) '-' num2str(t(col-1)+50) 'ms'], 'fontsize', 15); %col -1 for correct index
        end   
           colormap(mycolormap);
         sub = sub + 1;  
    end
end

%get axis
h = axes(hfig,'visible','off'); 
%h.XLabel.Visible = 'on';
%h.YLabel.Visible = 'on';
%ylabel(h,'yaxis','FontWeight','bold');
%xlabel(h,'xaxis','FontWeight','bold');
%h.Title.Visible = 'on';
%title(h,'Topoplot: Electrode Selection');

c = colorbar(h,'Position',[0.93 0.168 0.022 0.7])

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',16) % adjust fontsize to your document
sgt.FontSize = 20;
set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
set(gcf,'color','w');



%% 2 Part row: all + g4 g5
t = [150 200 250 300 350 400 450 500]

hfig = figure;
all = 1
a = 5 %index for age
sub = 1; %index for subplot

for row = 4 : 6 %3 is for all stimuli 
    for col = 1:9 %add first col for names 
        subplot(3,9,sub)
        if row == 4 
            a = 1;
            row = 1;
        else
            a = row;
        end

        % for naming row: delete plot with inkscape 
        if col == 1
            pl = plot(rand(1))
            pl.Visible = 'off';
            axis off
            title(age_n(row))
            all = all + 1;
            sub = sub  + 1 
            continue
        end

       
        topoplot(cell2mat(meanTopoValue{row,col-1}), EEG.chanlocs,'maplimits', [-1.5 1.5]); %col -1 since first index is for names: topotable has only 8 index      
        hold on
        topoplot([],EEG.chanlocs(channels), 'style','blank','electrodes','pts');
        hold off
        % add title with times 
        if row == 1 
           title ([num2str(t(col-1)) '-' num2str(t(col-1)+50) 'ms'], 'fontsize', 15); %col -1 for correct index
        end   
           colormap(mycolormap);
         sub = sub + 1;  
    end
end

%get axis
h = axes(hfig,'visible','off'); 
%h.XLabel.Visible = 'on';
%h.YLabel.Visible = 'on';
%ylabel(h,'yaxis','FontWeight','bold');
%xlabel(h,'xaxis','FontWeight','bold');
%h.Title.Visible = 'on';
%title(h,'Topoplot: Electrode Selection');

c = colorbar(h,'Position',[0.93 0.168 0.022 0.7])

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',16) % adjust fontsize to your document
sgt.FontSize = 20;
set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
set(gcf,'color','w');
%% 3 Part row: all + g6 g7
t = [150 200 250 300 350 400 450 500]

hfig = figure;
sub = 1; %index for subplot

for row = 6 : 8  %5 is for all stimuli 
    for col = 1:9 %add first col for names 
        subplot(3,9,sub)
        if row == 6 
            a = 1;
            row = 1;
        else
            a = row;
        end

        % for naming row: delete plot with inkscape 
        if col == 1
           pl = plot(rand(1))
            pl.Visible = 'off';
            title(age_n(row))
            axis off
            all = all + 1;
            sub = sub  + 1;
            continue
        end

       
        topoplot(cell2mat(meanTopoValue{row,col-1}), EEG.chanlocs,'maplimits', [-1.5 1.5]); %col -1 since first index is for names: topotable has only 8 index      
        hold on
        topoplot([],EEG.chanlocs(channels), 'style','blank','electrodes','pts');
        hold off
        % add title with times 
        if row == 1 
           title ([num2str(t(col-1)) '-' num2str(t(col-1)+50) 'ms'], 'fontsize', 15); %col -1 for correct index
        end   
           colormap(mycolormap);
         sub = sub + 1;  
    end
end

%get axis
h = axes(hfig,'visible','off'); 
%h.XLabel.Visible = 'on';
%h.YLabel.Visible = 'on';
%ylabel(h,'yaxis','FontWeight','bold');
%xlabel(h,'xaxis','FontWeight','bold');
%h.Title.Visible = 'on';
%title(h,'Topoplot: Electrode Selection');

c = colorbar(h,'Position',[0.93 0.168 0.022 0.7])

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',16) % adjust fontsize to your document
sgt.FontSize = 20;
set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
set(gcf,'color','w');


%% second plot: learning categories for four age groups


%select peak latency from truePeakMs: group 1,2,4,6
t =[454,422,400,398];
int = [];
for i = 1:size(t, 2)

    % +100 weil in topo tabelle 450 sample point mit -100:800 
    int(i, :) = EEG.times >= t(i)+50 & EEG.times <= t(i) + 150;
    
end


% for each table create tab for learning categories 
% categories
full_tab_topo.Category = ordinal(full_tab_topo.Category);
% 1 = NL, 2 = UN, 3 = K, 4 = F
getlabels(full_tab_topo.Category)
full_tab_topo.Category = setlabels(full_tab_topo.Category ,{'NL', 'UN', 'K', 'F'});
full_tab_topo.Category = categorical(full_tab_topo.Category);

% create cell array (dat) with rows = stimuli, col = four age groups
learningcategories = ["UN", "NL","K"];
groups = [1,2,4,6];
for g = 1 :4
    for ls = 1:3

    i = full_tab_topo.agegroup == groups(g) & full_tab_topo.Category == learningcategories(ls);
    t = cat(3,full_tab_topo.data{i});
    t = mean(t,3);
    dat{ls,g} = mean(t(:,logical(int(g,:))),2);

    end
end

% plot 2: learning categories for four age groups
hfig = figure
age = ["Age: 5-7" "Age: 7-9"  "Age: 11-13"  "Age: 15-17"];
titles = ["Unknown", "Newly Learned", "Known"];
time =[454,422,400,398];
counter = 1;
for g = 1: 4
    for ls = 1:3
        subplot(4,3,counter)
        
        topoplot(cell2mat(dat(ls,g)), EEG.chanlocs,'maplimits', [-1.5 1.5]); %col -1 since first index is for names: topotable has only 8 index      
        hold on
        topoplot([],EEG.chanlocs(channels), 'style','blank','electrodes','pts');
        hold off
        if g == 1 
            p(ls) = title(titles{ls});
        end
        if ls == 1 
           o(g) = subtitle([age{g} ' (' num2str(time(g)) ' +/- 50 ms)']); 
        end  
        counter = counter + 1;
    end
end
colormap(mycolormap);
picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio

sgt.FontSize = 20;
set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')

set(findall(hfig,'-property','FontSize'),'FontSize',16) % adjust fontsize to your document
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
for i = 1 : 4
    o(i).FontSize = 12
end

set(gcf,'color','w');

