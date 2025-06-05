#Importing data VIA CSV provided from the SBA website. Also loading in libraries
library(readxl)
ProjectData <- read_excel("Documents/497 Class Project/TERM PROJ*/Term project data FULL SET.xlsx")
View(ProjectData)
library(readxl)
options(scipen = 9999)


#1 - Part One Data Wrangling ------

colSums(is.na(ProjectData))
"It seems like some rows may need to be turned into dummy vars but first lets
hanlde rows that shouldnt be NA

If a var has NA in these collumns than I will ommit them becuase I dont think it
will ruin the analysis
-Name #5 (# of NAs)
-City #30
-State #14
-Bank #1559
-Bankstate #1566
-ApprovalFy #18
-New Exist#136
-MIS STATUS (Omit)


Vars I will need to change to categorical and closley examine
-RevlineCr#4528
-LowDoc #2500 maybe get rid of
-ChgOffDateDate when a loan is declared to be in defualt #this mightbe worth 
-DisbursementDate #2368 (modify somehow)
"
sum(is.na(ProjectData))

chrg_counts <- table(ProjDataMKII$ChrgOff)  # Count occurrences of 0s and 1s
chrg_proportions <- prop.table(chrg_counts)*100  # Convert to proportions
barplot(chrg_proportions,
        col = c("grey", 'azure4'),  # Assign colors
        names.arg = c("Did not default (0)", "Defaulted (1)"),  # Label bars
        main = "Proportion of Loan Defaults",
        ylab = "Proportion (%)",
        xlab = "Loan Status",
        ylim = c(0,100))

UrbanRural_Table <-table(ProjDataMKII$UrbanRural)
UrbanRural_Table_Prop <- prop.table(UrbanRural_Table)*100
UrbanRural_Table_Prop

barplot(UrbanRural_Table_Prop,
        legend.text = FALSE,
        names.arg = c('Undefined','Urban','Rural'),
        ylim = c(0,60),
        main = "Proportion of Urban/Rural (%)",
        col = c('grey','azure4','grey'))

table(ProjDataMKII$NAICS)


#Let the Omitting begin------
ProjDataMKII<- ProjectData[complete.cases(ProjectData[,c(2,3,4,5,6,7,10,13,24)]),]
colSums(is.na(ProjDataMKII))


#looking at RevLineCr----
table(ProjDataMKII$RevLineCr)
table(ProjDataMKII$RevLineCr[ProjDataMKII$RevLineCr %in% c('Y', 'N')])

#Assuming T means Y
ProjDataMKII$RevLineCr[ProjDataMKII$RevLineCr == 'T'] <- 'Y'
table(ProjDataMKII$RevLineCr)

ProjDataMKII <- ProjDataMKII[ProjDataMKII$RevLineCr %in% c('Y', 'N'), ]

#Convert into Binary
ProjDataMKII$RevLineCr[ProjDataMKII$RevLineCr == 'Y'] <- 1
ProjDataMKII$RevLineCr[ProjDataMKII$RevLineCr == 'N'] <- 0
table(ProjDataMKII$RevLineCr)

#looking at LowDoc-----
table(ProjDataMKII$LowDoc) #alot of useless numbers and letters, onlt need Y & N
ProjDataMKII$LowDoc[ProjDataMKII$LowDoc == '0'] <- 'N'
ProjDataMKII <- ProjDataMKII[ProjDataMKII$LowDoc %in% c('Y', 'N'), ]

ProjDataMKII$LowDoc[ProjDataMKII$LowDoc == 'N'] <- 0
ProjDataMKII$LowDoc[ProjDataMKII$LowDoc == 'Y'] <- 1


#looking at ChOffDate(I will convert this to )
summary(ProjDataMKII$ChgOffDate)
ProjDataMKII$ChrgOff <- ifelse(is.na(ProjDataMKII$ChgOffDate), 0, 1)
table(ProjDataMKII$ChrgOff)

length(which((ProjDataMKII$ChrgOff==1)))/length(ProjDataMKII$ChrgOff) #.192% fail
View(ProjDataMKII)

#Is this a date------
class(ProjDataMKII$ApprovalDate)
ProjDataMKII$ApprovalDate <- as.Date(ProjDataMKII$ApprovalDate)
ProjDataMKII$ChgOffDate <- as.Date(ProjDataMKII$ChgOffDate)
ProjDataMKII$DisbursementDate <- as.Date(ProjDataMKII$DisbursementDate)

