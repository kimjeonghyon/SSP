Step 1: Load Data

Data Set Information:

Bike sharing systems are new generation of traditional bike rentals where whole process from membership, rental and return back has become automatic. Through these systems, user is able to easily rent a bike from a particular position and return back at another position. Currently, there are about over 500 bike-sharing programs around the world which is composed of over 500 thousands bicycles. Today, there exists great interest in these systems due to their important role in traffic, environmental and health issues.

Apart from interesting real world applications of bike sharing systems, the characteristics of data being generated by these systems make them attractive for the research. Opposed to other transport services such as bus or subway, the duration of travel, departure and arrival position is explicitly recorded in these systems. This feature turns bike sharing system into a virtual sensor network that can be used for sensing mobility in the city. Hence, it is expected that most of important events in the city could be detected via monitoring these data.
# install.packages("tseries")
# install.packages("ggplot2")
# install.packages("forecast")

library('ggplot2')
library('forecast')
## Warning: package 'forecast' was built under R version 3.3.3
## 
## Attaching package: 'forecast'
## The following object is masked from 'package:ggplot2':
## 
##     autolayer
library('tseries')
## Warning: package 'tseries' was built under R version 3.3.3
daily_data = read.csv('timeSeriseExample/day.csv', header=TRUE, stringsAsFactors=FALSE)

head(daily_data)
##   instant     dteday season yr mnth holiday weekday workingday weathersit
## 1       1 2011-01-01      1  0    1       0       6          0          2
## 2       2 2011-01-02      1  0    1       0       0          0          2
## 3       3 2011-01-03      1  0    1       0       1          1          1
## 4       4 2011-01-04      1  0    1       0       2          1          1
## 5       5 2011-01-05      1  0    1       0       3          1          1
## 6       6 2011-01-06      1  0    1       0       4          1          1
##       temp    atemp      hum windspeed casual registered  cnt
## 1 0.344167 0.363625 0.805833 0.1604460    331        654  985
## 2 0.363478 0.353739 0.696087 0.2485390    131        670  801
## 3 0.196364 0.189405 0.437273 0.2483090    120       1229 1349
## 4 0.200000 0.212122 0.590435 0.1602960    108       1454 1562
## 5 0.226957 0.229270 0.436957 0.1869000     82       1518 1600
## 6 0.204348 0.233209 0.518261 0.0895652     88       1518 1606




Attribute Information:
•instant: record index
•dteday : date
•season : season (1:springer, 2:summer, 3:fall, 4:winter)
•yr : year (0: 2011, 1:2012)
•mnth : month ( 1 to 12)
•hr : hour (0 to 23)
•holiday : weather day is holiday or not (extracted from [Web Link])
•weekday : day of the week
•workingday : if day is neither weekend nor holiday is 1, otherwise is 0.
•weathersit :
•1: Clear, Few clouds, Partly cloudy, Partly cloudy
•2: Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist
•3: Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered clouds
•4: Heavy Rain + Ice Pallets + Thunderstorm + Mist, Snow + Fog
•temp : Normalized temperature in Celsius. The values are derived via (t-t_min)/(t_max-t_min), t_min=-8, t_max=+39 (only in hourly scale)
•atemp: Normalized feeling temperature in Celsius. The values are derived via (t-t_min)/(t_max-t_min), t_min=-16, t_max=+50 (only in hourly scale)
•hum: Normalized humidity. The values are divided to 100 (max)
•windspeed: Normalized wind speed. The values are divided to 67 (max)
•casual: count of casual users
•registered: count of registered users
•cnt: count of total rental bikes including both casual and registered

Step 2: Examine Your Data
daily_data$Date = as.Date(daily_data$dteday)

ggplot(daily_data, aes(Date, cnt)) + geom_line() + scale_x_date('month')  + ylab("Daily Bike Checkouts") +
  xlab("")




 

tsclean

R provides a convenient method for removing time series outliers: tsclean() as part of its forecast package. tsclean() identifies and replaces outliers using series smoothing and decomposition.

This method is also capable of inputing missing values in the series if there are any.Note that we are using the ts() command to create a time series object to pass to tsclean()
count_ts = ts(daily_data[, c('cnt')])

daily_data$clean_cnt = tsclean(count_ts)

