# Pick up files
masterList=Investments.master
reportHeader=reports.header.html
todaysFile=Investments.status.`date "+%Y%m%d"`.html

# Overall stats
totalStocks=0
totalCost=0
totalValue=0
totalGainLoss=0

#Create today's file
#Header of html file
cat $reportHeader > $todaysFile
echo "<p><strong>Today's report, date:`date \"+%Y-%m-%d\"`</strong></p>" >> $todaysFile

#Data table
echo "<table><tr>" >> $todaysFile
echo "<th>Symbol</th>" >> $todaysFile
echo "<th>Shares</th>" >> $todaysFile
echo "<th>Cost</th>" >> $todaysFile
echo "<th>Price</th>" >> $todaysFile
echo "<th>Value</th>" >> $todaysFile
echo "<th>Gain<br>Loss</th>" >> $todaysFile

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
#   myStockStatus="${i},$myStockPrice,$myStockValue,$myStockGainLoss"
#   echo $myStockStatus >> $todaysFile

   #Add row to html table
   echo "<tr>" >> $todaysFile
   printf  "<td>%s</td>"   $myStockSymbol>> $todaysFile
   printf "<td>$%.0f</td>" $myStockShares >> $todaysFile
   printf "<td>$%.0f</td>" $myStockCost >> $todaysFile
   printf "<td>$%.0f</td>" $myStockPrice >> $todaysFile
   printf "<td>$%.0f</td>" $myStockValue >> $todaysFile
   printf "<td>$%.0f</td>" $myStockGainLoss >> $todaysFile
   echo "</tr>" >> $todaysFile
   
   #Aggregate totals
   totalStocks=`echo $totalStocks + 1|bc -l`
   totalCost=`echo $totalCost + $myStockCost|bc -l`
   totalValue=`echo $totalValue + $myStockValue|bc -l`
   totalGainLoss=`echo $totalGainLoss + $myStockGainLoss|bc -l`
done

#Write the summary
echo "<tr>" >> $todaysFile
printf "<th>Summary</th>" >> $todaysFile
printf "<th>.(%.0f).</th>" $totalStocks   >> $todaysFile
printf "<th>\$%.0f</th>"   $totalCost     >> $todaysFile
printf "<th>...</th>"                     >> $todaysFile
printf "<th>\$%.0f</th>"   $totalValue    >> $todaysFile
printf "<th>\$%.0f</th>"   $totalGainLoss >> $todaysFile
echo "</tr>" >> $todaysFile

echo "</table></body></html>" >> $todaysFile