#Seee whats left-----
summary(ProjDataMKII)#No Emp
class(ProjDataMKII$LowDoc)
ProjDataMKII$LowDoc <- as.numeric(ProjDataMKII$LowDoc)
ProjDataMKII$RevLineCr <- as.numeric(ProjDataMKII$RevLineCr)

#NewExist, lets remove zero then reconvert into binary
table(ProjDataMKII$NewExist)
ProjDataMKII <- ProjDataMKII[ProjDataMKII$NewExist %in% c(1,2), ]
table(ProjDataMKII$NewExist)
ProjDataMKII$NewExist[ProjDataMKII$NewExist == 1] <- 0
ProjDataMKII$NewExist[ProjDataMKII$NewExist == 2] <- 1
table(ProjDataMKII$NewExist)

#UrbanRural convert into IsUrban
table(ProjDataMKII$UrbanRural)
ProjDataMKII$IsUrban <- ifelse(ProjDataMKII$UrbanRural==1,1,0)
table(ProjDataMKII$IsUrban)


table(ProjDataMKII$LowDoc)
table(ProjDataMKII$ChrgOff)
ProjDataMKII[8, ]


#Data Cleansing all done------
#Partioning Data-----
#lets split 3/4 for Training
#1/4 for validating

(3/4)*length(ProjDataMKII$LoanNr_ChkDgt)#=471,376.5
(1/4)*length(ProjDataMKII$LoanNr_ChkDgt)#157,125.5
157125+471377

#Log Vals
ProjDataMKII$LogDisbGross <- log(ProjDataMKII$DisbursementGross)
ProjDataMKII$LoGrAppv <-log(ProjDataMKII$GrAppv)

#Training Set
trainingSetMKII <- ProjDataMKII[1:471377,] 
ValidSetMKII <- ProjDataMKII[471377:628502,] 



#MODELING TIME-------
table(trainingSetMKII$ChrgOff)
prop.table(table(trainingSetMKII$ChrgOff))


Logistic_Model_1.0 <- glm(ChrgOff ~ Term + IsUrban, data = trainingSetMKII, family = binomial)
summary(Logistic_Model_1.0)


Logistic_Model_2.0 <- glm(ChrgOff ~ Term + DisbursementGross+GrAppv +IsUrban, data = trainingSetMKII, family = binomial(link = logit))
summary(Logistic_Model_2.0)

Logistic_Model_3.0 <- glm(ChrgOff ~ Term+DisbursementGross +LowDoc +GrAppv,data = trainingSetMKII, family = binomial)
summary(Logistic_Model_3.0)

                          
#Evaluation------
table(ProjDataMKII$ChrgOff)

#Holdout Corss-Validation Method (Model1)------------------------------------------------
pHat1.0 <- predict(Logistic_Model_1.0, ValidSetMKII, type="response")
yHat1.0 <- ifelse(pHat1.0 >= 0.35,1,0)#decreased the value to increase convservativeness
100*mean(ValidSetMKII$ChrgOff==yHat1.0)
#= 89.845 (Logistic_Model_1.0)

#k-Fold Cross Validation Method
pHat1.1 <- predict(Logistic_Model_1.0, ValidSetMKII, type = 'response')
yHat1.1 <- ifelse(pHat1.1>=0.35,1,0)

yTP1.1 <-ifelse(yHat1.1==1&ValidSetMKII$ChrgOff==1,1,0)
yTN1.1 <-ifelse(yHat1.1==0&ValidSetMKII$ChrgOff==0,1,0)

100*mean(ValidSetMKII$ChrgOff==yHat1.1)#accuracy
100*(sum(yTP1.1)/sum(ValidSetMKII$ChrgOff==1)) #sensitivity
100*(sum(yTN1.1)/sum(ValidSetMKII$ChrgOff==0))#specifity

table(ValidSetMKII$ChrgOff, yHat1.0)
table1.0<- table(ValidSetMKII$ChrgOff, yHat1.0)
prop.table(table1.0)
#Holdout Corss-Validation Method (Model2)------------------------------------
pHat2.0 <- predict(Logistic_Model_2.0, ValidSetMKII, type="response")
yHat2.0 <- ifelse(pHat2.0 >= 0.35,1,0)#decreased the value to increase convservativeness
100*mean(ValidSetMKII$ChrgOff==yHat2.0)
#= 89.812 (Logistic_Model_2.0) ???Same???

