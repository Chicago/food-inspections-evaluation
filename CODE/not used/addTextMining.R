
library(plyr)
library(tm)
library(SnowballC)
library(lda)
library(ggplot2)
library(reshape2)


addressCount <- ddply(foodInspect,c("doing_business_as_name"),summarize,addressCount=length(unique(address)))
foodInspect <- merge(
  x=foodInspect,
  y=addressCount,
  by="doing_business_as_name",
  all.x=TRUE,
  all.y=FALSE)
foodInspect$addressCount <- pmin(foodInspect$addressCount,5)

wardCount <- ddply(foodInspect,c("doing_business_as_name"),summarize,wardCount=length(unique(ward)))
foodInspect <- merge(
  x=foodInspect,
  y=wardCount,
  by="doing_business_as_name",
  all.x=TRUE,
  all.y=FALSE)
foodInspect$wardCount <- pmin(foodInspect$wardCount,5)

districtCount <- ddply(foodInspect,c("doing_business_as_name"),summarize,districtCount=length(unique(police_district)))
foodInspect <- merge(
  x=foodInspect,
  y=districtCount,
  by="doing_business_as_name",
  all.x=TRUE,
  all.y=FALSE)
foodInspect$districtCount <- pmin(foodInspect$districtCount,5)

rm(districtCount,wardCount,addressCount); gc()

bname <- foodInspect$doing_business_as_name
bname <- tolower(bname)
bname <- gsub("[[:punct:]]","",bname)
bname <- gsub("[0-9]+","",bname)

myStopWords <- c(stopwords("english"),"th")
myStopWords <- myStopWords[!grepl("[[:punct:]]",myStopWords)]
myStopRegEx <- paste("\\b",paste(myStopWords,collapse="\\b|\\b", sep=""),"\\b",sep="")

bname <- gsub(myStopRegEx,"",bname)

bname <- sapply(strsplit(bname," "), function(w) paste(wordStem(w),collapse=" ",sep=""))

bname <- gsub("[[:space:]]+"," ",bname)
bname <- gsub("^[[:space:]]+","",bname)
bname <- gsub("[[:space:]]+$","",bname)


words <- table(unlist(strsplit(bname, split=" ")))
words <- words[order(-words)]
words <- words[words>5]

name_split <- strsplit(bname, split=" ")

# tf <- llply(name_split,function(x) {
#   n <- sum(x %in% names(words))
#   if (n > 0){
#     mat <- matrix(0L,nrow=2,ncol=n)
#     w <- factor(x[x %in% names(words)],levels=names(words))
#     mat[1,] <- unclass(w) - 1L
#     mat[2,] <- as.integer(table(w)[x[x %in% names(words)]])
#   } else {
#     mat <- NULL
#   }
#   return(mat)
# })



#set.seed(8675309)
# K <- 10 ## Num clusters
# result <- lda.collapsed.gibbs.sampler(tf[!sapply(tf,is.null)], K, names(words), num.iterations=1000, alpha=0.1, eta=0.1, burnin=1000, compute.log.likelihood=TRUE) 
# plot(result$log.likelihoods[1,], type="l")
## Get the top words in the cluster
#(top.words <- top.topic.words(result$topics, 20))

#sum(sapply(name_split, function(wds) sum(wds %in% c("eurest")))>0)
#head(foodInspect$doing_business_as_name[sapply(name_split, function(wds) sum(wds %in% c("sodexo")))>0],20)


foodInspect$name_length <- sapply(name_split,length)
foodInspect$type_food <- "unknown"
foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                        c("el",
                          "taqueria",
                          "lo",
                          "de",
                          "y",
                          "mexican",
                          "chipotl",
                          "taco",
                          "don",
                          "pepe",
                          "birrieria",
                          "maria",
                          "del",
                          "taco",
                          "burrito",
                          "pollo",
                          "feliz",
                          "loco",
                          "hermano"
                        )))>0, "spanish", foodInspect$type_food)

foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                                   c("pizzeria",
                                                                     "pizza",
                                                                     "papa",
                                                                     "littl",
                                                                     "salad",
                                                                     "ristorant",
                                                                     "itali",
                                                                     "trattoria",
                                                                     "francesca",
                                                                     "di",
                                                                     "domino"                                                                     
                                                                   )))>0, "italian", foodInspect$type_food)





foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                                   c("subwai",
                                                                     "sandwich",
                                                                     "submarin",
                                                                     "work",
                                                                     "john",
                                                                     "potbelli",
                                                                     "jimmi",
                                                                     "sub",
                                                                     "cosi",
                                                                     "pocket"
                                                                   )))>0, "sandwich", foodInspect$type_food)



foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                                    c("bakeri",
                                                                      "cafe",
                                                                      "corner",
                                                                      "dunkin",
                                                                      "donut",
                                                                      "caff",
                                                                      "bagel",
                                                                      "sweet",
                                                                      "cake",
                                                                      "pastri",
                                                                      "bon",
                                                                      "au",
                                                                      "coffe",
                                                                      "starbuck",
                                                                      "tea",
                                                                      "bread",
                                                                      "pancak",
                                                                      "juic",
                                                                      "fruit",
                                                                      "xsport"                                                                      
                                                                    )))>0, "breakfast", foodInspect$type_food)



foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                                    c("burger",
                                                                      "hamburg",
                                                                      "chophous",
                                                                      "buffett",
                                                                      "kitchen",
                                                                      "wing",
                                                                      "wingstop",
                                                                      "wendi",
                                                                      "mcdonald",
                                                                      "fast",
                                                                      "donald",
                                                                      "castl",
                                                                      "box",
                                                                      "white",
                                                                      "popey",
                                                                      "king",
                                                                      "gyro",
                                                                      "fri",
                                                                      "beef",
                                                                      "bistro",
                                                                      "dog",
                                                                      "hot",
                                                                      "chicken",
                                                                      "fish",
                                                                      "restaur",
                                                                      "famili",
                                                                      "golden",
                                                                      "grill",
                                                                      "steak",
                                                                      "rib",
                                                                      "big",
                                                                      "pita",
                                                                      "indian",
                                                                      "india",
                                                                      "bombai",
                                                                      "kfc",
                                                                      "cuisin"
                                                                    )))>0, "dinner", foodInspect$type_food)










foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                                    c("bar",
                                                                      "club",
                                                                      "loung",
                                                                      "tavern",
                                                                      "sport",
                                                                      "pub",
                                                                      "tap",
                                                                      "cantina",
                                                                      "taverna"
                                                                    )))>0, "bar", foodInspect$type_food)








foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                               c("food",
                                                                 "mart",
                                                                 "liquor",
                                                                 "store",
                                                                 "groceri",
                                                                 "j",
                                                                 "eleven",
                                                                 "dollar",
                                                                 "walgreen",
                                                                 "store",
                                                                 "wine",
                                                                 "stop",
                                                                 "mini",
                                                                 "citgo",
                                                                 "bp",
                                                                 "shell",
                                                                 "pharmaci",
                                                                 "marathon",
                                                                 "snack"
                                                               )))>0, "mart", foodInspect$type_food)







foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                               c("hospit",
                                                                 "intern",
                                                                 "cater",
                                                                 "univers",
                                                                 "eurest",
                                                                 "servic",
                                                                 "levi",
                                                                 "center",
                                                                 "field",
                                                                 "hotel",
                                                                 "marriott",
                                                                 "sodexo",
                                                                 "aramark",
                                                                 "inn",
                                                                 "moodi",
                                                                 "arrang",
                                                                 "airlin",
                                                                 "associ",
                                                                 "institut"
                                                               )))>0, "cater", foodInspect$type_food)








foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                               c("new",
                                                                 "china",
                                                                 "thai",
                                                                 "chines",
                                                                 "cuisin",
                                                                 "wok",
                                                                 "express",
                                                                 "noodl",
                                                                 "sushi",
                                                                 "chines",
                                                                 "blue",
                                                                 "japanes",
                                                                 "rice",
                                                                 "express",
                                                                 "see",
                                                                 "afc",
                                                                 "chop",
                                                                 "suei",
                                                                 "panda",
                                                                 "see",
                                                                 "asian",
                                                                 "japan"
                                                               )))>0, "asian", foodInspect$type_food)









foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                               c("supermercado",
                                                                 "supermarket",
                                                                 "dominick",
                                                                 "jewel",
                                                                 "mariano",
                                                                 "trader",
                                                                 "aldi",
                                                                 "whole",
                                                                 "carniceria",
                                                                 "meat",
                                                                 "deli",
                                                                 "sausag",
                                                                 "produc",
                                                                 "market"
                                                               )))>0, "grocery", foodInspect$type_food)




#what about chocolate, or ben and jerri's
foodInspect$type_food <- ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                                   c("robbin",
                                                                     "baskin",
                                                                     "ic",
                                                                     "icecream",
                                                                     "dairi",
                                                                     "oberwei",
                                                                     "shake",
                                                                     "dessert",
                                                                     "gelato",
                                                                     "candi",
                                                                     "frozen",
                                                                     "yogurt",
                                                                     "cold",
                                                                     "sugar",
                                                                     "custard",
                                                                     "theatr",
                                                                     "pastri",
                                                                     "cake",
                                                                     "pretzel"
                                                                   )))>0, "dessert", foodInspect$type_food)








foodInspect$type_food <- factor(foodInspect$type_food, 
                            levels=c("spanish","italian","sandwich",
                                     "breakfast","dinner","bar",
                                     "mart","cater","asian",
                                     "grocery","dessert","unknown"))








