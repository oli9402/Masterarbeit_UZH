# ------------------------------------------------------------------------
# ---------- Main script  ------------------------------------------------
# ------------------------------------------------------------------------
#this script calls all other scripts 


#change to correct prefix 
prefix <- "\\\\psyger-stor02.d.uzh.ch\\"

#which scripts to execute?

selectScript <- c(0,1,0)

#Diagnosis, P3_beta, MeanKI
if (selectScript[1] == 1){
  source("b1_p3_beta.r")
}

#Linear Mixed-Effects Models
if (selectScript[2] == 1){
  source("b2_mm.r")
}

#Network Analysis
if (selectScript[3] == 1){
  source("b3_network.r")
}