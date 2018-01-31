# Quantitative-trade-signal-determination
Create a buy/sell trigger for a stock based on whether it is currently overpriced or under-priced

1.AIM
-----
The project delves into a trading strategy, where the aim is to create a buy/sell trigger for a stock based on whether it is currently overpriced or underpriced. 

The methodology The have employed to arrive at this conclusion is to identify the intrinsic value of the stock by using the Dividend discount model and evaluate this intrinsic value against the expected return of the stock calculated using the Capital asset pricing model. Based on the values obtained from the two models, a confidence interval is created to assess whether the stock price is current overvalued or undervalued. In a situation where it is overvalued, this indicates a sell signal for the stock and a buy signal when the analysis returns an undervalued situation.

For this, diverse statistical analysis was used to arrive at the final stock valuations. 30 stocks were considered for the analysis. The data under consideration spans the past year and it consists of the daily stock data - [Open, Close, Adjusted, Volume]. The initial steps consisted of computing the log returns of the stocks on a daily basis and populating the summary statistics for the same. 

2.METHODOLOGY
-------------

2.1	Computing summary statistics for log returns
-------------------------------------------------

The stock data consists of the daily open and price values of the stocks for 1 year. We compute the log returns of the stocks using the formula 

Daily Stock Returns= log⁡(S_Close/S_Open)

By computing the log returns on a daily basis, we are able to configure a parameter which is time additive and mathematically convenient as logarithms are easier to manipulate in calculus. By plotting the log returns on a histogram, we obtain graphs which are approximately normal. This indicates that prices of some stocks follow a lognormal distribution. But computing the closing and opening prices into one parameter such as log return, we are able to condense the information over an entire day of stock prices. Thus, by using the log prices, we can convert an exponential problem into a linear problem.

We see that the measured distribution is quite close to being normal. The exception to this being that the observed distribution is smaller at the mean and larger at high values. This difference in the shapes in termed as fat tails, meaning that the observed distribution is larger at the tails than a normal distribution. What this tells us is that large price changes occur more frequently than would be predicted by a normal distribution of the same variance. 

2.2 Identification and Consolidation of Dividend Returns
--------------------------------------------------------

The dividend discount model (DDM) is a method which is used to identify the intrinsic returns of a stock using the predicted dividends and discounting them to the present value. The dividend yield of a company is measure of the “productivity” of the company. The dividend of a stock is a sign of the stability of a company and those companies that have paid out significant dividends for a long period of time are seen as safe investments. 

The dividend discount model is mathematically represented as follows.

E(R_i)=  (D_0 (1+g))/((1+R_f)S)

Where,
E(R_i) - Intrinsic return
D_0 	 - Dividend Yield
g 	   - Growth rate
R_f 	 - Risk free rate
S 	   - Current Stock Price

2.3	Calculating the expected value of the stock using CAPM
----------------------------------------------------------

The capital asset pricing model (CAPM) is a model which is employed to forecast the return of the stock based on the 
	
  Expected return on the market – This is a forecast of the market’s return over a specified time
	Risk free rate – The interest rate available for a risk free security
	Beta of the stock -  This is a measure of the asset’s price volatility relative to that of the entire market

The CAPM can be mathematically represented in the following manner:

E(R_i )=R_f+ β[E(R_m )-R_f]

Where,
E(R_i)	- Expected return of the stock
R_f 	  - Risk Free Rate
β	      - Beta
E(R_m )	- Expected return of the market

In our analysis, we considered the log returns of the S&P 500 as the market component and hence needed to find the Beta of the log returns of each stock relative to the S&P 500. In order to arrive at the correlation between these two components, a measure which is vital to the calculation of the Beta, we built a linear regression model to compute the correlation. 

β=  (Cov(R_i,R_m))/(Var(R_m))= ρ_(i,m)  σ_i/σ_m 

Where,
ρ_(i,m)	Correlation Coefficient of the stock and the market
σ_i	Standard deviation of the stock
σ_m	Standard deviation of the market

3.HYPOTHESIS TESTING
---------------------

Using the values obtained for the returns from the Dividend discount model and the Capital asset pricing model, we wish to ascertain whether the stock price is overpriced or underpriced. 

We create a confidence interval for the forecasted stock return values obtained from the Capital asset pricing model using the z-test. The z-test is a hypothesis test in which the z-statistic follows a normal distribution. We state the hypothesis for the test as follows:

Null Hypothesis: If the forecasted and estimated stock return values fall within the confidence interval created, then the stock is fairly priced.

Alternate Hypothesis: If the forecasted and estimated stock return values do not fall within the confidence interval, then we check whether the stock is overpriced or underpriced. 

The z statistic is calculated as follows:

z=  ([E(R_CAPM)-E(R_DDM )])/(σ/√(n-1))
Where,
E(R〗_CAPM)    - Expected return from CAPM
E(R_DDM)	     - Return from DDM
σ	             - Standard deviation of the stock returns
n	             - Count of stock price data