ggplot() +
  geom_line(data = daily_data, aes(x = Date, y = clean_cnt)) + ylab('Cleaned Bicycle Count')
## Don't know how to automatically pick scale for object of type ts. Defaulting to continuous.












Data smoothing technique

Even after removing outliers, the daily data is still pretty volatile. Visually, we could a draw a line through the series tracing its bigger troughs and peaks while smoothing out noisy fluctuations. This line can be described by one of the simplest — but also very useful —concepts in time series analysis known as a moving average. It is an intuitive concept that averages points across several time periods, thereby smoothing the observed data into a more stable predictable series.

Formally, a moving average (MA) of order m can be calculated by taking an average of series Y, k periods around each point:


MA=1m∑j=−kkyt+jMA=1m∑j=−kkyt+j




where m = 2k + 1. The above quantity is also called a symmetric moving average because data on each side of a point is involved in the calculation.

Note that the moving average in this context is distinct from the M A(q) component in the above ARIMA definition. Moving average M A(q) as part of the ARIMA framework refers to error lags and combinations, whereas the summary statistic of moving average refers to a data smoothing technique.

The wider the window of the moving average, the smoother original series becomes. In our bicycle example, we can take weekly or monthly moving average, smoothing the series into something more stable and therefore predictable:
daily_data$cnt_ma = ma(daily_data$clean_cnt, order=7) # using the clean count with no outliers
daily_data$cnt_ma30 = ma(daily_data$clean_cnt, order=30)


ggplot() +
  geom_line(data = daily_data, aes(x = Date, y = clean_cnt, colour = "Counts")) +
  geom_line(data = daily_data, aes(x = Date, y = cnt_ma,   colour = "Weekly Moving Average"))  +
  geom_line(data = daily_data, aes(x = Date, y = cnt_ma30, colour = "Monthly Moving Average"))  +
  ylab('Bicycle Count')
## Don't know how to automatically pick scale for object of type ts. Defaulting to continuous.
## Warning: Removed 6 rows containing missing values (geom_path).
## Warning: Removed 30 rows containing missing values (geom_path).









Step 3: Decompose Your Data

Decompose

Seasonal component refers to fluctuations in the data related to calendar cycles. For example, more people might be riding bikes in the summer and during warm weather, and less during colder months. Usually, seasonality is fixed at some number; for instance, quarter or month of the year.

Trend component is the overall pattern of the series: Is the number of bikes rented increasing or decreasing over time?

Cycle component consists of decreasing or increasing patterns that are not seasonal. Usually, trend and cycle components are grouped together. Trend-cycle component is estimated using moving averages.

Finally, part of the series that can’t be attributed to seasonal, cycle, or trend components is referred to as residual or error.

The process of extracting these components is referred to as decomposition.

stl()
count_ma = ts(na.omit(daily_data$cnt_ma), frequency=30)
decomp = stl(count_ma, s.window="periodic")
deseasonal_cnt <- seasadj(decomp)
plot(decomp)






Step 4: Stationarity
adf.test(count_ma, alternative = "stationary")
## Warning in adf.test(count_ma, alternative = "stationary"): p-value greater
## than printed p-value
## 
##  Augmented Dickey-Fuller Test
## 
## data:  count_ma
## Dickey-Fuller = -0.2557, Lag order = 8, p-value = 0.99
## alternative hypothesis: stationary
ndiffs(count_ma)
## [1] 1
nsdiffs(count_ma)
## [1] 0
PP.test(count_ma)
## 
##  Phillips-Perron Unit Root Test
## 
## data:  count_ma
## Dickey-Fuller = -1.1931, Truncation lag parameter = 6, p-value =
## 0.9076
# -> H0: non-stationary 
# -> H1: stationary 

Step 5: Autocorrelations and Choosing Model Order
Acf(count_ma, main='')

Pacf(count_ma, main='')










 
count_d1 = diff(deseasonal_cnt, differences = 1)
plot(count_d1)






adf.test(count_d1, alternative = "stationary")
## Warning in adf.test(count_d1, alternative = "stationary"): p-value smaller
## than printed p-value
## 
##  Augmented Dickey-Fuller Test
## 
## data:  count_d1
## Dickey-Fuller = -9.9255, Lag order = 8, p-value = 0.01
## alternative hypothesis: stationary