#k-Fold Cross Validation Method
pHat2.1 <- predict(Logistic_Model_2.0, ValidSetMKII, type = 'response')
yHat2.1 <- ifelse(pHat2.1>=0.35,1,0)

yTP2.1 <-ifelse(yHat2.1==1&ValidSetMKII$ChrgOff==1,1,0)
yTN2.1 <-ifelse(yHat2.1==0&ValidSetMKII$ChrgOff==0,1,0)

100*mean(ValidSetMKII$ChrgOff==yHat2.1)#accuracy
100*(sum(yTP2.1)/sum(ValidSetMKII$ChrgOff==1)) #sensitivity
100*(sum(yTN2.1)/sum(ValidSetMKII$ChrgOff==0))#specifity

table(ValidSetMKII$ChrgOff, yHat2.0)
table2.0<- table(ValidSetMKII$ChrgOff, yHat2.0)
prop.table(table2.0)

#Holdout Corss-Validation Method (Model3)------------------------------------
pHat3.0 <- predict(Logistic_Model_3.0, ValidSetMKII, type="response")
yHat3.0 <- ifelse(pHat3.0 >= 0.35,1,0)#decreased the value to increase convservativeness
100*mean(ValidSetMKII$ChrgOff==yHat3.0)
#= 82.415 (Logistic_Model_3.0) ???Same???

#k-Fold Cross Validation Method
pHat3.1 <- predict(Logistic_Model_3.0, ValidSetMKII, type = 'response')
yHat3.1 <- ifelse(pHat3.1>=0.35,1,0)

yTP3.1 <-ifelse(yHat3.1==1&ValidSetMKII$ChrgOff==1,1,0)
yTN3.1 <-ifelse(yHat3.1==0&ValidSetMKII$ChrgOff==0,1,0)

100*mean(ValidSetMKII$ChrgOff==yHat3.1)#accuracy
100*(sum(yTP3.1)/sum(ValidSetMKII$ChrgOff==1)) #sensitivity
100*(sum(yTN3.1)/sum(ValidSetMKII$ChrgOff==0))#specifity

table(ValidSetMKII$ChrgOff, yHat3.0)
table3.0<- table(ValidSetMKII$ChrgOff, yHat3.0)
prop.table(table3.0)

#Adding Y-Hat& P-Hat Coll Collumns-----

ProjDataMKII$P_Hat1.0 <- predict(Logistic_Model_1.0, ProjDataMKII, type = 'response')
ProjDataMKII$Y_Hat1.0 <-ifelse(ProjDataMKII$P_Hat1.0 >= 0.35,1,0)#decreased the value to increase convservativeness


ProjDataMKII$P_Hat2.0 <- predict(Logistic_Model_2.0, ProjDataMKII, type = 'response')
ProjDataMKII$Y_Hat2.0 <-ifelse(ProjDataMKII$P_Hat2.0 >= 0.35,1,0)#decreased the value to increase convservativeness

ProjDataMKII$P_Hat3.0 <- predict(Logistic_Model_3.0, ProjDataMKII, type = 'response')
ProjDataMKII$Y_Hat3.0 <-ifelse(ProjDataMKII$P_Hat3.0 >= 0.35,1,0)#decreased t

#Amount Loss

Amount_Loss_Observed <- sum(ProjDataMKII$DisbursementGross[ProjDataMKII$ChrgOff == 1])
Amount_Loss_Observed

Amount_Loss_Model2 <- sum(ProjDataMKII$DisbursementGross[ProjDataMKII$Y_Hat2.0 == 0 & ProjDataMKII$ChrgOff==1 ])
Amount_Loss_Model2

Amount_Loss_FalseNegatives <- sum(ProjDataMKII$DisbursementGross[ProjDataMKII$Y_Hat2.0 == 0 & ProjDataMKII$ChrgOff == 1])
Amount_Loss_FalseNegatives

#Model is a bit leinent but that's ok, its enought to allow the loan officer the ability to decide weather or not
# the loanee is a good applicant they can also applky their humans insight to make the best deciios


differenceO = Amount_Loss_Observed - Amount_Loss_Model2

differenceO/Amount_Loss_Observed

