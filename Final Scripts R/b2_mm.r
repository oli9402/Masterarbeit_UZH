#------------------------------------------------------------------
# ----------Statistical Analysis -----------------------------------
# ------------------------------------------------------------------


#load packages
library(tidyverse)
library(lme4)
library(psych)
library(lmerTest) #p values lmer
library(ggplot2)
#for allfit
library(optimx)
library(dfoptim)
# transformation
library(scales)
library(data.table)
options(scipen=999)
library(magrittr)
library(dplyr)#for %>% select
#print md 
library(parameters)
# lmer html table
library(sjPlot)
library(sjmisc)
library(sjlabelled)
#contrasts
library(emmeans)

library(effectsize)

#------------------------------------------------------------------
# ---------- Load Data    -----------------------------------------
# ------------------------------------------------------------------

#change to correct prefix 
#prefix <- "\\\\psyger-stor02.d.uzh.ch\\"

load(file.path(prefix, "methlab","Students","Oliver","script","Final Scripts R","Data","dat.Rda"))




#-------------------------------------------------------------------
# ---------- Percentage learning categories for tables -------------
# ------------------------------------------------------------------
collapsed_data <- dat %>%
  group_by(ID) %>%
  summarise(Count_UN = sum(Category == "UN"), 
            Percentage_UN = sum(Category == "UN") / n() * 100,
            Count_NL = sum(Category == "NL"), 
            Percentage_NL = sum(Category == "NL") / n() * 100,
            Count_K = sum(Category == "K"), 
            Percentage_K = sum(Category == "K") / n() * 100,
            Count_F = sum(Category == "F"), 
            Percentage_F = sum(Category == "F") / n() * 100,
            SL  = unique(SeqL))

#By Sequence Length
mean_sd <- collapsed_data %>% group_by(SL) %>% summarise(meanUN = mean(Count_UN),
                                                         sdUN = sd(Count_UN),
                                                         perUN = mean(Percentage_UN),
                                                         meanNL = mean(Count_NL),
                                                         sdNL = sd(Count_NL),
                                                         perNL = mean(Percentage_NL),
                                                         meanK = mean(Count_K),
                                                         sdK = sd(Count_K),
                                                         perK = mean(Percentage_K),
                                                         meanF = mean(Count_F),
                                                         sdF = sd(Count_F),
                                                         perF = mean(Percentage_F)) 
#total
mean_sd_t <- collapsed_data %>% summarise(meanUN = mean(Count_UN),
                                                         sdUN = sd(Count_UN),
                                                         meanNL = mean(Count_NL),
                                                         perUN = mean(Percentage_UN),
                                                         sdNL = sd(Count_NL),
                                                         perNL = mean(Percentage_NL),
                                                         meanK = mean(Count_K),
                                                         sdK = sd(Count_K),
                                                         perK = mean(Percentage_K),
                                                         meanF = mean(Count_F),
                                                         sdF = sd(Count_F),
                                                         perF = mean(Percentage_F)) 

#-------------------------------------------------------------------
# ---------- Make zero meaningful (centering)   -------------------
# ------------------------------------------------------------------

#BlockNr - 1 so that 0 is first block
dat$BlockNr <- dat$BlockNr - 1

#Grand -mean Centering Age 
dat$age <- center(dat$age)


#group mean centering
#dat <- dat %>%
  #add_rownames()%>% #if the rownames are needed as a column
  #group_by(SeqL) %>% 
  #mutate(cent= age-mean(age))


#-------------------------------------------------------------------
# ---------- as Cat + Rereference   --------------------------------
# ------------------------------------------------------------------



dat$ID = as.factor(dat$ID)
dat$SeqL = as.factor(dat$SeqL)
dat$BlockNr = as.numeric(dat$BlockNr)
dat$Category = as.factor(dat$Category)
dat$gender = as.factor(dat$gender)

#relevel
dat$Category = relevel(dat$Category, "NL")
dat$SeqL = relevel(dat$SeqL, '10')
dat$gender = relevel(dat$gender,"M")


#-------------------------------------------------------------------
# ---------- Knowledge Index  --------------------------------------
# ------------------------------------------------------------------
names(dat)[names(dat) == 'BlockNr'] <- 'Repetition'
names(dat)[names(dat) == 'age'] <- 'Age'
names(dat)[names(dat) == 'gender'] <- 'Gender'


k <- lmer(KI~ Repetition*Age*SeqL +(1+Repetition|ID), data = dat)

s <- step(k)
m_final <- get_model(s)
res = summary(m_final)
res[["coefficients"]]
tab_model(m_final,digits = 3, show.re.var = T)
logLik(m_final)
options(scipen = 0)
summary(m_final)



#-------------------------------------------------------------------
# -------how many negative slopes estimated? -----------------------
# ------------------------------------------------------------------
#how many negative slopes were estimated?
tt <- ranef(m_final)$ID
nslopes <- tt %>% filter(Repetition < 0)



#-------------------------------------------------------------------
# ---------- Learning Index  --------------------------------------
# ------------------------------------------------------------------



k <- lmer(LI~ Repetition*Age*SeqL +(1+Repetition|ID), data = dat)

s <- step(k)
m_final <- get_model(s)
res = summary(m_final)
res[["coefficients"]]
tab_model(m_final,digits = 3, show.re.var = T)
logLik(m_final)
options(scipen = 0)
summary(m_final)


#-------------------------------------------------------------------
# ---------- P300 BlockNr ------------------------------------------
# ------------------------------------------------------------------



#creat mP300 for every block in subject 
meanP300 = c()
meanBase = c()
id <- unique(dat$ID)