There are significant auto correlations at lag 1 and 2 and beyond. Partial correlation plots show a significant spike at lag 1 and 7. This suggests that we might want to test models with AR or MA components of order 1, 2, or 7. A spike at lag 7 might suggest that there is a seasonal pattern present, perhaps as day of the week. We talk about how to choose model order in the next step.
Acf(count_d1, main='ACF for Differenced Series')





Pacf(count_d1, main='PACF for Differenced Series')






Step 6: Fitting an ARIMA model

The forecast package allows the user to explicitly specify the order of the model using the arima() function, or automatically generate a set of optimal (p, d, q) using auto.arima(). This function searches through combinations of order parameters and picks the set that optimizes model fit criteria.
auto.arima(deseasonal_cnt, seasonal=FALSE)
## Series: deseasonal_cnt 
## ARIMA(1,1,1) 
## 
## Coefficients:
##          ar1      ma1
##       0.5510  -0.2496
## s.e.  0.0751   0.0849
## 
## sigma^2 estimated as 26180:  log likelihood=-4708.91
## AIC=9423.82   AICc=9423.85   BIC=9437.57

Using the ARIMA notation introduced above, the fitted model can be written as


Y^dt=0.551Yt−1−0.2496et−1+EY^dt=0.551Yt−1−0.2496et−1+E




where E is some error and the original series is differenced with order 1.

AR(1) coefficient p = 0.551 tells us that the next value in the series is taken as a dampened previous value by a factor of 0.55 and depends on previous error lag.

Step 7: Evaluate and Iterate

Can we trust this model? We can start by examining ACF and PACF plots for model residuals. If model order parameters and structure are correctly specified, we would expect no significant autocorrelations present.
fit<-auto.arima(deseasonal_cnt, seasonal=FALSE)
tsdisplay(residuals(fit), lag.max=45, main='(1,1,1) Model Residuals')




There is a clear pattern present in ACF/PACF and model residuals plots repeating at lag 7. This suggests that our model may be better off with a different specification, such as p = 7 or q = 7.

We can repeat the fitting process allowing for the MA(7) component and examine diagnostic plots again. This time, there are no significant autocorrelations present. If the model is not correctly specified, that will usually be reflected in residuals in the form of trends, skeweness, or any other patterns not captured by the model. Ideally, residuals should look like white noise, meaning they are normally distributed. A convenience function tsdisplay() can be used to plot these model diagnostics. Residuals plots show a smaller error range, more or less centered around 0. We can observe that AIC is smaller for the (1, 1, 7) structure as well:


fit2 = arima(deseasonal_cnt, order=c(1,1,7))

fit2
## 
## Call:
## arima(x = deseasonal_cnt, order = c(1, 1, 7))
## 
## Coefficients:
##          ar1     ma1     ma2     ma3     ma4     ma5     ma6      ma7
##       0.2803  0.1465  0.1524  0.1263  0.1225  0.1291  0.1471  -0.8353
## s.e.  0.0478  0.0289  0.0266  0.0261  0.0263  0.0257  0.0265   0.0285
## 
## sigma^2 estimated as 14392:  log likelihood = -4503.28,  aic = 9024.56
tsdisplay(residuals(fit2), lag.max=15, main='Seasonal Model Residuals')





fcast <- forecast(fit2, h=30)
plot(fcast)






“hold-out” set

The light blue line above shows the fit provided by the model, but what if we wanted to get a sense of how the model will perform in the future? One method is to reserve a portion of our data as a “hold-out” set, fit the model, and then compare the forecast to the actual observed values:
hold <- window(ts(deseasonal_cnt), start=700)

fit_no_holdout = arima(ts(deseasonal_cnt[-c(700:725)]), order=c(1,1,7))

fcast_no_holdout <- forecast(fit_no_holdout,h=25)
plot(fcast_no_holdout, main=" ")
lines(ts(deseasonal_cnt))






Refit model




