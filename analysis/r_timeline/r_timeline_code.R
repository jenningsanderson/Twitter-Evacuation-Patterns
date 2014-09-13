library(ggplot2)
library(scales) # to access breaks/formatting functions

#Load the user
data = read.csv("../exports/ajc6789_minute.csv")  # read csv file 

#Convert the time -- not fucking working right now
data$TimeConvert <- as.POSIXct(strptime(data$Time, "%Y-%m-%d %H:%M:%S %z"), tz="EST")
data$Time <- as.POSIXct(data$TimeConvert)


ggplot(data, aes(x=Time, y = value, color = variable)) +  
  geom_point(aes(y = Preparation, col= "Preparation", label=Preparation)) +
  geom_point(aes(y = Movement, col = "Movement", label=Movement))       +
  geom_point(aes(y = Environment, col = "Environment", label=Environment)) +
  geom_point(aes(y = Collective.Information, col = "Collective", label=Collective.Information))   +
  geom_point(aes(y = Cluster, col = "Geo Location"))
#geom_text(angle = 45)




plot.new()
V1 <- as.Date(data$Time)
V2 <- data$Movement

plot(V1, V2,type = "n",bty = "n", 
     xlab = "Time", ylab = "Sentiment")

u <- par("usr")
#arrows(u[1], 0, u[2], 0, xpd = TRUE)
points(V1,V2,pch = 20)
#segments(V1,c(0,0,0),V1,V2)
text(x=V1,y=V2,labels=V2,pos=c(4,2,2))