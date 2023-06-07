# ------------------------------------------------------------------------
# ---------- P3_beta (Network Analysis) + Diagnosis ----------------------
#----------  Table creating for Network Analysis -------------------------
# ------------------------------------------------------------------------

#load packages
library(dplyr)
library(ggplot2)
library(stringr)


# ------------------------------------------------------------------------
# ---------- load data  --------------------------------------------------
# ------------------------------------------------------------------------

#change to correct prefix 
#prefix <- "\\\\psyger-stor02.d.uzh.ch\\"


dat <- read.csv(file.path(prefix, "methlab","Students","Oliver","script","Final Scripts R","Data","full_t.csv"))


# ------------------------------------------------------------------------
# ---------- Create P3_beta& Mean KI for Network Analysis ----------------
# ------------------------------------------------------------------------

id <- unique(dat[,1])

p3_beta = c()
meanKI = c()
for (i in 1:length(id)){
  
  out <- dat %>% filter(grepl(id[i], ID)) #creates sub table for subject i
  mod1 <- lm(P300 ~ as.numeric(BlockNr), data = out)  
  # plot(P300 ~ BlockNr, data = out)
  # lines(out$BlockNr,predict(mod1))

  sum_mod <- summary(mod1)
  p3_beta =c(p3_beta,sum_mod$coefficients[2])  
  
  meanKI = c(meanKI,mean(out$KI,na.rm = T))
}
  


# ------------------------------------------------------------------
# ---------- Diagnosis  --------------------------------------------
# ------------------------------------------------------------------

BD <- read.csv(file.path(prefix, "methlab","Students","Oliver","BD.csv"))

#only subs that are in final sample size 
i <- match(id,BD$EID)
subtable <- BD[i,]

#select all relevant cols for Diagnosis
BD_dia <- subtable%>% select(starts_with("DX")& ends_with("Cat"),ends_with("sub"),starts_with("age"),starts_with("EID"))

#same order of ID?
i <- BD_dia$EID == id
which(i == FALSE)








#create empty df
n <- c("ADHD", "Depression" ,"ASD", "SLD", "CommD","Anxiety", 
       "Disruptive, Impulsive", "Other", "No Dia", "DX01")

df <- data.frame(matrix(ncol = 10, nrow = 1594))
colnames(df) <- n


#find names of diagnosis
table(BD_dia[,1]) #DX01
table(BD_dia[,11]) #DX01_sub




# ---------- vector for strings compare------------------------------

#No Dia, Anxiety, Depression, Disruptive can be found in "BD_dia$Cat" for other BD_dia$Cat_sub is needed

n_dia <- c("Depressive Disorders", "Anxiety Disorders", "Disruptive, Impulse Control and Conduct Disorders",
            "No Diagnosis Given","Neurodevelopmental Disorders")

#if Neurodevelopmental Disorders: group different sub diagnosis, adhd and specific learning disorders 
neuro <- c("Attention-Deficit/Hyperactivity Disorder",
           "Specific Learning Disorder",
           "Autism Spectrum Disorder")


# compare whether diagnosis found for each individual and add to df (Cat)

for (i in 1:1594){
  m <- match(BD_dia[i,1:10],n_dia) #compare if any strings from BD_dia (only categories) in diagnosis vector 
  
  #go through individual cases:
  
  #no diagnose = 4
  if(4 %in% m){
    df$`No Dia`[i] = 1
    next }

  #neurodevelopmental = 5
  if(5 %in% m){
    #which position in m (corresponds to DX01, DX02,...)
    j <- which(m==5)
    #sub can have multiple neurodevelopmental disorders
    for(ii in 1:length(j)){
      #add 10 to j for sub: DX01 (1) -> DX01_sub(11)
      neuroidx <- match(BD_dia[i,j[ii]+10],neuro)
      
      if(is.na(neuroidx)){
        df$Other[i] = 1
        next #if == can't handle na that why this comes condition comes first
      }
      if(neuroidx == 1){
        df$ADHD[i] = 1
      }
      if(neuroidx == 2){
        df$SLD[i] = 1
      }
      if(neuroidx == 3){
        df$ASD[i] = 1
      }
      }
    }
    
  #Depression = 1
  if(1 %in% m){
    df$Depression[i] = 1
  }

  #Anxiety = 2
  if(2 %in% m){
    df$Anxiety[i] = 1
  }
  #Disrupt = 3
  if(3 %in% m){
    df$`Disruptive, Impulsive`[i] = 1
  }
  #assumption everyone without NO Diagnosis has a diagnosis.
  #Since loop goes to next with subjects with no diagnosis 
  # If not diagnosis 1,2,3,5 then match is na
  #Other diagnosis
  if(all(is.na(m))){
    df$Other[i] = 1
  }
}
# ---------- First DX01------------------------------

#DX01 as categories
df$DX01 <- BD_dia$DX_01_Cat

#three conditions: Neurodevelopment, Not part of string vector n_dia, no Diagnosis

for (i in 1:1594){
  if(is.na(df$DX01[i])){
    next
  }
  #no diagnosis
  if(df$DX01[i] == "No Diagnosis Given"){
    next
  }
  
  #neurodevelopment
  if(df$DX01[i] == "Neurodevelopmental Disorders"){
    
    #check DX01_sub and add as DX01 if in neuro else other
    if(BD_dia$DX_01_Sub[i] %in% neuro){
      j <- which(BD_dia$DX_01_Sub[i] %in% neuro)
      df$DX01[i] = neuro[j]
    }else{
       df$DX01[i] = "Other"
     }
  next }
  #Other Diagnosis
  if(!df$DX01[i]%in% n_dia){
    df$DX01[i] = "Other"  }
}




# ------------------------------------------------------------------
# ---------- Add to table  -----------------------------------------
# ------------------------------------------------------------------
#creates vector that shows which row is for which id
idx <- with(dat, match(dat$ID, unique(dat$ID)))



df2 <- data.frame()
#repeat rows of df based on idx
for (i in 1:1594){
  df2 <- rbind(df2,df[rep(i, length(which(idx == i))),])
}


#add to table

dat <- cbind(dat,df2)




# ------------------------------------------------------------------
# ---------- Add comorbidity   -------------------------------------
# ------------------------------------------------------------------


#create tab with unique for id

full_unique <- dat %>% distinct(ID, .keep_all = TRUE)


#add how many diagnosis (comorbidity)
CountDia <- c()
for (i in 1:1594){
  CountDia[i] <- sum(full_unique[i,19:26], na.rm = T)
}
full_unique[,ncol(full_unique) + 1] <-  CountDia


# ------------------------------------------------------------------
# ---------- Add mean KI, P3Beta for Network Analysis   ------------
# ------------------------------------------------------------------

full_unique[,ncol(full_unique) + 1] <- p3_beta
full_unique[,ncol(full_unique) + 1] <- meanKI
names(full_unique)[29] <- "Comorbidity"
names(full_unique)[30] <- "P3_beta"
names(full_unique)[31] <- "meanKI"

setwd(file.path(prefix, "methlab","Students","Oliver","script","Final Scripts R","Data"))

save(full_unique,file = "full_unique.Rda")
save(dat,file="dat.Rda")

#save BD file with only subjects in analysis (1594)
save(subtable,file = "BD_sub.Rda")