How can we improve the forecast and iterate on this model? One simple change is to add back the seasonal component we extracted earlier. Another approach would be to allow for (P, D, Q) components to be included to the model, which is a default in the auto.arima() function. Re-fitting the model on the same data, we see that there still might be some seasonal pattern in the series, with the seasonal component described by AR(1):
fit_w_seasonality = auto.arima(deseasonal_cnt, seasonal=TRUE)
fit_w_seasonality
## Series: deseasonal_cnt 
## ARIMA(2,1,2)(1,0,0)[30] 
## 
## Coefficients:
##          ar1      ar2      ma1     ma2    sar1
##       1.3644  -0.8027  -1.2903  0.9146  0.0100
## s.e.  0.0372   0.0347   0.0255  0.0202  0.0388
## 
## sigma^2 estimated as 24810:  log likelihood=-4688.59
## AIC=9389.17   AICc=9389.29   BIC=9416.68
seas_fcast <- forecast(fit_w_seasonality, h=30)
plot(seas_fcast)



What’s Next?

After an initial naive model is built, it’s natural to wonder how to improve on it. Other forecasting techniques, such as exponential smoothing, would help make the model more accurate using a weighted combinations of seasonality, trend, and historical values to make predictions. In addition, daily bicycle demand is probably highly dependent on other factors, such weather, holidays, time of the day, etc. One could try fitting time series models that allow for inclusion of other predictors using methods such ARMAX or dynamic regression. These more complex models allow for control of other factors in predicting the time series.





ARIMA Model

Exercise 1

Load the dataset, and plot the variables cons (ice cream consumption), temp (temperature), and income.

The exercises make use of the Icecream dataset from the Ecdat package. The dataset contains the following variables:
•ice cream consumption in the USA (in pints, per capita),
•average family income per week (in USD),
•price of ice cream (per pint),
•average temperature (in Fahrenheit).

The number of observations is 30. They correspond to four-weekly periods in the span from March 18, 1951 to July 11, 1953
# install.packages("gridExtra")
# install.packages("ggplot2")

require(ggplot2)
## Loading required package: ggplot2
require(gridExtra)
## Loading required package: gridExtra
## Warning: package 'gridExtra' was built under R version 3.3.3
df <- read.csv("Icecream.csv")

head(df)
##   X  cons income price temp
## 1 1 0.386     78 0.270   41
## 2 2 0.374     79 0.282   56
## 3 3 0.393     81 0.277   63
## 4 4 0.425     80 0.280   68
## 5 5 0.406     76 0.272   69
## 6 6 0.344     78 0.262   65
p1 <- ggplot(df, aes(x = X, y = cons)) +
             ylab("Consumption") +
             xlab("") +
             geom_line() +
             expand_limits(x = 0, y = 0)
p2 <- ggplot(df, aes(x = X, y = temp)) +
             ylab("Temperature") +
             xlab("") +
             geom_line() +
             expand_limits(x = 0, y = 0)
p3 <- ggplot(df, aes(x = X, y = income)) +
             ylab("Income") +
             xlab("Period") +
             geom_line() +
             expand_limits(x = 0, y = 0)
grid.arrange(p1, p2, p3, ncol=1, nrow=3) 






Exercise 2


Estimate an ARIMA model for the data on ice cream consumption using the auto.arima function. Then pass the model as input to the forecast function to get a forecast for the next 6 periods (both functions are from the forecast package).


Plot the obtained forecast with the autoplot.forecast function from the forecast package.
require(forecast)
## Loading required package: forecast
## Warning: package 'forecast' was built under R version 3.3.3
## 
## Attaching package: 'forecast'
## The following object is masked from 'package:ggplot2':
## 
##     autolayer
fit_cons <- auto.arima(df$cons)
fcast_cons <- forecast(fit_cons, h = 6)
autoplot(fcast_cons)








Exercise 3


Use the accuracy function from the forecast package to find the mean absolute scaled error (MASE) of the fitted ARIMA model.
accuracy(fit_cons)
##                        ME       RMSE        MAE        MPE     MAPE
## Training set 0.0001020514 0.03525274 0.02692065 -0.9289035 7.203075
##                   MASE       ACF1
## Training set 0.8200619 -0.1002901


ARIMAX Model


Exercise 4


Estimate an extended ARIMA model for the consumption data with the temperature variable as an additional regressor (using the auto.arima function). Then make a forecast for the next 6 periods (note that this forecast requires an assumption about the expected temperature; assume that the temperature for the next 6 periods will be represented by the following vector: fcast_temp <- c(70.5, 66, 60.5, 45.5, 36, 28)).


