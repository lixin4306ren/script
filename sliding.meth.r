args <- commandArgs(TRUE)
#cat(args[1]);
#cat(args[2]);
setwd(args[4])
print(args[4])
sliding.count<-function(file,window.size,step.size,min.num=20,min.mc.depth=0){
library(data.table)
library(GenomicRanges)

read.table(file,colClasses = "integer")->x
#x[x$V4 > 0,]->x
#x[x$V3 > min.mc.depth,]->mcg
chr.name=tail(unlist(strsplit(file,'/')),n=1)
chr.name=unlist(strsplit(chr.name,'\\.'))[1]
#generate sliding window pos
#seq(min(x$V1),max(x$V1)-window.size+1,step.size)->start
#seq(min(x$V1)+window.size-1,max(x$V1),step.size)->end
print (chr.name)
seq(1,max(x$V1)-window.size+1,step.size)->start
seq(1+window.size-1,max(x$V1),step.size)->end

x[x$V4 > 0,]->x
x[x$V3 > min.mc.depth,]->mcg
win<-GRanges(seqnames=chr.name,IRanges(start=start,end=end))
#transfer x, y to GRange objects
cg1<-GRanges(seqnames=chr.name,IRanges(start=x$V1,end=x$V1))
mcg<-GRanges(seqnames=chr.name,IRanges(start=mcg$V1,end=mcg$V1))

as.data.frame(findOverlaps(win,cg1))->tmp1
countOverlaps(win,mcg)->mcg
countOverlaps(win,cg1)->c

which(countOverlaps(win,cg1)==0)->tmp2 #regions without Cs

data.table(id=as.character(tmp1$queryHits),cov=x$V4[tmp1$subjectHits],m=x$V3[tmp1$subjectHits])->new1
setkey(new1,id)
as.integer(new1[,sum(cov),by=id]$id)->id1
data.table(id=new1[,sum(cov),by=id]$id,start=start(win)[id1],end=end(win)[id1],m=new1[,sum(m),by=id]$V1,cov=new1[,sum(cov),by=id]$V1)->tmp1
tmp1<-rbind(data.frame(tmp1),data.frame(id=as.character(tmp2),start=start(win)[tmp2],end=end(win)[tmp2],m=rep(0,length(tmp2)),cov=rep(0,length(tmp2))))
sort(as.integer(tmp1$id),index.return = T)->ind1
tmp1[ind1$ix,]->tmp1

data.frame(rep(chr.name,nrow(tmp1)),tmp1$start,tmp1$end,tmp1$m/tmp1$cov)->out
paste(chr.name,".bed",sep="")->outname
write.table(out,file=outname,row.names=F,col.names=F,sep="\t",quote=F)
#tmp1$mcg=mcg
#tmp1$c=c
#tmp1[tmp1$cov>min.num,]->tmp1
#tmp1
}

sliding.count2<-function(x,chr.name="chr",window.size=10000,step.size=10000,min.num=20,min.mc.depth=0){
library(data.table)
library(GenomicRanges)

seq(1,max(x$V1)-window.size+1,step.size)->start
seq(1+window.size-1,max(x$V1),step.size)->end

x[x$V4 > 0,]->x
x[x$V3 > min.mc.depth,]->mcg
win<-GRanges(seqnames=chr.name,IRanges(start=start,end=end))
#transfer x, y to GRange objects
cg1<-GRanges(seqnames=chr.name,IRanges(start=x$V1,end=x$V1))
mcg<-GRanges(seqnames=chr.name,IRanges(start=mcg$V1,end=mcg$V1))

as.data.frame(findOverlaps(win,cg1))->tmp1
countOverlaps(win,mcg)->mcg
countOverlaps(win,cg1)->c

which(countOverlaps(win,cg1)==0)->tmp2 #regions without Cs

data.table(id=as.character(tmp1$queryHits),cov=x$V4[tmp1$subjectHits],m=x$V3[tmp1$subjectHits])->new1
setkey(new1,id)
as.integer(new1[,sum(cov),by=id]$id)->id1
data.table(id=new1[,sum(cov),by=id]$id,start=start(win)[id1],end=end(win)[id1],m=new1[,sum(m),by=id]$V1,cov=new1[,sum(cov),by=id]$V1)->tmp1
tmp1<-rbind(data.frame(tmp1),data.frame(id=as.character(tmp2),start=start(win)[tmp2],end=end(win)[tmp2],m=rep(0,length(tmp2)),cov=rep(0,length(tmp2))))
sort(as.integer(tmp1$id),index.return = T)->ind1
tmp1[ind1$ix,]->tmp1

tmp1$mcg=mcg
tmp1$c=c
tmp1[tmp1$cov>min.num,]->tmp1
tmp1
}
################################
plotCG<-function(all,chr.name="chr"){
window.size<-(all[[1]]$end[1]-all[[1]]$start[1]+1[1])
all[[1]]$start+window.size/2->plot.x
all[[1]]$c/window.size->plot.y
plot(plot.x,plot.y,pch=".",cex=0.1,col="black",ylab="CpG density",xlab=chr.name,type="n")
lines(smooth.spline(plot.x[which(plot.y != "NaN")], plot.y[which(plot.y != "NaN")], spar=0.3))
}
################################
plotmanyCG<-function(all,chr.name="chr"){
window.size<-(all[[1]]$end[1]-all[[1]]$start[1]+1[1])
all[[1]]$start+window.size/2->plot.x
all[[1]]$c/window.size->plot.y
plot(plot.x,plot.y,pch=".",cex=0.1,col="blue",ylab="CpG density",xlab=chr.name,type="n")

num<-length(all)
#rep(c("black","red"),each=3)->col
c("black","black","black","red","blue","green")->col
for(i in 1:num){
window.size<-(all[[i]]$end[1]-all[[i]]$start[1]+1[1])
all[[i]]$start+window.size/2->plot.x
all[[i]]$c/window.size->plot.y
lines(smooth.spline(plot.x[which(plot.y != "NaN")], plot.y[which(plot.y != "NaN")], spar=0.3),col=col[i])
}
}
class(args)
sliding.count(args[1],as.integer(args[2]),as.integer(args[3]))
