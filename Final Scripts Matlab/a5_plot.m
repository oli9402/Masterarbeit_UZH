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

%% load data 
load(fullfile(prefix, 'methlab\Students\Oliver\script\nobase_corr\Mat_Files\full_tab_a4.mat'));
load(fullfile(prefix, 'methlab_data\HBN\EEG-ET_Joelle_MA_results\NDARAA075AMK\gip_vis_learn_EEG.mat'));
%% load packages

addpath(fullfile(prefix, 'methlab\Students\Oliver\BrewerMap-master'));


%plot 1 = meanKI over repetitions for age groups (not all if to much)
%plot 2 = ERP Learning states age groups
%plot 3 = ERP over repetitions

%% Plot behavioral
% 1. Avg. KI/LI over repetitions

%% Plot neurophysiological
% 2. Amplitude decrease over repetition
% 3. ERP over repetition
% 4. ERP different learning categories

%% Plot 1  KI/LI over rep
%creat data
for group = 1 : 7
    for rep = 1 : 5 
        i = full_tab.agegroup == group & full_tab.BlockNr == rep;
        meanKI(group,rep) = mean(full_tab.KI(i),'omitnan');
        stderrK(group,rep) = std(full_tab.KI(i),'omitnan')/sqrt(length(find((~isnan(full_tab.KI(i))))));
    end
end

%li

%creat data
for group = 1 : 7
    for rep = 1 : 5 
        i = full_tab.agegroup == group & full_tab.BlockNr == rep;
        meanLI(group,rep) = mean(full_tab.LI(i),'omitnan');
        stderr(group,rep) = std(full_tab.LI(i),'omitnan')/sqrt(length(find((~isnan(full_tab.LI(i))))));
    end
end
% plot data 
cb = colormap(brewermap(8,'RdBu'));

hfig = figure;

subplot(1,2,1)
hold on
for i = 7:-1:1 
errorbar(1:5, meanKI(i,:),stderrK(i,:),'color', cb(9-i,:),'LineWidth',2)
end
ylim([0 1])
ylabel("Average Knowledge Index")
xlabel('Repetition')
xlim([0 6])
xticks([1:5])
yticks([0.2,0.4,0.6,0.8,1])
title("Knowledge Index over Repetitions")

subplot(1,2,2)
hold on
for i = 7:-1:1 
errorbar(1:5, meanLI(i,:),stderr(i,:),'color', cb(9-i,:),'LineWidth',2)
end

lg = legend('Age: 17-22 (n = 92)', 'Age: 15-17 (n = 130)','Age: 13-15 (n = 170)','Age: 11-13 (n = 260)','Age: 9-11   (n = 366)','Age: 7-9   (n = 390)','Age: 5-7   (n = 191)')

ylim([0 1])
ylabel("Average Learning Index")
xlabel('Repetition')
xlim([0 6])
xticks([1:5])
yticks([0.2,0.4,0.6,0.8,1])
title(" Learning Index over Repetitions")
picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',20) % adjust fontsize to your document
lg.FontSize = 14
set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
set(gcf,'color','w');




%% plot 2 meanP300 repetition decrease age


%creat data
for group = 1 : 7
    for rep = 1 : 5 
        i = full_tab.agegroup == group & full_tab.BlockNr == rep;
        meanP300(group,rep) = mean(full_tab.P300(i),'omitnan');
        stderrP300(group,rep) = std(full_tab.P300(i),'omitnan')/sqrt(length(find((~isnan(full_tab.P300(i))))));
    end
end

% plot data 
cb = colormap(brewermap(8,'RdBu'));

hfig = figure;
hold on

for i = 7:-1:1 
errorbar(1:5, meanP300(i,:), stderrP300(i,:),'color', cb(9-i,:),'LineWidth',2)
end


lg = legend('Age: 17-22 (n = 92)', 'Age: 15-17 (n = 130)','Age: 13-15 (n = 170)','Age: 11-13 (n = 260)','Age: 9-11   (n = 366)','Age: 7-9   (n = 390)','Age: 5-7   (n = 191)')

ylabel("Amplitude [uV]")
xlabel('Repetition')
xlim([0 6])
ylim([0.4 1.8])
xticks([1:5])
title("Mean P300 Amplitude over Repetition")
picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',20) % adjust fontsize to your document
lg.FontSize = 14
set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
set(gcf,'color','w');



%% Plot 3 subplots repetition erp age

%creat data
titles = ["Age: 5-7 ","Age: 7-9 ","Age: 11-13 ","Age: 15-17"];

groups = [1,2,4,6];

for g = 1 : length(groups)
    for rep = 1 : 5
            i = full_tab.agegroup == groups(g) &  full_tab.BlockNr == rep;
            erp{1,g,rep} = mean(cat(3,full_tab.databaseline{i}),3);
            
    end
end


% plot 
cb = colormap(brewermap(5,'Reds'));

x = linspace(-0.1 ,0.8, 450)*1000;
hfig = figure;
hold on
for g = 1 : 4
    subplot(1,4,g)
    
    for rep = 1:5
        hold on
        plot(x,erp{1,g,rep},'color', cb(6-rep,:),'LineWidth',2)
    end
    title(titles(g))
    xlim([-100 800])

    if g == 1 
        ylabel("Amplitude [uV]")
    end
    ylim([-0.8 2.7])
    yticks([-0.5,0,0.5,1,1.5,2,2.5])
    
         xlabel("Time [ms]")

end

lg = legend('Repetition 1','Repetition 2','Repetition 3','Repetition 4', 'Repetition 5')


picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',15) % adjust fontsize to your document
lg.FontSize = 13
set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
set(gcf,'color','w');

%% Plot 4 Learning Categories ERP


%creat data
titles = ["Age: 5-7 ","Age: 7-9 ","Age: 11-13 ","Age: 15-17"];
LS = ["UN", "NL", "K"];
groups = [1,2,4,6];

for g = 1 : length(groups)
    for learn = 1 : 3
            i = full_tab.agegroup == groups(g) &  full_tab.Category == LS(learn);
            erp{1,g,rep} = mean(cat(3,full_tab.databaseline{i}),3);
            
    end
end

% plot 
cb = colormap(brewermap(3,'Reds'));

x = linspace(-0.1 ,0.8, 450)*1000;
hfig = figure;
hold on
for g = 1 : 4
    subplot(1,4,g)
    
    for learn = 1:3
        hold on
        plot(x,erp{1,g,learn},'color', cb(4-learn,:),'LineWidth',2)
    end
    title(titles(g))
    xlim([-100 800])

    if g == 1 
        ylabel("Amplitude [uV]")
    end
    ylim([-0.8 2.7])
    yticks([-0.5,0,0.5,1,1.5,2,2.5])
    
         xlabel("Time [ms]")

end

lg = legend('Unknown','Newly Learned','Known')

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',15) % adjust fontsize to your document
lg.FontSize = 13
set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
set(gcf,'color','w');