Plot the obtained forecast.
fit_cons_temp <- auto.arima(df$cons, xreg = df$temp)
fcast_temp <- c(70.5, 66, 60.5, 45.5, 36, 28)
fcast_cons_temp <- forecast(fit_cons_temp, xreg = fcast_temp, h = 6)
autoplot(fcast_cons_temp)







Exercise 5


Print summary of the obtained forecast. Find the coefficient for the temperature variable, its standard error, and the MASE of the forecast. Compare the MASE with the one of the initial forecast.
summary(fcast_cons_temp)
## 
## Forecast method: Regression with ARIMA(0,1,0) errors
## 
## Model Information:
## Series: df$cons 
## Regression with ARIMA(0,1,0) errors 
## 
## Coefficients:
##         xreg
##       0.0028
## s.e.  0.0007
## 
## sigma^2 estimated as 0.001108:  log likelihood=58.03
## AIC=-112.06   AICc=-111.6   BIC=-109.32
## 
## Error measures:
##                       ME       RMSE        MAE      MPE     MAPE      MASE
## Training set 0.002563685 0.03216453 0.02414157 0.564013 6.478971 0.7354048
##                    ACF1
## Training set -0.1457977
## 
## Forecasts:
##    Point Forecast     Lo 80     Hi 80     Lo 95     Hi 95
## 31      0.5465774 0.5039101 0.5892446 0.4813234 0.6118313
## 32      0.5337735 0.4734329 0.5941142 0.4414905 0.6260566
## 33      0.5181244 0.4442225 0.5920263 0.4051012 0.6311476
## 34      0.4754450 0.3901105 0.5607796 0.3449371 0.6059529
## 35      0.4484147 0.3530078 0.5438217 0.3025024 0.5943270
## 36      0.4256524 0.3211393 0.5301654 0.2658135 0.5854913


Exercise 6


Check the statistical significance of the temperature variable coefficient using the the coeftest function from the lmtest package. Is the coefficient statistically significant at 5% level?
# install.packages("lmtest")
require(lmtest)
## Loading required package: lmtest
## Warning: package 'lmtest' was built under R version 3.3.3
## Loading required package: zoo
## Warning: package 'zoo' was built under R version 3.3.3
## 
## Attaching package: 'zoo'
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
coeftest(fit_cons_temp)
## 
## z test of coefficients:
## 
##       Estimate Std. Error z value  Pr(>|z|)    
## xreg 0.0028453  0.0007302  3.8966 9.756e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1


Exercise 7


The function that estimates the ARIMA model can input more additional regressors, but only in the form of a matrix. Create a matrix with the following columns:


1. values of the temperature variable,


2. values of the income variable,


3. values of the income variable lagged one period,


4. values of the income variable lagged two periods.


Print the matrix.


Note: the last three columns can be created by prepending two NA‘s to the vector of values of the income variable, and using the obtained vector as an input to the embed function (with the dimension parameter equal to the number of columns to be created).
temp_column <- matrix(df$temp, ncol = 1)
income <- c(NA, NA, df$income)
income_matrix <- embed(income, 3)
vars_matrix <- cbind(temp_column, income_matrix)
print(vars_matrix)
##       [,1] [,2] [,3] [,4]
##  [1,]   41   78   NA   NA
##  [2,]   56   79   78   NA
##  [3,]   63   81   79   78
##  [4,]   68   80   81   79
##  [5,]   69   76   80   81
##  [6,]   65   78   76   80
##  [7,]   61   82   78   76
##  [8,]   47   79   82   78
##  [9,]   32   76   79   82
## [10,]   24   79   76   79
## [11,]   28   82   79   76
## [12,]   26   85   82   79
## [13,]   32   86   85   82
## [14,]   40   83   86   85
## [15,]   55   84   83   86
## [16,]   63   82   84   83
## [17,]   72   80   82   84
## [18,]   72   78   80   82
## [19,]   67   84   78   80
## [20,]   60   86   84   78
## [21,]   44   85   86   84
## [22,]   40   87   85   86
## [23,]   32   94   87   85
## [24,]   27   92   94   87
## [25,]   28   95   92   94
## [26,]   33   96   95   92
## [27,]   41   94   96   95
## [28,]   52   96   94   96
## [29,]   64   91   96   94
## [30,]   71   90   91   96


