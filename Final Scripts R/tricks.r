library(data.table)
library(stringr)

data <- fread("C:\\Users\\olive\\OneDrive - Universität Zürich UZH\\Master3\\MA\\Excel HBN\\BD.csv")
head(data)

#find NDARAW298ZA9

id <- data$EID

test <- ifelse("NDARAW298ZA9"%in% id, 1,0)

#find NDARAX722PKY
test <- ifelse(id %in% "NDARAX722PKY", 1,0)
which(test %in% 1)

