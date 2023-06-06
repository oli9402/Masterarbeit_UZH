# Script 1: a1_preprocessing (Preprocessing and Generating Table)
In this script, four long format tables are generated. Each row is a single trial of a given subject. EEG is preprocessed and epoch for each trial is created. Computing this script takes long and is executed with cloud computer. If executed locally, file path should be adjusted accordingly (i.e., local = '...'). Code for ET data was not included since it wasn't used in the final thesis. 

## Output
Four Tables (light/full x baseline/no baseline):
- light = containing only six relevant (for P300) electrodes. (linear mixed-effects model)
- full  =  containing all 105 electrodes. (Topoplots)

Reject Mat file containing information about how many trials have artifacts for each subject
Tables are saved in "\\psyger-stor02.d.uzh.ch\methlab\Students\Oliver\script"
# Script 2: a2_0_demo_exclusion (Add Demographics and exclusion)
Input is light table with no baseline generated in the first script (a1_pre). 
Output is a final table in which subjects were excluded and demographics (age, gender), agegroup, Knowledge and Learning Index, performance group were added.
Diagnosis are added in with R.
Steps: 
- Variables are renamed 
- Age groups are created (]x:x+2])
- Learning Categories are named 
- mean baseline values added (-100:0)
- subjects with many artifacts (< 50%)  and/or no demographics in BD.csv are indexed for later exclusion
- Knoweledge Index and Learning Index are calculated

## Output
Tables are saved in "\\psyger-stor02.d.uzh.ch\methlab\Students\Oliver\script\nobase_corr\Mat_Files" 

# Script 3: a3_P300
- In this script mean P300 for each trial is calculated using a time window of max peak +/- 50 ms.
- For each age group an individual time window is calculated based on group average ERP waveform. 

## Output
P300 variable is added to table generated in a2_0_demo_exclusion and saved as full_table_a3 in "\\psyger-stor02.d.uzh.ch\methlab\Students\Oliver\script\nobase_corr\Mat_Files"
Second, a mat file with peaks latency of each group is saved truePeakMs.mat 

# Script 4: a4_topo
In this script, baseline corrected data set is used to create topoplots and average of six relevant electrodes for later plots.
Figures are created:
- electrode selection figure
- learning categories figure

## Output
- light version table for topoplots 
- full_tab with additional baseline corrected data for later plots 
- topoplots for thesis 