Exercise 8


Use the obtained matrix to fit three extended ARIMA models that use the following variables as additional regressors:


1. temperature, income,


2. temperature, income at lags 0, 1,


3. temperature, income at lags 0, 1, 2.


Examine the summary for each model, and find the model with the lowest value of the Akaike information criterion (AIC).

Note that the AIC cannot be used for comparison of ARIMA models with different orders of integration (expressed by the middle terms in the model specifications) because of a difference in the number of observations. For example, an AIC value from a non-differenced model, ARIMA (p, 0, q), cannot be compared to the corresponding value of a differenced model, ARIMA (p, 1, q).

fit_vars_0 <- auto.arima(df$cons, xreg = vars_matrix[, 1:2])
fit_vars_1 <- auto.arima(df$cons, xreg = vars_matrix[, 1:3])
fit_vars_2 <- auto.arima(df$cons, xreg = vars_matrix[, 1:4])

print(fit_vars_0$aic)

## [1] -113.3357

print(fit_vars_1$aic)

## [1] -111.9228

print(fit_vars_2$aic)

## [1] -110.2497

Exercise 9

Use the model found in the previous exercise to make a forecast for the next 6 periods, and plot the forecast. (The forecast requires a matrix of the expected temperature and income for the next 6 periods; create the matrix using the fcast_temp variable, and the following values for expected income: 91, 91, 93, 96, 96, 96).

Find the mean absolute scaled error of the model, and compare it with the ones from the first two models in this exercise set.

expected_temp_income <- matrix(c(fcast_temp, 91, 91, 93, 96, 96, 96), ncol = 2, nrow = 6)
fcast_cons_temp_income <- forecast(fit_vars_0, xreg = expected_temp_income, h = 6)
autoplot(fcast_cons_temp_income)

 





accuracy(fit_cons)[, "MASE"]

## [1] 0.8200619

accuracy(fit_cons_temp)[, "MASE"]

## [1] 0.7354048

accuracy(fit_vars_0)[, "MASE"]

## [1] 0.7290753 




Exercise 1

Load the dataset, and plot
economic.df <- read.csv("BOK_macro_economic_rate.csv")

head(economic.df)
##      date employment_rate bonds_3_year
## 1 2010-01            56.8         4.29
## 2 2010-02            56.7         4.19
## 3 2010-03            57.9         3.94
## 4 2010-04            59.2         3.77
## 5 2010-05            60.1         3.70
## 6 2010-06            60.0         3.75
head(economic.df$employment_rate)
## [1] 56.8 56.7 57.9 59.2 60.1 60.0
head(economic.df$bonds_3_year)
## [1] 4.29 4.19 3.94 3.77 3.70 3.75
head(economic.df, n=3)
##      date employment_rate bonds_3_year
## 1 2010-01            56.8         4.29
## 2 2010-02            56.7         4.19
## 3 2010-03            57.9         3.94
economic.ts <- ts(economic.df[-c(1)], start=c(2010.1), frequency = 12)
economic.ts[,1]
## Time Series:
## Start = 2010.1 
## End = 2017.35 
## Frequency = 12 
##  [1] 56.8 56.7 57.9 59.2 60.1 60.0 60.0 59.2 59.3 59.5 59.3 58.2 57.0 57.3
## [15] 58.5 59.5 60.4 60.5 60.2 59.8 59.3 60.1 59.9 58.7 57.7 57.7 58.9 60.0
## [29] 60.8 60.7 60.6 59.9 60.2 60.3 59.9 58.6 57.7 57.5 58.7 60.0 60.6 60.8
## [43] 60.7 60.2 60.6 60.8 60.7 59.4 58.8 58.9 59.7 60.9 61.1 61.2 61.4 61.1
## [57] 61.1 61.1 61.1 59.7 59.0 59.1 59.8 60.6 61.2 61.2 61.3 60.9 61.1 61.2
## [71] 61.0 60.1 59.0 58.9 59.7 60.5 61.1 61.3 61.3 61.2 61.1 61.2 61.2 60.2
## [85] 59.1 59.3 60.3 61.0
employment.ts=ts(economic.df$employment_rate, start=c(2010.1), frequency = 12)

plot(employment.ts, xlab = "Time(Monthly)", ylab = " ", main = "Raw Data")

 



