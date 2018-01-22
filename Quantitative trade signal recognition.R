#Installing the list of packages we need if they are not already installed.
packages = c(
  "quantmod",
  "stats",
  "DescTools",
  "ggplot2",
  "PerformanceAnalytics",
  "fPortfolio",
  "PortfolioAnalytics",
  "lubridate",
  "xts",
  "shiny",
  "shinythemes"
)
installOrLoad <- function(pkg) {
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

installOrLoad(packages)

#Loading the set of stocks, their names and dividends

getwd()
setwd(".......................")

mainData = read.csv("C:..............",
                    header = TRUE,
                    sep = ',')

write.csv(mainData, file = "maindata1.csv")
#Getting the last 1 year data for it.
today = Sys.Date()
lastYear = ymd(today) - years(1)
stockPriceHistory = list()

getMarketData = function(ticker) {
  data = getSymbols(
    ticker,
    src = "yahoo",
    auto.assign = FALSE,
    from = lastYear,
    end = today
  )
  stockDF = as.data.frame(data, stringsAsFactors = F)
  stockDF$date = index(data) ## you can also use outputDf$date <- row.names(outputDf)
  return(stockDF)
}

computeLogReturns = function(stockName, df) {
  closeColName = paste(stockName, ".Close", sep = "")
  openColName = paste(stockName, ".Open", sep = "")
  df$log.return = log(df[, closeColName] / df[, openColName])
  return(df)
}

for (i in 1:length(mainData$Stock.Symbol)) {
  ticker = as.character(mainData$Stock.Symbol[i])
  stockDF = getMarketData(ticker)
  stockDF = computeLogReturns(ticker, stockDF)
  stockPriceHistory[[i]] = stockDF
}

snpData = getMarketData("^GSPC")
snpData = computeLogReturns("GSPC", snpData)
snpReturns = snpData$log.return
riskFreeRate = 0.0161
snpMean = mean(snpReturns)
snpSd = sd(snpReturns)

getStockIndex = function(ticker, masterData) {
  return (masterData$Index[masterData$Stock.Symbol == ticker])
}

computeDefaultStats = function(ticker, priceHistory, masterData) {
  i = getStockIndex(ticker, masterData)
  masterData$mean[[i]] = mean(priceHistory$log.return)
  masterData$sd[[i]] =  sd(priceHistory$log.return)
  masterData$median[[i]] = median(priceHistory$log.return)
  masterData$stockPrice[[i]] =
    priceHistory[nrow(priceHistory), paste(ticker, ".Close", sep = "")]
  return(masterData)
}
computeConfIntervals = function(priceHistory, masterData, confLevel) {
  i = getStockIndex(ticker, masterData)
  masterData$lowerCf[[i]] =   t.test((priceHistory$log.return), conf.level = confLevel)$conf.int[1:1]
  masterData$upperCf[[i]] = t.test((priceHistory$log.return), conf.level = confLevel)$conf.int[2:2]
  return(masterData)
}
computeMarketCorrelationAndBeta = function(ticker, priceHistory, masterData) {
  i = getStockIndex(ticker, masterData)
  linear = lm(snpReturns ~ stock$log.return)
  stockCorrelation = sqrt(summary(linear)$r.squared)
  masterData$correlation[[i]]  = stockCorrelation
  masterData$beta[[i]] = stockCorrelation * masterData$sd[[i]] / snpSd
  return(masterData)
}
computeDDMReturn = function(ticker, masterData) {
  i = getStockIndex(ticker, masterData)
  masterData$DDMReturn[[i]] = masterData$Dividend[[i]] * (1 + masterData$Dividend.Growth[[i]] /
                                                            100) / ((1 + riskFreeRate) * masterData$stockPrice[[i]])
  return(masterData)
}
computeCAPMReturn = function(ticker, masterData) {
  i = getStockIndex(ticker, masterData)
  masterData$CAPMReturn[[i]] = riskFreeRate + masterData$beta[[i]] * (snpMean - masterData$mean[[i]])
  return(masterData)
}
predictAction = function(ticker, masterData) {
  i = getStockIndex(ticker, masterData)
  zStat = (masterData$CAPMReturn[[i]] - masterData$DDMReturn[[i]]) / (masterData$sd[[i]] /
                                                                        sqrt(nrow(stock) - 1))
  verdict = ""
  if (zStat < 1.96 & zStat > -1.96) {
    verdict = "Fairly Priced, hold your trade"
  } else if (zStat > 1.96) {
    verdict = "Under priced, make a buy trade"
  } else{
    verdict = "Over priced, make a sell trade"
  }
  masterData$verdict[[i]] = verdict
  return(masterData)
}
for (i in 1:length(stockPriceHistory)) {
  stock = stockPriceHistory[[i]]
  ticker = mainData$Stock.Symbol[[i]]
  
  mainData = computeDefaultStats(ticker, stock, mainData)
  mainData = computeConfIntervals(stock, mainData, confLevel = 0.95)
  mainData = computeMarketCorrelationAndBeta(ticker, stock, mainData)
  mainData = computeDDMReturn(ticker, mainData)
  mainData = computeCAPMReturn(ticker, mainData)
  mainData = predictAction(ticker, mainData)
}

write.csv(mainData, file = "maindata2.csv")