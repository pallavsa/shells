# Pick up files
masterList=Investments.master
todaysFile=Investments.status.`date "+%Y%m%d"`

# Overall stats
totalStocks=0
totalCost=0
totalValue=0
totalGainLoss=0

#Create today's file
echo "Today's report, date:`date \"+%Y%m%d\"`" > $todaysFile
echo "=========================================================" >> $todaysFile
head -1 Investments.master|grep ^# >> $todaysFile
echo "=========================================================" >> $todaysFile

#Get rest of values
for i in `cat Investments.master|grep -v ^#`
do
   
   #Generate for the current stock
   myStockSymbol=`echo $i|cut -f 1 -d ,`
   myStockShares=`echo $i|cut -f 2 -d ,`
   myStockCost=`echo $i|cut -f 3 -d ,`
   myStockURL="https://api.iextrading.com/1.0/stock/${myStockSymbol}/price"
   myStockPrice=`curl -s $myStockURL`
   echo "Price of ${myStockSymbol} is ${myStockPrice}. I have $myStockShares shares bought at ${myStockCost}"
   myStockValue=`echo "$myStockShares * $myStockPrice"|bc -l`
   myStockGainLoss=`echo "$myStockValue - $myStockCost"|bc -l`
   myStockStatus="${i},$myStockPrice,$myStockValue,$myStockGainLoss"
   echo $myStockStatus >> $todaysFile
   
   #Aggregate totals
   totalStocks=`echo $totalStocks + 1|bc -l`
   totalCost=`echo $totalCost + $myStockCost|bc -l`
   totalValue=`echo $totalValue + $myStockValue|bc -l`
   totalGainLoss=`echo $totalGainLoss + $myStockGainLoss|bc -l`
done

echo "=========================================================" >> $todaysFile
echo "" >> $todaysFile
echo "Summary" >> $todaysFile
echo "totalStocks=$totalStocks" >> $todaysFile
echo "totalCost=$totalCost" >> $todaysFile
echo "totalValue=$totalValue" >> $todaysFile
echo "totalGainLoss=$totalGainLoss" >> $todaysFile