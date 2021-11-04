
%let tcode=t01;
%let ds=PUBLIC.ATUSSUM_2020;

%macro getci (tcode);

proc sql noprint;
	select name into :charvar separated by "+"
	from dictionary.columns
	where LIBNAME = "PUBLIC"
	and MEMNAME = "ATUSSUM_2020" 
	and name like "&tcode.%";
quit;

%if (%str(&tcode) ne t01) %then %let ds=abc;

data abc;
	set &ds;
	&tcode=1*compress(&charvar);
run;

%mend getci;

%let allt=t01 t02 t03 t04 t05 t06 t07 t08 t09 t10 t11 t12 t13 t14 t15 t16 t18 t50;
%let wordcount=%sysfunc(countw(&allt));

%macro getall;
%DO i=1 %TO %eval(&wordcount);
		%LET tcode = %scan("&allt",%eval(&i), ", ");
		%getci(&tcode);
%end;
%mend getall;

%getall;

data atussum_cate(keep=t01-t50);
	set abc;
run;

proc summary data=atussum_cate mean noprint;
	var _numeric_;
	output out=ci01(drop=_type_ _freq_) mean=/autoname ;
run;

proc summary data=atussum_cate lclm alpha=0.05 noprint;
	var _numeric_;
	output out=ci02(drop=_type_ _freq_) lclm=/autoname ;
run;

proc summary data=atussum_cate uclm alpha=0.05 noprint;
	var _numeric_;
	output out=ci03(drop=_type_ _freq_) uclm=/autoname ;
run;

proc transpose data=ci01 out=ct01 name=varname prefix=mean;
	var _numeric_;
run;
data ci_mean(rename=mean1=mean);
	set ct01;
	varname=substr(varname,1,3);
run;

proc transpose data=ci02 out=ct02 name=varname prefix=lclm;
	var _numeric_;
run;
data ci_lclm(rename=lclm1=lclm);
	set ct02;
	varname=substr(varname,1,3);
run;

proc transpose data=ci03 out=ct03 name=varname prefix=uclm;
	var _numeric_;
run;
data ci_uclm(rename=uclm1=uclm);
	set ct03;
	varname=substr(varname,1,3);
run;

data CI_merged; 
    merge ci_mean ci_lclm ci_uclm; 
    by varname; 
run;