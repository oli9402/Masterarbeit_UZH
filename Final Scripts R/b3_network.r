# ------------------------------------------------------------------
# ---------- Network Analysis   ------------------------------------
# ------------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(tibble)
library(stringr)

#network analysis
library(huge)
library(mgm)
library(psychonetrics)
library(qgraph)
library(bootnet)
library(glasso)




#------------------------------------------------------------------
# ---------- Load Data    -----------------------------------------
# ------------------------------------------------------------------

#change to correct prefix 
#prefix <- "\\\\psyger-stor02.d.uzh.ch\\"

load(file.path(prefix, "methlab","Students","Oliver","script","Final Scripts R","Data","full_unique.Rda"))

#BD for questionnaires
load(file.path(prefix, "methlab","Students","Oliver","script","Final Scripts R","Data","BD_sub.Rda"))

BD <- subtable
#same order? -> yes
all(full_unique$ID == BD$EID)


# ------------------------------------------------------------------
# ---- Create Subscale Emotional Dysregulation + Select nodes------- 
# ------------------------------------------------------------------

ED <- BD%>% select(starts_with("CBCL.CBCL_AD_T"), 
                   starts_with("CBCL.CBCL_AP_T"),
                   starts_with("CBCL.CBCL_AB_T")) %>% rowSums()

CB <- BD%>% select("CBCL.CBCL_WD_T", "CBCL.CBCL_TP_T")
  
PS <- BD%>% select("WISC.WISC_PSI_Sum")
WM <- BD%>% select("WISC.WISC_WMI_Sum")



LP <- BD%>% select(starts_with("C3SR.C3SR_LP_T"))
SM <- BD%>% select("SRS.SRS_MOT_T","SRS.SRS_SCI_T")

BD_swan <- BD%>% select(starts_with("swan.swan_in"))

#create df with all revelant data
dat_net <- cbind(ED,CB,WM,PS,LP,full_unique$age,full_unique$meanKI,full_unique$P3_beta,SM,BD_swan)


#correlation matrix
cor(dat_net$`full_unique$meanKI`,dat_net$`full_unique$P3_beta`)
t <- as.data.frame(round(cor(dat_net,use="pairwise.complete.obs"),2))

# ------------------------------------------------------------------
# ---------- Distribution Plot   -----------------------------------
# ------------------------------------------------------------------

library(cowplot)
p1 <- ggplot(dat_net, aes(ED)) + 
  geom_histogram(bins=100)
p2 <- ggplot(dat_net, aes(CBCL.CBCL_WD_T)) + 
  geom_histogram(bins=100)
p3 <- ggplot(dat_net, aes(CBCL.CBCL_TP_T)) + 
  geom_histogram(bins=100)
p4 <- ggplot(dat_net, aes(WISC.WISC_WMI_Sum)) + 
  geom_histogram(bins=100)
p5 <- ggplot(dat_net, aes(WISC.WISC_PSI_Sum)) + 
  geom_histogram(bins=100)
p6 <- ggplot(dat_net, aes(C3SR.C3SR_LP_T)) + 
  geom_histogram(bins=100)
p7 <- ggplot(dat_net, aes(full_unique$age)) + 
  geom_histogram(bins=100)
p8 <- ggplot(dat_net, aes(full_unique$meanKI)) + 
  geom_histogram(bins=100)
p9 <- ggplot(dat_net, aes(full_unique$P3_beta)) + 
  geom_histogram(bins=100)
p10 <- ggplot(dat_net, aes(SRS.SRS_MOT_T)) + 
  geom_histogram(bins=100)
p11 <- ggplot(dat_net, aes(SRS.SRS_SCI_T)) + 
  geom_histogram(bins=100)
p12 <- ggplot(dat_net, aes(SWAN.SWAN_IN)) + 
  geom_histogram(bins=100)


plot_grid(p1, p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12)


# ------------------------------------------------------------------
# ---------- transformation CBCL nodes   ---------------------------
# ------------------------------------------------------------------
library(tidyr)
library(huge)

#before transformation NA should be dropped
dat_net <- dat_net %>% drop_na(ED,CBCL.CBCL_WD_T,CBCL.CBCL_TP_T)

dat_net_2 <- huge.npn(dat_net[1:3])
dat_net_2 <-as.data.frame(dat_net_2) 
dat_net_3 <- cbind(dat_net_2, dat_net[4:12])

# ------------------------------------------------------------------
# ---------- Plot after trans   ---------------------------------------------
# ------------------------------------------------------------------

p1.5 <- ggplot(dat_net_3, aes(ED)) + 
  geom_histogram(bins=100)
p2.5 <- ggplot(dat_net_3, aes(CBCL.CBCL_WD_T)) + 
  geom_histogram(bins=100)
p3.5 <- ggplot(dat_net_3, aes(CBCL.CBCL_TP_T)) + 
  geom_histogram(bins=100)


plot_grid(nrow = 2, ncol = 3, p1, p2,p3, p1.5,p2.5,p3.5, labels = c('A', '','','B','',''))


# ------------------------------------------------------------------
# ---------- Renaming final df   -----------------------------------
# ------------------------------------------------------------------
dat_net <- dat_net_3

names(dat_net) <- c("V1","V2","V3","V4","V5","V6","V7","V8","V9","V10","V11","V12")

Quest <- c(rep("Child Behavior Checklist",times = 3),rep("WISC-V",times = 2),rep("Conners 3 SR",times = 1),
           rep("Demographics",times=1),rep("Sequence Learning Paradigm", times = 2),rep(" Social Responsiveness Scale",times = 2),
           rep("SWAN",times = 1))

Names <- c("Emotional Dysregulation","Withdrawn/Depressed","Thought Problems","Working Memory Index", "Processing Speed Index ",
           "Learning Problems", "Age" ,
           "Mean Knowledge Index", "P300 Beta" , "Social Motivation Problems" ,"Social Cognition", "Inattention")


# ------------------------------------------------------------------
# ---------- Network estimation   ----------------------------------
# ------------------------------------------------------------------




results <- estimateNetwork(dat_net, default = "ggmModSelect", corMethod = "cor_auto")




pie_t <- centrality(results,R2=T)
plot(results,layout = "spring", cut=0,
     palette = "colorblind",vsize=5,edge.labels = F,
     label.cex=1.5, legend.cex=.6, GLratio = 1.5,
     groups = Quest,
     nodeNames = Names,
     nodeNames.font = 10,
     pie = pie_t$R2,pieBorder = 0.25)


centralityPlot(results,include=c("Strength", "Closeness", "Betweenness"), scale
               = "raw")
pie_t$R2

summary(results)
results$graph

# ------------------------------------------------------------------
# ---------- Bootstrapping -----------------------------------------
# ------------------------------------------------------------------

#estimated confidence intervals for edge strength (takes long)
boot1 <- bootnet(results, nBoots = 1000, nCores = 4)

#output
print(boot1)
summary(boot1)
plot(boot1)

#confidence intervalls
s <- boot1$bootTable
v8 <- s[s$id=="V8--V9",]$value
v4 <- s[s$id=="V4--V9",]$value
ci <- quantile(v8, c(0.025, 0.975))
ci <- quantile(v4, c(0.025, 0.975))

v12 <- s[s$id=="V8--V12",]$value
ci <- quantile(v12, c(0.025, 0.975))

hist(v4)


