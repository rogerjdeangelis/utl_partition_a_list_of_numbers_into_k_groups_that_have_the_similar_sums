Partition a list of numbers into k groups that have the same sum genetic algorithm;

  SAS/IML Genetic Algorithm Solution

  * I don't think genetic algorithms guarantee
    an optimum solution, but this seems to work.
    I only have a rough idea why this is working.
    Some stocastic black boxes?
  ;

see
https://tinyurl.com/yaf9ma8y
https://github.com/rogerjdeangelis/utl_partition_a_list_of_numbers_into_k_groups_that_have_the_similar_sums

see Ricks Blog
https://blogs.sas.com/content/iml/2017/05/01/split-data-groups-mean-variance.html

K Sharp profile
https://communities.sas.com/t5/user/viewprofilepage/user-id/18408

SOAPBOX ON
  SAS is like the Navy Seals, Army Rangers and Air Force top gun.
  R and Python are like the entire Army, Navy and Air force.
  Python, Java and C have solutions, but I tend to trust SAS a little more
  when SAS is apllicable.
SOAPBOX OFF

INPUT
=====

%let groups=3;

WORK.VAVE total obs=8

  NUMS

    1
    2
    3
    4
    5
    6
    7
    8


EXAMPLE OUTPUT
--------------

 GROUP    NUMS    SUMNUMS

   1        1        12
   1        3        12
   1        8        12

   2        7        12
   2        5        12

   3        6        12
   3        2        12
   3        4        12

PROCESS
=======

proc iml;
   use have nobs nobs;
   read all var {nums};
   close;

   start function(x) global(nums,nobs,group,tot);
   if countunique(x)=group then do;
   do i=1 to group;
    idx=loc(x=i);
    temp=nums[idx];
    tot[i,1]=sum(temp);
    tot[i,2]=sum(temp);
   end;

   /* substract the minimum from each num max differences?*/
   dif=sum(tot[,]-tot[><,]);
   end;
   else dif=999999;
   return (dif);
   finish;

   group=&groups;  /* number of groups */
   tot=j(group,2,.);

   encoding=j(2,nobs,1);
   encoding[2,]=group;

   id  =gasetup(2,nobs,123456789);
   call gasetobj(id,0,"function");
   call gasetsel(id,10,1,1);
   call gainit(id,1000,encoding);

   niter = 100;
   do i = 1 to niter;
    call garegen(id);
    call gagetval(value, id);
   end;
   call gagetmem(mem, value, id, 1);

   col_mem=t(mem);
   create group var {col_mem};
   append;
   close;

   print value[l = "Min Value:"] ;
   call gaend(id);

quit;

data wantpre;
 merge group have(keep=nums);
run;

proc sql;
  create
     table want as
  select
     col_mem as group
    ,nums
    ,sum(nums) as sumNums
  from
    wantpre
  group
    by col_mem
;quit;

proc print data=want;
run;quit;


OUTPUT
======

WORK.WANT total obs=8

 GROUP    NUMS    SUMNUMS

   1        1        12
   1        3        12
   1        8        12
   2        7        12
   2        5        12
   3        6        12
   3        2        12
   3        4        12

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

proc datasets lib=work kill;
run;quit;
data have;
  do nums=1 to 8;
    output;
  end;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

see process

