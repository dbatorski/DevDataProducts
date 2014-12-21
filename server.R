library(shiny)

# Load data on internet connection speed 2003-2013. 
dane <- read.table("Dane_DS_lacza_2003-2013.txt", header = T, na.strings="")
# Data transformations
Mb <- round(dane$Kb/1024, 2) 
log2kb <- log2(dane$Kb)
p2003 <- dane$r2003/sum(dane$r2003)
p2005 <- dane$r2005/sum(dane$r2005)
p2007 <- dane$r2007/sum(dane$r2007)
p2009 <- dane$r2009/sum(dane$r2009)
p2011 <- dane$r2011/sum(dane$r2011)
p2013 <- dane$r2013/sum(dane$r2013)
x <- as.matrix(cbind(p2003,p2005,p2007,p2009,p2011,p2013),nrow=14,6)
naz <- c('1/16', '1/8', '1/4', '1/3', '1/2', round(Mb[6:14],0) )
# vectors for years 
lat1 = c(2003 + 0:17)
lat2 = c(seq(2003,2013,2))
# vector of average speed of internet access in Poland 2003-2013
mediana2 = c(1/16, 1/8, 1/2, 1, 2, 6)

# Prediction model 
m1m = lm(log2(mediana2) ~ lat2)
# weighted model
wagi = c(1,2,2,4,4,4)
wazenie <- function(vec){
  rep(vec,wagi)  
}
m2m = lm(log2(wazenie(mediana2)) ~ wazenie(lat2+1/4))

# predicted average speed in 2020
pred2m <- 2^(m2m$coef[[1]]+m2m$coef[[2]]*2020)

# Number of months in which internet speed doubles 
BatorskiLaw = round(12/m2m$coef[[2]],1)

# Uncerteinty of prediction
rste2m = summary(m2m)$sigma
vr = c(2013:2020)+1/4
vr2 = c(0:7)
vg2m = (m2m$coef[[1]] + m2m$coef[[2]]*vr + rste2m*vr2)
vd2m = (m2m$coef[[1]] + m2m$coef[[2]]*vr - rste2m*vr2)



shinyServer(
  function(input, output){
    output$newHist <- renderPlot({
      wybrane = as.numeric(input$id1)
      #par(mar=c(4, 4, 0.5, 2) + 0.1)
      barplot(100*t(x[,wybrane]), names.arg=naz, ylim=c(0,80), beside=T, las=1, 
              col=rainbow(6)[wybrane],
              main="Internet access and broadband speed in Poland", 
              sub="Source of data: Social diagnosis",
              xlab="Broadband capacity (Mbps)", 
              ylab="Percent of households with internet access")
      legend("right", title="year", legend=seq(2003,2013,2)[wybrane], fill=rainbow(6)[wybrane], bty="n")
      })
    output$newPlot <- renderPlot({
      scenario = as.numeric(input$id2)
      plot(c(2003,2020), c(-4,8),bty='l',yaxt='n',las=1,type='n',
         main='Broadband speed - prediction',
         xlab='year',ylab='Broadband capacity (Mbps)')
      axis(1, at=c(2003:2020),labels=F)
      axis(2, at=seq(-4,6,1),labels=c('1/16','1/8','1/4','1/2',2^seq(0,6,1)),las=1)
      abline(h=log2(c(30,100)),lty=3)
      abline(v=2020,lty=3)
      text(2006,log2(30),'30 Mbps', cex=0.8, pos=3, offset=0.1)
      text(2006,log2(100),'100 Mbps', cex=0.8, pos=3, offset=0.1)
      polygon(c(2013:2020,2020:2013)+1/4,c(vd2m,vg2m[8:1]), col='palegreen', border=NA)
      points(lat2+1/4, log2(mediana2), pch=1, col="green4")
      abline(m2m, lty=2, lwd=1, col='green4')
      points(2020,log2(pred2m),pch=19,col='green4')
      legend("left", pch=1, col='green4', legend="average broadband capacity", bty="n")
      text(2020,log2(pred2m), paste(round(pred2m,1),'Mbps'), cex=0.8, pos=2, offset=0.1)
      PredYear = as.numeric(strftime(as.Date(input$date), format = "%Y"))
      PredDay = as.numeric(strftime(as.Date(input$date), format = "%j"))
      SelectedDate = PredYear+PredDay/365
      abline(v=SelectedDate,lwd=2,col=2,lty=3)
      corect = 0
      if(SelectedDate>2013.25){
        corect = (2-scenario) * (rste2m*(SelectedDate-2013.25))
      }
      predictSelected = 2^(m2m$coef[[1]]+m2m$coef[[2]]*SelectedDate + corect)
      points(SelectedDate, log2(predictSelected), pch=19, col=2)
      v100 = 100-round(100*pnorm(log2(100),log2(predictSelected),1.6),1)
      v30 = 100-round(100*pnorm(log2(30),log2(predictSelected),1.6),1)
      text(2017,log2(.3375),c("Predicted percent of households"), pos=4)
      text(2017,log2(.225),c("with internet connection:"), pos=4)
      text(2017,log2(.15),"at least 30Mbps:  ", pos=4)
      text(2017,log2(.1),"at least 100Mbps: ", pos=4)
      text(2019,log2(.15),paste(v30,"%"), pos=4, col=2)
      text(2019,log2(.1),paste(v100,"%"), pos=4, col=2)
    })
    output$odate <- renderPrint({input$date})
    output$vmed <- renderPrint({predictSelected})
    output$v100 <- renderPrint({100-round(100*pnorm(log2(100),log2(predictSelected),1.6),1)})
    output$v30 <- renderPrint({100-round(100*pnorm(log2(30),log2(predictSelected),1.6),1)})
  }
)