employment_dif.ts = diff(employment.ts, lag=12)
plot(employment_dif.ts, xlab = "Time(Monthly)", ylab = " ", main = "Frist Order Differenced at lag=12")

 

Exercise 2

계절 차분 및 단위근 검정
require(forecast)
## Loading required package: forecast
## Warning: package 'forecast' was built under R version 3.3.3
require(tseries)
## Loading required package: tseries
## Warning: package 'tseries' was built under R version 3.3.3
Acf(employment_dif.ts, main = "ACF of seasonally diffrenced series")





Pacf(employment_dif.ts, main = "PACF of seasonally diffrenced series")





adf.test(employment_dif.ts, k=3)
## 
##  Augmented Dickey-Fuller Test
## 
## data:  employment_dif.ts
## Dickey-Fuller = -2.1917, Lag order = 3, p-value = 0.4973
## alternative hypothesis: stationary

Exercise 3

계절 차분 후 1차 차분 추가
employment_dif2.ts = diff(employment_dif.ts, lag=1)

Acf(employment_dif2.ts, main = "ACF of seasonally & 1st order diffrenced series")





Pacf(employment_dif2.ts, main = "PACF of seasonally & 1st order diffrenced series")






Exercise 4

fit Model - arima function
employment_arima_fit <- arima(employment.ts, order = c(1,1,0), seasonal = list( order = c(0,1,1), period = 12))
                              
employment_arima_fit
## 
## Call:
## arima(x = employment.ts, order = c(1, 1, 0), seasonal = list(order = c(0, 1, 
##     1), period = 12))
## 
## Coefficients:
##           ar1     sma1
##       -0.3499  -0.4367
## s.e.   0.1112   0.1180
## 
## sigma^2 estimated as 0.04981:  log likelihood = 4.73,  aic = -3.46

fit Model - auto.arima function
employment_auto_fit <- auto.arima(employment.ts)

employment_auto_fit
## Series: employment.ts 
## ARIMA(0,1,1)(0,0,2)[12] 
## 
## Coefficients:
##          ma1    sma1    sma2
##       0.3088  0.6352  0.7242
## s.e.  0.1121  0.1483  0.2717
## 
## sigma^2 estimated as 0.1359:  log likelihood=-44.27
## AIC=96.53   AICc=97.02   BIC=106.4

fit Model - auto.arima function

차분 및 계절차분 고정
employment_auto_fit1 <- auto.arima(employment.ts, d=1, D=1)

employment_auto_fit1
## Series: employment.ts 
## ARIMA(0,1,1)(0,1,1)[12] 
## 
## Coefficients:
##           ma1     sma1
##       -0.3966  -0.4380
## s.e.   0.1106   0.1128
## 
## sigma^2 estimated as 0.05095:  log likelihood=5.32
## AIC=-4.64   AICc=-4.3   BIC=2.32

Exercise 5

잔차분석
# ResidualDiagnose(employment_arima_fit, season = TRUE)

tsdiag(employment_arima_fit)

 
qqnorm(employment_arima_fit$residuals)
qqline(employment_arima_fit$residuals)





tsdiag(employment_auto_fit1)

 
qqnorm(employment_auto_fit1$residuals)
qqline(employment_auto_fit1$residuals)






Exercise 6

모형 비교
round(rbind(accuracy(employment_arima_fit), accuracy(employment_auto_fit1)), 4)
##                   ME   RMSE    MAE     MPE   MAPE   MASE    ACF1
## Training set -0.0013 0.2073 0.1598 -0.0024 0.2666 0.3036 -0.0419
## Training set -0.0023 0.2056 0.1570 -0.0040 0.2620 0.4608 -0.0050
•ME(mean error)
•RMSE(Root mean squared error)
•MAE(Mean absolute error)
•MPE(Mean percentage error)
•MAPE(Mean absolute percentage error)
•MASE(Mean absolute scaled error)
•ACF1(the first-order autocorrelation coefficient)

Exercise 7

예측
plot(forecast(employment_arima_fit), main = "Forecasts from ARIMA(1,1,0)(0,1,1)[12]")





plot(forecast(employment_auto_fit1), main = "Forecasts from ARIMA(0,1,1)(0,0,2)[12]")








