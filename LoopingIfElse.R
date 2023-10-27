#### Advanced R Workshop, CCTWS 2022
#### Module #1: Speeding things up with looping
#### Author: Caroline Blommel 

########################
# Notes:
#   1. If you repeat the same function/line of code >3 times, consider using a looping function
#   2. Loops can make your code more efficient and easier to edit 
#   3. Start VERY BASIC when creating a loop, then build up from there
#   4. Common mistakes in for loops include:
#      - Missing or extra brackets
#      - Not setting up your sequence correctly
#      - Not using your index letting/the correct index letter in your loop
#      - Not saving your results into a vector/matrix

########################
####  Demonstration #### 
########################

###
### For loops
###

# Repeat the same line of code as many times as you specify
for(i in 1:10){
  print(i)
}

# Breaking down the structure 
for(i in 1:10){ # for every INDEX in SEQUENCE OF NUMBERS
  print(i) # RUN a function or operation
} # will loop over everything within {}

# Loops are useful when you want to automatically update a vector
v <- numeric(10) # create a vector of 10 0's
v
for(i in 1:10){
  v[i] <- i
}
v

#For example, for loops can be useful in building capture histories 

# For loops are useful for iterative operations
running.mean <- numeric(10)
for(i in 1:10){
  running.mean[i] <- mean(1:i)
}
running.mean # this is the mean at each step of the for loop 

# non-loop solution ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dplyr::cummean(1:10)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Challenge 1! ###
# Fix the following code so that it runs:
y <- numeric(10)
for(i in 1:10){
  y[i] <- mean(1:i)
}
y

# Loops are useful for random walks!
xy <- matrix(data=0,nrow=10,ncol=2) # columns = coordinates
xy

set.seed(111) #ensures the same random draws with each execution of this code 
for(t in 2:10){ # start at 2, because we sample based on the last point (random walk) 
  xy[t,] <- rnorm(n=2, mean=xy[t-1,], sd=0.5) #random draw from the normal distribution,  
} #2 at a time, based on the mean of the last step

xy

plot(xy[,1],xy[,2])
lines(xy[,1],xy[,2])

# For loops can also be helpful for splitting up dataframes
# Say you want to split up sites in your dataframe into items of a list:
dat <- data.frame(site=c(rep(1,5),rep(2,5),rep(3,5)), #sites 1, 2, and 3 (5 surveys each)
                  occ=rbinom(15,1,0.5), #occupancy 
                  rain=rnorm(15,10,2)) #survey/site-specific covariate 
dat
length(unique(dat$site))
site_list=list()
for(i in 1:length(unique(dat$site))){
  site_list[[i]] <- dat[dat$site==i,]
}
site_list
site_list[[2]]

# non-loop solution ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
lapply(
  unique(dat$site),
  function(x) dplyr::filter(dat, site == x)
)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Challenge 2!###
# Using a for loop, create a vector of 5 numbers where each value is the previous value squared, starting with 2.

# solution ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tmp <- 2

for(i in 1:5){
  tmp[i+1] <- tmp[i]^2
}
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Note: There are other types of looks in R (while loops, repeat loops), 
# but for loops are quite common and I find, the most useful

###
### Apply functions
###

# Similar to for loops, but condensed code and a bit less flexible

# # apply() is used for matrices
# # apply(OBJECT, MARGIN (1=row, 2=colum), FUNCTION)
mat <- matrix(data=c(rep(1,4),rep(2,4),rep(3,4)),nrow=4,ncol=3)
mat <- matrix(data = rep(1:3, 4), ncol = 3, byrow = TRUE)
mat
apply(mat, 1, sum)
apply(mat, 2, prod)

# # sapply() can be used for matrices, vectors, or arrays
vec <- 1:10
vec
vec_new <- sapply(vec, function(x){x+1})
vec_new

### Challenge 3!###
# Sum each of the columns in the following matrix:
prac <- matrix(rnorm(20,10,4),4,5)

apply(prac, 2, sum)

###
### If/Else Statements 
###

# If and else statements can be used on their own or within loops to allow your code to 
# execute an action based on criteria that you specify 

vec <- "present"

if(vec == "present"){ #test expression, if object vec is 'present' 
  vec <- 1 #then change the value to 1
} else { #otherwise
  vec <- 0 #change the value to 0
}

vec #the if/else statement was true, and thus the operation was executed 

# You can include if/else statements in loops as well 

occurrence <- c("present", "present", "absent", "absent", "present", "absent")
length(occurrence)

for(i in 1:length(occurrence)){
  if(occurrence[i] == "present"){
    occurrence[i] <- 1
  } else {
    occurrence[i] <- 0
  }
}

occurrence

# non-loop solution ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
occurrence <- c("present", "present", "absent", "absent", "present", "absent")

as.numeric(occurrence ==  "present")
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Applications ###
# What are some repetitive or iterative tasks that could be sped up or automated by loops?

#################################################################
#### End of Module
#################################################################




# Create some data
dat <- 
  tibble::tibble(
    obs = 1:100,
    id = rep(1:5, each = 20),
    year = rep(2001:2020, 5),
    value = rnorm(length(obs))
  ) |> 
  # convert year to numeric factor
  dplyr::mutate(
    year_fct = as.numeric(as.factor(year))
  )

# make some holes in the data
dat$value[sample(1:100, 10)] <- NA

# convert from long-from using nested indexing ---------------------------------

# get dimensions
n_obs = max(dat$obs)
n_id   <- dat$id |> unique() |> length()
n_year <- dat$year |> unique() |> length()

# create matrix to hold data
mat <- matrix(nrow = n_year, ncol = n_id)

# Fill matrix using nested indexing
for(i in 1:n_obs){
  mat[dat$year_fct[i], dat$id[i]] <- dat$value[i]
}

colnames(mat) <- paste0("id", unique(dat$id))
rownames(mat) <- unique(dat$year)

# non-loop solution ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
out <- 
  dat |> 
  dplyr::mutate(text_name = paste0("id", id)) |> 
  dplyr::select(text_name, year, value) |> 
  tidyr::pivot_wider(
    names_from = text_name,
    values_from = value
  )

out
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Fill missing values using for nested for loop
mat

for(i in 1:n_year){
  for(j in 1:n_id){
    mat[i, j] <- if(is.na(mat[i, j])) {999} else {mat[i, j]}
  }
}

# non-loop solution ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
out[is.na(out)] <- 999
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Nested loop example
ch <- matrix(data = NA, nrow = 10, ncol = 3)

for(i in 1:dim(ch)[1]){  
  for(j in 1:dim(ch)[2]){  
    ch[i,j] = rbinom(1,1,0.5) 
  }}