for (j in 1:length(id)){
  for (l in 0:4){
    i <- dat$ID == id[j] & dat$Repetition == l
    d <- mean(dat$P300[i],na.rm = T)
    o <- mean(dat$mbase[i],na.rm = T)
    meanP300[i] <- d
    meanBase[i] <- o
  }
}

dat <- cbind(dat,meanP300,meanBase)

## p300
p <- lmer(meanP300~ Repetition*Age*Gender*SeqL+meanBase+(1|ID), data = dat)
s <- step(p)
m_final <- get_model(s)
summary(m_final)
tab_model(m_final,digits = 3)
logLik(m_final)



#-------------------------------------------------------------------
# ---------- mP300 KI ----------------------------------------------
# ------------------------------------------------------------------


# mixed models
p <- lmer(KI ~ meanP300*Age*Gender+meanBase + (1|ID), data = dat)
s <- step(p)
m_final <- get_model(s)
summary(m_final)
tab_model(m_final,digits = 3)


#-------------------------------------------------------------------
# ---------- P300 Category -----------------------------------------
# ------------------------------------------------------------------
names(dat)[names(dat) == 'Category'] <- 'LearningCategories'


p <- lmer(P300~ LearningCategories*Age*Gender+mbase+(1|ID), data = dat)
s <- step(p)
m_final <- get_model(s)

res = summary(m_final)

res[["coefficients"]]
tab_model(m_final,digits = 3)
logLik(m_final)

res
em <- emmeans(m_final, c("LearningCategories"),pbkrtest.limit = 58194)
emmip(em, ~LearningCategories,pbkrtest.limit = 58194)
contrast(em)
res = summary(pairs(em, adjust = 'none'))
options(scipen=0) 
summary(pairs(em))
res$p.value # exact p-values
res['p_corr'] = res$p.value * 6  # bonferroni
eff_size(em, sigma = sigma(m_final), edf = nrow(dat))
plot(em, comparisons = TRUE, ylab = '', xlab = 'P300 amplitude')
res['CI_low'] = res['estimate'] - res['SE'] * 1.96
res['CI_high'] = res['estimate'] + res['SE'] * 1.96






#------------------------------------------------
#-------------- assumptions----------------------
#------------------------------------------------

#mod1 <- m_final
#preds <- predict(mod1)

#assuTdat <- data.frame("ID" = names(preds),
#                       "preds"= preds,
#                       "rez" = scale(residuals(mod1)))

# random effects will have a different dimension, so we need to 
# make their own data frame.
#L2ranef <- ranef(mod1)$ID

#L2randat <- data.frame("ID" = 1:nrow(L2ranef),
                      ## "RanInt"= L2ranef$`(Intercept)`,
                      # "RandSlope" = L2ranef$BlockNr)


# Level 1 assumptions
###ggplot(data = assuTdat, aes(sample = rez)) +
 ## stat_qq(alpha = 0.2) +
 # stat_qq_line() 

#ggplot(data = assuTdat, aes(x = preds,y = rez)) +
 # geom_point(alpha = 0.4) +
 # geom_smooth() + theme_minimal() +
 # ggtitle("Standardized residuals vs fitted")

# Level 2 assumptions
#ggplot(data = L2randat, aes(sample = RanInt)) +
#  stat_qq(alpha = 0.2) +
#  stat_qq_line() 

#ggplot(data = L2randat, aes(sample = RandSlope)) +
#  stat_qq(alpha = 0.2) +
#  stat_qq_line() 
#hist(L2randat$RandSlope)



#-------------------------------------------------------------------
# -------MISC: Visualize lmer lines --------------------------------
# ------------------------------------------------------------------
#in which repetition is max KI of every individual
#df_max <- dat %>% group_by(ID) %>% slice(which.max(KI))
#Ki_sum <- dat %>%
#  group_by(ID) %>%
#  summarise(variance = var(KI, na.rm = TRUE), mean = mean(KI,na.rm = T), 
#            median = median(KI, na.rm = T))

#hist(Ki_sum$variance)
#hist(df_max$Repetition)

#tt <- ranef(m_final)$ID
#t <- cbind(tt, df_max$Repetition, df_max$KI, unique_id$age, unique_id$SeqL,Ki_sum[2:4])
#t_7 <- t %>% filter(unique_id$SeqL == 7)
#t_10 <- t%>% filter(unique_id$SeqL == 10)
#t_n <- t %>% filter(Repetition < 0) #868 have negative slope
#hist(t_n$`unique_id$age`) #similar age dist.
#hist(t_n$`df_max$Repetition`) #in which repetition do they achieve their max KI
#hist(t_n$`df_max$KI`) #dist of Max KI
#table(t_n$`unique_id$SeqL`)
#table(t_n$`unique_id$performerKI`) #132 above median performance

#plot lines with intercept and slope 
#plot(dat$Repetition, dat$KI, type = "n")
#for (i in 1:nrow(t_n)){
#  abline(a = t_n$`(Intercept)`[i], b = t_n$Repetition[i])
#}

#Extract the estimated random intercepts at all time points
#re <- predict(m_final, newdata = dat, re.form = ~0 + (1 | ID))

# Plot the estimated random intercepts
#plot(re ~ dat$Repetition, xlab = "Time", ylab = "Estimated Random Intercept")

#cor.test(t_n$Repetition, t_n$median)
#cor(t_n$Repetition,t_n$`df_max$Repetition`)
#hist(t_n$`df_max$KI`)
#hist(t_n$median)
#hist(Ki_sum$variance)
#hist(t_n$`df_max$Repetition`)
#hist(t$`df_max$Repetition`)




