splitPoint <- function(x,y,sp.del=FALSE)
{
  y <- y[!is.na(x)]
  x <- x[!is.na(x)]
  
  ########################## Start change labels to Y , N
  y <- as.factor(y)
  temp <- table(y)
  if(temp[1]<temp[2])
  {
    levels(y)[1] <- "Y"
    levels(y)[2] <- "N"
  }
  else
  {
    levels(y)[1] <- "N"
    levels(y)[2] <- "Y"
  }
  ########################## End change labels to Y , N
  m <- sum(y=="Y")/length(y)
  m <- m
  #m <- 0.5
  
  or <- order(x)
  x <- x[or]
  y <- y[or]
  
  txy <-table(x,y)
  txy <- txy/rowSums(txy)
  txy <- data.frame(x=rownames(txy),N=txy[,"N"],Y=txy[,"Y"])
  txy$x <- as.numeric(as.character(txy$x))
  
  txy$lbl <- txy$Y >=m
  
  pre.lbl <- txy[1,4]
  sp <-c()
  spi<-c()
  temp <- c(1:length(x))
  for (i in 1:nrow(txy)) {
    now.lbl <- txy[i,4]
    if(now.lbl != pre.lbl)
    {
      sp <- c( sp,mean( c(txy[i,1],txy[i-1,1]) ) )
      
      spi<- c(spi,min(temp[x==txy[i,1]]))
    }
    pre.lbl <- now.lbl
  }
  if(length(sp)==0)
  {
    sp <- c("All")
    return(sp)
  }
  
  ###############delete split points
  if(sp.del & length(sp)>2)
  {
    sp <- c(0,sp,0)
    spi<- c(1,spi,(length(x)+1))
    del.index <- c()
    
    for (i in 2:(length(sp)-2)) {
      
      now.rec.count <- spi[i+1]-spi[i]
      pre.rec.count <- spi[i] - spi[i-1]
      nxt.rec.count <- spi[i+2]-spi[i+1]
      
      if(txy[ txy$x==x[spi[i]]  ,  4 ])
        trsh <- m
      else
        trsh <- 0.5
      
      now.rec.per <- now.rec.count/(now.rec.count+pre.rec.count+nxt.rec.count)
      if(  now.rec.per<trsh )
        del.index <- c(del.index,i,i+1)
    }
    sp<-sp[-del.index]
    sp<-sp[-c(1,length(sp))]
  }
  
  if(length(sp)==0)
    sp <- c("All")
  return(sp)
}

#3 group: N(values that all of instaces labels are N)
#         Y(values that all of instaces labels are Y)
#         YN(values that their instances have Y and N labels)
xColumnDisc <- function(x.col,sp)
{
  if(!is.numeric(x.col)&!is.integer(x.col))
  {
    print("features must be numeric or integer!")
    return()
  }
  sp <- sort(sp)
  x <- x.col
  x.disc <- x
  
  if(length(sp)==0)
  {
    x.disc <- rep(1,length(x.disc))
    return(x.disc)
  }
  else if(length(sp)==1 && (sp=="" |sp=="All"))
  {
    x.disc <- rep(1,length(x.disc))
    return(x.disc)
  }
  
  x.disc[x<=sp[1]] <- 1
  x.disc[x>sp[length(sp)]] <- ( length(sp)+1)
  
  if(length(sp)==1)
    return(x.disc)
  
  for (i in 2:length(sp)) {
    x.disc[x<=sp[i] & sp[i-1]<x] <- i
  }
  
  return(x.disc)
}


xColumnDisc_mean <- function(x.col,sp)
{
  if(!is.numeric(x.col)&!is.integer(x.col))
  {
    print("features must be numeric or integer!")
    return()
  }
  sp <- sort(sp)
  x <- x.col
  x.disc <- x
  
  if(length(sp)==0)
  {
    x.disc <- rep(mean(x),length(x.disc))
    return(x.disc)
  }
  else if(length(sp)==1 && (sp=="" |sp=="All"))
  {
    x.disc <- rep(mean(x),length(x.disc))
    return(x.disc)
  }
  
  x.disc[x<=sp[1]] <- mean(x[x<=sp[1]])
  x.disc[x>sp[length(sp)]] <- mean(x[x>sp[length(sp)]])
  
  if(length(sp)==1)
    return(x.disc)
  
  for (i in 2:length(sp)) {
    x.disc[x<=sp[i] & sp[i-1]<x] <- mean(x[x<=sp[i] & sp[i-1]<x])
  }
  
  return(x.disc)
}


xDisc <- function(x,sps,type)
{
  x.disc <- x
  if(type=='usual')
  {
    for (i in 1:ncol(x)) {
      x.disc[,i] <- xColumnDisc(x[,i],sps[[i]])
    }
  } else if(type=='mean')
  {
    for (i in 1:ncol(x)) {
      x.disc[,i] <- xColumnDisc_mean(x[,i],sps[[i]])
    }
  } else{
    print('type must be usual or mean')
  }
  
  
  #x.disc <- apply(x.disc, 2, as.integer)
  x.disc <- as.data.frame(x.disc)
  rownames(x.disc) <- rownames(x)
  
  return(x.disc)
}



avlDisc <- function(data,type='usual')
{
  x <- data[,-ncol(data)]
  y <- data[,ncol(data)]
  cn <- colnames(data)
  
  x.disc <- x
  sps <- list()
  for (i in 1:ncol(x)) {
    sps[[i]] <- splitPoint(x[,i],y)
  }
  
  x.disc <- xDisc(x,sps,type)
  
  data <- cbind(x.disc,y)
  colnames(data) <- cn
  return(list(cutp=sps,Disc.data=data))
}

#get cutpoint from discreted data
#data and disc.data dont have label
getCutPoint <- function(data,disc.data)
{
  cps <- list()
  for (i in 1:ncol(data)) {
    d <- data[,i]
    di <- disc.data[,i]
    cpi <- c()
    if(length(unique(di))==1)
    {
      cps[[i]] <-c("")
      next
    }
    
    or <- order(d,decreasing = FALSE)
    for (j in 2:length(or)) {
      if(di[or[j]] !=di[or[j-1]] )
        cpi <- c(   cpi   ,   mean(  c( d[or[j]] , d[or[j-1]] )  )   )
    }
    
    cps[[i]] <- cpi
  }
  
  return(cps)
}

meanDisc <- function(data,disc.data)
{
  sps <- getCutPoint(data,disc.data)
  
  
  x <- data[,-ncol(data)]
  y <- data[,ncol(data)]
  cn <- colnames(data)
  
  x.disc <- xDisc(x,sps,type = 'mean')
  
  data <- cbind(x.disc,y)
  colnames(data) <- cn
  return(list(cutp=sps,Disc.data=data))
}

