# Main Script: b0_main
This script calls all other scripts

# Script 1: b1_p3_beta

In this script variables P3_beta and Mean KI is constructed for each subject. Furthermore, diagnosis are extracted and included in tables

### Output
- Full table with Diagnosis
- Wide format table where each subject has one row with P3_beta and mean KI for Network Analysis

# Script 2: b2_mm 
Linear Mixed-Effects Models, and descriptive statistics for tables. Uses data frame dat.Rda created in b1_p3_beta 
Furthermore, mean P300 for every repetition is created for the linear mixed-effects model decrease of mean P300 over repetitions.
Relevant information for tables are extracted manually. 

# Script 3: b3_network
Finally, this script performs a network analysis using ggmModSelect. 