foodInspect$nondisp_ware <-ifelse(sapply(name_split, function(wds) sum(wds %in% 
                                                                     c("ristorant",
                                                                       "itali",
                                                                       "trattoria",
                                                                       "francesca",
                                                                       "di",
                                                                       "cafe",
                                                                       "caff",
                                                                       "pancak",
                                                                       "chophous",
                                                                       "buffett",
                                                                       "kitchen",
                                                                       "bistro",
                                                                       "restaur",
                                                                       "famili",
                                                                       "golden",
                                                                       "steak",
                                                                       "rib",
                                                                       "indian",
                                                                       "india",
                                                                       "bombai",
                                                                       "cuisin",
                                                                       "bar",
                                                                       "club",
                                                                       "loung",
                                                                       "tavern",
                                                                       "sport",
                                                                       "pub",
                                                                       "tap",
                                                                       "cantina",
                                                                       "taverna",
                                                                       "hospit",
                                                                       "intern",
                                                                       "cater",
                                                                       "univers",
                                                                       "eurest",
                                                                       "servic",
                                                                       "center",
                                                                       "hotel",
                                                                       "marriott",
                                                                       "sodexo",
                                                                       "aramark",
                                                                       "inn",
                                                                       "moodi",
                                                                       "associ",
                                                                       "institut",
                                                                       "new",
                                                                       "china",
                                                                       "thai",
                                                                       "chines",
                                                                       "cuisin",
                                                                       "wok",
                                                                       "sushi",
                                                                       "chines",
                                                                       "blue",
                                                                       "japanes",
                                                                       "chop",
                                                                       "suei",
                                                                       "asian",
                                                                       "japan"
                                                                     )))>0, 1L, 0L)






## Number of documents to display
# N <- 10
# theme_set(theme_bw())  
# 
# topic.proportions <- t(result$document_sums) / colSums(result$document_sums)
# topic.proportions <- topic.proportions[sample(1:dim(topic.proportions)[1], N),]
# 
# topic.proportions[is.na(topic.proportions)] <-  1 / K
# 
# colnames(topic.proportions) <- apply(top.words, 2, paste, collapse=".")
# 
# topic.proportions.df <- melt(cbind(data.frame(topic.proportions), document=factor(1:N)),
#                              variable.name="topic",
#                              id.vars = "document")  
# head(topic.proportions.df)
# 
# ggplot(data=topic.proportions.df) + geom_bar(aes(x=topic,y=value,fill=topic),stat="identity") + labs(ylab="proportion") + 
#   theme(axis.text.x = element_text(angle=90, hjust=1)) +  
#   coord_flip() +
#   facet_wrap(~ document, ncol=5) + scale_x_discrete("", breaks = NULL)

# marginal <- result$topics / sum(result$topics)
# marginal[marginal==0] <- 1e-15
# marginal <- log(marginal/sum(marginal))
# #save(words, top.words, marginal, file="text_mine_result20140127v02.Rdata")
# 
# counts <- sapply(tf, function(m) {
#   if (is.null(m)) {
#     dat <- data.frame(voc=names(words)[1], cnts=0)
#   } else {
#     dat <- data.frame(voc=names(words)[m[1,]+1], cnts = m[2,])
#   }
#   dat$voc <- factor(dat$voc, levels=names(words))    
#   tapply(dat$cnts, dat$voc, sum, simplify=TRUE)
# })
# counts[is.na(counts)] <- 0
# 
# logLik <- marginal %*% counts
# 
# foodInspect$topic <- apply(top.words, 2, paste, collapse=".")[apply(logLik,2,which.max)]
# foodInspect$topic <- factor(foodInspect$topic, levels=apply(top.words, 2, paste, collapse="."))
# #head(foodInspect[,c("doing_business_as_name","topic")],50)
# 
# # ratio <- t(logLik)/logLik[1,] - 1
# # ratio <- ratio[,-1]
# # colnames(ratio) <- paste("lr",apply(top.words, 2, paste, collapse=".")[-1], sep="_")
# # foodInspect <- cbind(foodInspect,ratio)
# 
# logLik <- t(logLik)
# colnames(logLik) <- paste("lr",apply(top.words, 2, paste, collapse="."), sep="_")
# foodInspect <- cbind(foodInspect,logLik)


# tf_idf <- ldply(strsplit(bname, split=" "),function(x) {
#   table(factor(x[x %in% names(words)],levels=names(words)))
#   })
# ##idf <- sapply(tf_idf,function(col) sum(col!=0))
# ##idf <- log(nrow(tf_idf)/idf)
# ##l_ply(1:length(idf), function(i) {tf_idf[,i] <<- tf_idf[,i]*idf[i] 
# ##                                   invisible()})
# colnames(tf_idf) <- paste("name",colnames(tf_idf),sep="_")
# foodInspect <- cbind(foodInspect,tf_idf)

#rm(idf,bname,myStopRegEx,words,myStopWords,tf_idf); gc()
#rm(bname,myStopRegEx,words,myStopWords,tf_idf); gc()
#rm(bname,myStopRegEx,words,myStopWords,tf,counts,logLik,ratio,marginal,result,K); gc()
rm(bname,myStopRegEx,words,myStopWords,name_split); gc()
