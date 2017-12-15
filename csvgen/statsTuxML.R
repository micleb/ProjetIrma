library(ggplot2)
library(readr)

# TODO we assume that a res.csv exists (typically a CSV extracted from the database)
res <- read.csv("res.csv") 

print(paste("configuration options", ncol(res)))
print(paste("number of configs", nrow(res))) 

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

ksize <- res$KERNEL_SIZE / 1048576
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

# Bar plot
bp<- ggplot(res, aes(x=CONFIG_NFT_REJECT_IPV4, y=""))+
  geom_bar(width = 1, stat = "identity")
bp

counts = table(res$CONFIG_X86_PMEM_LEGACY)  ## get counts
labs = paste(res$CONFIG_X86_PMEM_LEGACY, counts)  ## create labels
pie(counts, labels = labs)  ## plot
