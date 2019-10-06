# based on: http://horicky.blogspot.com/2013/07/olap-operation-in-r.html
# Provided by Hong Cui

# This exercise illustrates the concepts of data cube and OLAP operations
# The implementation presented here is only good for small dataset that can be fit in to the memory of a computer.

# Step 1: Setup the dimension tables

#set.seed(1): don't really care about reproducibility so not using set.seed(). If we do care about reproducibility, we will set.seed() for 
#each of function that involve random sampling.  

(state_table <- data.frame(key=c("CA", "NY", "WA", "ON", "QU"),
                           name=c("California", "new York", "Washington", "Ontario", "Quebec"),
                           country=c("USA", "USA", "USA", "Canada", "Canada")))

(month_table <- data.frame(key=1:12,
                           desc=c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"),
                           quarter=c("Q1","Q1","Q1","Q2","Q2","Q2","Q3","Q3","Q3","Q4","Q4","Q4")))


(prod_table <-  data.frame(key=c("Printer", "Tablet", "Laptop"), price=c(225, 570, 1120)))




#Step 2: Function to generate the Sales table: the fact table
gen_sales <- function(no_of_recs) {
  # Generate transaction data by sampling, prob attributes indicate the change for the levels of a factor to be sampled
  loc <- sample(state_table$key, no_of_recs, replace=T, prob=c(2,2,1,1,1))
  time_month <- sample(month_table$key, no_of_recs, replace=T)
  time_year <- sample(c(2012, 2013), no_of_recs, replace=T)
  prod <- sample(prod_table$key, no_of_recs, replace=T, prob=c(1, 3, 2))
  unit <- sample(c(1,2), no_of_recs, replace=T, prob=c(10, 3)) #if the chance for '1' to be sampled is 10, then the chance for '2' to be sampled is 3.
  amount <- unit*prod_table[prod,]$price
  
  sales <- data.frame(month=time_month, year=time_year,
                      loc=loc, 
                      prod=prod,
                      unit=unit,
                      amount=amount)
  # Sort the records by time order
  sales <- sales[order(sales$year, sales$month),]
  row.names(sales) <- NULL
  return(sales)
  }

# Now create the sales fact table
(sales_fact <- gen_sales(500))

# Look at the records
View(sales_fact)
#or
head(sales_fact)

#Step 3: Convert the sales_fact table to a base cuboid with the measure=amount, which is a 4-D array. 
#tapply() Apply a function to each cell of a ragged array, 
#that is to each (non-empty) group of values given by a unique combination of the levels of certain factors.
(revenue_cube <- tapply(sales_fact$amount, 
                        sales_fact[,c("prod", "month", "year", "loc")], 
                        FUN=function(x){return(sum(x))}))


#check the dimensionalities of the cube
dimnames(revenue_cube)



#Step 4: Finally, OLAP operations can then be performed as selecting and/or aggregating segments in the 4-D array. 
#"Slice" performs a selectin on one dimension of the given cube. 
#For example, we can ask for the sales happening in "CA".
revenue_cube[, , , "CA"]


#"Dice" selects a subcube by selecting on two or more dimensions.  
#For example, we can ask for sales happening in [Jan/ Feb/Mar, Laptop/Tablet, CA/NY].
revenue_cube[c("Laptop", "Tablet"), c("1", "2", "3"), , c("CA", "NY")]


#"Rollup" is about applying an aggregation function to collapse a number of dimensions. 
#For example, we want to ask for the annual revenue for each product and collapse the location dimension (ie: we don't care where we sold our product).  
#Apply() returns a vector or array or list of values obtained by applying a function to margins of an array or matrix.
#In this case, the amount sum for different combinations of year and prod are computed
apply(revenue_cube, c("year", "prod"), FUN=function(x) sum(x, na.rm=TRUE))

#"Drilldown" is the reverse of "rollup" and applying an aggregation function to a finer level of granularity.  
#For example, we want to focus in the annual and monthly revenue for each product and collapse the location dimension (i.e.,: we don't care where we sold our product).
apply(revenue_cube, c("year", "month", "prod"), FUN=function(x) sum(x, na.rm=TRUE))


#"Pivot" is a visualization operation that rotates the data axes to provide an alternative data presentation.  
#For example, we can view the revenue by year and month, or by month and year.
apply(revenue_cube, c("year", "month"), FUN=function(x) sum(x, na.rm=TRUE))


apply(revenue_cube, c("month", "year"), FUN=function(x) sum(x, na.rm=TRUE))


#Product sales in CA in 2012: 
#rollup and dice
#rollup from months to year
(rollup <-apply(revenue_cube, c("loc", "prod", "year"), FUN=function(x) sum(x, na.rm=TRUE)))

dimnames(rollup)

#from the resulting subcube, select on location and year dimensions (dice)
(rollup["CA",, "2012"])

#compare and contrast: 
revenue_cube[, ,"2012" , "CA"]



#Generate cuboids from the base cuboid. 
#With cuboids available some of the OLAP operations make use of the cuboids that have already been computed. 
  
#apex
sum(apply(revenue_cube, c("year"), FUN=function(x) sum(x, na.rm=TRUE)))

#1-D cuboids
apply(revenue_cube, c("year"), FUN=function(x) sum(x, na.rm=TRUE))
apply(revenue_cube, c("prod"), FUN=function(x) sum(x, na.rm=TRUE))
apply(revenue_cube, c("month"), FUN=function(x) sum(x, na.rm=TRUE))
apply(revenue_cube, c("loc"), FUN=function(x) sum(x, na.rm=TRUE))

#2-D cuboids
apply(revenue_cube, c("year", "prod"), FUN=function(x) sum(x, na.rm=TRUE))
apply(revenue_cube, c("year", "month"), FUN=function(x) sum(x, na.rm=TRUE))
apply(revenue_cube, c("year", "loc"), FUN=function(x) sum(x, na.rm=TRUE))
apply(revenue_cube, c("prod", "month"), FUN=function(x) sum(x, na.rm=TRUE))
apply(revenue_cube, c("prod", "loc"), FUN=function(x) sum(x, na.rm=TRUE))
apply(revenue_cube, c("month", "loc"), FUN=function(x) sum(x, na.rm=TRUE))


# [REQUIRED]

# Students: please generate 3-D cuboids
# Students: What is 4-D or the base cuboid in this example?
  
  