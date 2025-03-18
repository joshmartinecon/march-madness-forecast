
rm(list = ls())

library(rvest)

### Read in Schedle
x <- read_html("https://www.sports-reference.com/cbb/postseason/women/2025-ncaa.html")

### Extract Links for Each School
x %>%
  html_nodes("a") %>%
  html_attr("href") -> linkz
linkz[grepl("school", linkz)] -> linkz
linkz[grepl("/women/2025.html", linkz)] -> linkz
linkz <- linkz[5:68]

### Loop: Grab Advanced Statistics for each School
y <- list()
for(i in 1:length(linkz)){
  if(linkz[i] == "/cbb/schools//women/2025.html"){
    x <- data.frame(
      team = "Play-In",
      av = NA
    )
    
    y[[length(y)+1]] <- x
    cat(i, "out of", length(linkz), "\r")
  }else{
    
    x <- read_html(paste0("https://www.sports-reference.com/", linkz[i]))
    x %>%
      html_nodes(xpath = '//comment()') %>%    # select comment nodes
      html_text() %>%    # extract comment text
      paste(collapse = '') %>%    # collapse to a single string
      read_html() %>%    # reparse to HTML
      html_node('#players_advanced') %>%
      html_table() %>%
      as.data.frame() -> x

    x$minz <- x$MP / max(x$G) / (sum(x$MP/max(x$G)) / 40/5)
    x$team = linkz[i]
    gsub("/cbb/schools/", "", x$team) -> x$team
    gsub("/women/2025.html", "", x$team) -> x$team
    
    y[[length(y)+1]] <- x
    cat(i, "out of", length(linkz), "\r")
    Sys.sleep(5)
  }
}

### This will remove observations for play-in
z <- list()
for(i in 1:length(linkz)){
  z[[length(z)+1]] <- dim(y[[i]])
}
z <- as.data.frame(do.call(rbind, z))
y <- y[-c(as.numeric(row.names(z[z$V1 == 1,])))]
y <- as.data.frame(do.call(rbind, y))

### Productivity Statistics
y$PERz <- y$PER*y$minz
y$WS.40z <- y$`WS/40`*y$minz
y$BPMz <- y$BPM*y$minz
for(i in 30:32){
  y[,i][is.na(y[,i])] <- mean(y[,i], na.rm = TRUE)
  y[,i] <- (y[,i] - mean(y[,i])) / sd(y[,i])
}
y$av <- apply(y[,30:32], 1, sum)/3
z <- aggregate(y$av, list(y$team), sum)

### Pull Strength of Schedule Data
read_html("https://www.sports-reference.com/cbb/seasons/women/2025-school-stats.html") -> x

### Clean Strength of Schedule
x %>%
  html_table() %>%
  as.data.frame() -> x1
colnames(x1) <- x1[1,]
x1 <- x1[-1,]
x1 <- x1[x1[,1] != "" ,]
x1 <- x1[x1[,1] != "Rk",]
x1 <- x1[,1:8]

### Extract links for matching
x %>%
  html_nodes("a") %>%
  html_attr("href") -> x2
x2[grepl("school", x2)] -> x2
x2[grepl("/women/2025.html", x2)] -> x2
x1$link = x2[3:length(x2)]
gsub("/cbb/schools/", "", x1$link) -> x1$link
gsub("/women/2025.html", "", x1$link) -> x1$link

### Standardize this measure
x1$SRS <- as.numeric(x1$SRS)
x1$SOS <- as.numeric(x1$SOS)
x1$SRSz <- (x1$SRS - mean(x1$SRS)) / sd(x1$SRS)
x1$SOSz <- (x1$SOS - mean(x1$SOS)) / sd(x1$SOS)

### Strrength of Schedule Adjust
z$srs <- x1$SRSz[match(z$Group.1, x1$link)]
z$sos <- x1$SOSz[match(z$Group.1, x1$link)]
# z$av <- z$x
z$av <- z$x + z$sos

### Loop Prep
gsub("/cbb/schools/", "", linkz) -> linkz
gsub("/women/2025.html", "", linkz) -> linkz
x <- data.frame(
  team = linkz
)
x$av <- z$av[match(x$team, z$Group.1)]
x$av[is.na(x$av)] <- mean(x$av, na.rm = TRUE)
x$rank <- rep(c(1, 16, 8, 9, 5, 12, 4, 13, 6, 11, 3, 14, 7, 10, 2, 15), 4)

### Round of 64
j <- list()
for(i in c(1:64)[1:64 %% 2 != 0]){
  z <- x[i:(i+1),]
  
  j[[length(j)+1]] <- z[z$av == max(z$av),]
}
j <- as.data.frame(do.call(rbind, j))
j
# j[j$rank > 8,]

### Round of 32
j1 <- list()
for(i in c(1:32)[1:32 %% 2 != 0]){
  z <- j[i:(i+1),]
  
  j1[[length(j1)+1]] <- z[z$av == max(z$av),]
}
j1 <- as.data.frame(do.call(rbind, j1))
j1
# j1[j1$rank > 4,]

### Sweet 16
j2 <- list()
for(i in c(1:16)[1:16 %% 2 != 0]){
  z <- j1[i:(i+1),]
  
  j2[[length(j2)+1]] <- z[z$av == max(z$av),]
}
j2 <- as.data.frame(do.call(rbind, j2))
j2
# j2[j2$rank > 2,]

### Elite 8
j3 <- list()
for(i in c(1:8)[1:8 %% 2 != 0]){
  z <- j2[i:(i+1),]
  
  j3[[length(j3)+1]] <- z[z$av == max(z$av),]
}
j3 <- as.data.frame(do.call(rbind, j3))
j3
# j3[j3$rank > 1,]

### Final Four
j4 <- list()
for(i in c(1:4)[1:4 %% 2 != 0]){
  z <- j3[i:(i+1),]
  
  j4[[length(j4)+1]] <- z[z$av == max(z$av),]
}
j4 <- as.data.frame(do.call(rbind, j4))
j4

### Championship
j5 <- list()
for(i in c(1:2)[1:2 %% 2 != 0]){
  z <- j4[i:(i+1),]
  
  j5[[length(j5)+1]] <- z[z$av == max(z$av),]
}
j5 <- as.data.frame(do.call(rbind, j5))
j5
