library(ggplot2)
library(readr)
library(rpart)
library(rpart.plot)
library(randomForest)
library(caret)

# TODO we assume that a res.csv exists (typically a CSV extracted from the database)
res <- read.csv("/Users/macher1/Documents/SANDBOX/csvTuxml/ProjetIrma/csvgen/res3.csv") 
res <- res[-c(21, 22), ] # HACK: we should actually delete this entry in the databse

res$KERNEL_SIZE <- res$KERNEL_SIZE / 1048576
# res <- subset(res, KERNEL_SIZE != 0)
# res <- res[20:nrow(res),]

print(paste("configuration options", ncol(res)))
print(paste("number of configs", nrow(res))) 

myes <- apply(res, MARGIN = 1, FUN = function(x) length(x[x == "m"]))
smyes <- summary(myes)
print(paste("average number of m", smyes['Mean'])) 
print(paste("min number of m", min(myes))) 
print(paste("max number of m", max(myes))) 

nyes <- apply(res, MARGIN = 1, FUN = function(x) length(x[x == "y"]))
syes <- summary(nyes)
print(paste("average number of yes", syes['Mean'])) 
print(paste("min number of yes", min(nyes))) 
print(paste("max number of yes", max(nyes))) 

nyesAndM <- apply(res, MARGIN = 1, FUN = function(x) length(x[x == "y" | x == "m"]))
syesAndM <- summary(nyesAndM)
print(paste("average number of yes/m", syesAndM['Mean'])) 
print(paste("min number of yes/m", min(nyesAndM))) 
print(paste("max number of yes/m", max(nyesAndM))) 



# res$nbActiveOptions <- nyes

comptime <- res$COMPILE_TIME

ksize <- res$KERNEL_SIZE 
#print("Kernel sizes in Mo")
#print(ksize)

print("Kernel size (in Mo)")
print(summary(ksize))

print("Compilation time")
print(summary(comptime))

print(paste("correlation between size and compilation time", cor(ksize, comptime)))

print(paste("correlation between active options (yes and m) and comp time ", cor(nyesAndM, comptime)))
print(paste("correlation between active options (yes and m) and kernel size ", cor(nyesAndM, ksize)))

print(paste("correlation between yes options and comp time ", cor(nyes, comptime)))
print(paste("correlation between yes options and kernel size ", cor(nyes, ksize)))

print(paste("correlation between m options and comp time ", cor(myes, comptime)))
print(paste("correlation between m options and kernel size ", cor(myes, ksize)))

# Bar plot
bp<- ggplot(res, aes(x=CONFIG_DEBUG_INFO, y=""))+
  geom_bar(width = 1, stat = "identity")
bp

#counts = table(res$CONFIG_UBSAN_SANITIZE_ALL)  ## get counts
#labs = paste(res$CONFIG_UBSAN_SANITIZE_ALL, counts)  ## create labels
#pie(counts, labels = labs)  ## plot




N_TRAINING = 600

# splitdf function will return a list of training and testing sets
splitdf <- function(dataframe, seed=NULL) {
  if (!is.null(seed)) set.seed(seed)
  index <- 1:nrow(dataframe)
  #trainindex <- sample(index, trunc(length(index)/2))
  trainindex <- sample(index, trunc(N_TRAINING))
  trainset <- dataframe[trainindex, ]
  testset <- dataframe[-trainindex, ]
  list(trainset=trainset,testset=testset)
}

NTREE = 10

mkRandomForest <- function(dat) {
  # mtry <- (ncol(dat) - 7) # 7: because we excluse non predictor variables! => BAGGING (m=p)
  return (randomForest (KERNEL_SIZE~.-COMPILE_TIME, data=dat,importance=TRUE,ntree=NTREE,keep.forest=TRUE,na.action=na.exclude))
}

predComputation <- function(iris) {
  
  #apply the function
  splits <- splitdf(iris)
  
  # save the training and testing sets as data frames
  training <- splits$trainset
  testing <- splits$testset
  
  rtree <-  mkRandomForest(training)
    # rpart(KERNEL_SIZE~.-COMPILE_TIME, data=training,
    #   method = "anova",
    #   parms = list(split = "information"),
    #   control = rpart.control(minsplit = 2,
    #                           minbucket = 8,
    #                           #maxdepth = maxDepth,
    #                           #cp = complexity,
    #                           usesurrogate = 0,
    #                           maxsurrogate = 0))

  #rpart.plot(rtree)
  # print(rtree)
  # print(varImp(rtree))
  #print(varImp(rtree)[1:20,])
  #print(sort(varImp(rtree), decreasing = TRUE))
  # what are the important variables (via permutation)
  varImpPlot(rtree, type=1)
  
  #predict the outcome of the testing data
  predicted <- predict(rtree, newdata=testing)
  #predicted <- predict(model, data=testing) # for CART 

  # what is the proportion variation explained in the outcome of the testing data?
  # i.e., what is 1-(SSerror/SStotal)
  actual <- testing$KERNEL_SIZE 
  rsq <- 1-sum((actual-predicted)^2)/sum((actual-mean(actual))^2)
  #rsq <- sum((actual-predicted)^2)/sum((actual-mean(actual))^2)
  list(act=actual,prd=predicted,rs=rsq)
}

predKernelSizes <- predComputation(res)
predKernelSizes$d <- abs((predKernelSizes$act - predKernelSizes$prd) / predKernelSizes$act) 
mae <- ((100 / length(predKernelSizes$d)) * sum(predKernelSizes$d))
print(paste("MAE", mae))

