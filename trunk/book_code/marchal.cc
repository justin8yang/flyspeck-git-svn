#include <iomanip.h>
#include <iostream.h>
#include <math.h>
#include "Minimizer.h"
#include "numerical.h"


// marchal.cc
// $ make marchal.o
// $ ./marchal.o

// constructor calls optimizer.  No need to place in main loop.
class trialdata {
public:
  trialdata(Minimizer M,char* s) {
    M.coutReport(s);
  };
};

int trialcount = 300;
double eps = 1.0e-6;
double s2 = sqrt(2.0);
double s8 = sqrt(8.0);

double alphamar = acos(1.0/3.0);
double Kmar = (3.0 * alphamar - pi()) * sqrt(2.0)/(12.0 * pi() - 30.0*alphamar);
double Mmar = (18.0 * alphamar - 7.0*pi())*sqrt(2.0)/(144.0*pi() - 360.0*alphamar);

double hmin = 1.2317544220903185; // where Mfun meets Lfun
double hmid = 1.26; // 2.52 truncation
double h0 = 1.26;
double hmax = 1.3254; // zero of Mfun

int wtrange(double t) {
  return ((t >= 2.0*hmin) && (t <= 2.0*hmax));
}
int wtcount(double y1,double y2,double y3,double y4,double y5,double y6) {
  int count =0;
  if (wtrange(y1)) { count++; }
  if (wtrange(y2)) { count++; }
  if (wtrange(y3)) { count++; }
  if (wtrange(y4)) { count++; }
  if (wtrange(y5)) { count++; }
  if (wtrange(y6)) { count++; }
  return count;
}
int wtcount3(double y1,double y2,double y3) {
  int count =0;
  if (wtrange(y1)) { count++; }
  if (wtrange(y2)) { count++; }
  if (wtrange(y3)) { count++; }
  return count;
}

double interp(double x,double x1,double y1,double x2,double y2) {
  return y1 + (x - x1) *(y2-y1)/(x2-x1);
}

double Mfun (double r) {
  return (s2 - r)*(r- 1.3254)*(9.0*r*r - 17.0*r + 3.0)/(1.627*(s2- 1.0));
}
double Lfun(double r) {
  return interp(r,  1.0,1.0,    hmid,0.0);
}
double Lmfun(double r) {
  return max(0,Lfun(r));
}

double vol4(double y1,double y2,double y3,double y4,double y5,double y6) {
  return sqrt(delta_x(y1*y1,y2*y2,y3*y3,y4*y4,y5*y5,y6*y6))/12.0;
}

double vol4M(double y1,double y2,double y3,double y4,double y5,double y6) {
  double d1 = dih_y(y1,y2,y3,y4,y5,y6);
double d2 = dih_y(y2, y3, y1, y5, y6, y4);
double d3 = dih_y(y3, y1, y2, y6, y4, y5);
double d4 = dih_y(y4, y2, y6, y1, y5, y3);
double d5 = dih_y(y5, y3, y4, y2, y6, y1);
double d6 = dih_y(y6, y1, y5, y3, y4, y2);
 return 8.0*((Kmar/(2.0*pi()))*(d1+d2+d3+d4+d5+d6) - Kmar - 
	     (Mmar/pi() )*(d1*Mfun(y1/2.0)+d2*Mfun(y2/2.0)+d3*Mfun(y3/2.0)+
			d4*Mfun(y4/2.0)+d5*Mfun(y5/2.0)+d6*Mfun(y6/2.0)));
}

double vol4L(double y1,double y2,double y3,double y4,double y5,double y6) {
  double d1 = dih_y(y1,y2,y3,y4,y5,y6);
double d2 = dih_y(y2, y3, y1, y5, y6, y4);
double d3 = dih_y(y3, y1, y2, y6, y4, y5);
double d4 = dih_y(y4, y2, y6, y1, y5, y3);
double d5 = dih_y(y5, y3, y4, y2, y6, y1);
double d6 = dih_y(y6, y1, y5, y3, y4, y2);
 return 8.0*((Kmar/(2.0*pi()))*(d1+d2+d3+d4+d5+d6) - Kmar - 
	     (Mmar/pi() )*(d1*Lmfun(y1/2.0)+d2*Lmfun(y2/2.0)+d3*Lmfun(y3/2.0)+
			d4*Lmfun(y4/2.0)+d5*Lmfun(y5/2.0)+d6*Lmfun(y6/2.0)));
}

double gamma4L (double y1,double y2,double y3,double y4,double y5,double y6) {
  return vol4(y1,y2,y3,y4,y5,y6) - vol4L(y1,y2,y3,y4,y5,y6);
}

double gamma4Lwt(double y1,double y2,double y3,double y4,double y5,double y6) {
  gamma4L(y1,y2,y3,y4,y5,y6)/wtcount(y1,y2,y3,y4,y5,y6);
}


// Now for the 3 variable inequality:
double vol3(double y1,double y2,double y3) {
  return vol4(s2,s2,s2,y1,y2,y3);
}
double vol3M(double y1,double y2,double y3) {
  double sol1 = sol_y(y1,y2,s2,s2,s2,y3);
  double sol2 = sol_y(y2,y3,s2,s2,s2,y1);
  double sol3 = sol_y(y3,y1,s2,s2,s2,y2);
  double d1 = dih_y(y1,y2,s2,s2,s2,y3);
  double d2 = dih_y(y2,y3,s2,s2,s2,y1);
  double d3 = dih_y(y3,y1,s2,s2,s2,y2);
  return (2.0*Kmar/pi())*(sol1+sol2+sol3) -
    (4.0*Mmar/pi())*2.0*(d1*Mfun(y1/2.0)+d2*Mfun(y2/2.0)+d3*Mfun(y3/2.0));
}
// same using modified Lmfun:
double vol3L(double y1,double y2,double y3) {
  double sol1 = sol_y(y1,y2,s2,s2,s2,y3);
  double sol2 = sol_y(y2,y3,s2,s2,s2,y1);
  double sol3 = sol_y(y3,y1,s2,s2,s2,y2);
  double d1 = dih_y(y1,y2,s2,s2,s2,y3);
  double d2 = dih_y(y2,y3,s2,s2,s2,y1);
  double d3 = dih_y(y3,y1,s2,s2,s2,y2);
  return (2.0*Kmar/pi())*(sol1+sol2+sol3) -
    (4.0*Mmar/pi())*2.0*(d1*Lmfun(y1/2.0)+d2*Lmfun(y2/2.0)+d3*Lmfun(y3/2.0));
}
double gamma3L(double y1,double y2,double y3) {
  if (radf(y1,y2,y3)>sqrt(2.0)) { return 0.0; }
  return vol3(y1,y2,y3) - vol3L(y1,y2,y3);
}
double gamma3Lwt(double y1,double y2,double y3) {
  return gamma3L(y1,y2,y3)/wtcount3(y1,y2,y3);
}


// dih*vol2(y/2) is the volume of a 2-cell (inside two-stacked Rogers of given dihR).
double vol2(double r) {
  return 2*(2 - r*r)*r/6.0;
}
double vol2L(double r) {
  return 2*((2*Kmar/pi())*(1-r/s2) - (4*Mmar/pi())*Lmfun(r));
}
double gamma2Ldivalpha(double r) {
  return vol2(r) - vol2L(r);
}
// combined 2 and 3 cell for simplices greater than sqrt2 in rad:
double gamma23L(double y1,double y2,double y3,double y4,double y5,double y6) {
  double gamma3Lterm =  gamma3L(y1,y2,y6) + gamma3L(y1,y3,y5);
  double dihrest = dih_y(y1,y2,y3,y4,y5,y6) - dih_y(y1,y2,s2,s2,s2,y6) - dih_y(y1,y3,s2,s2,s2,y5);
  double cell2 = dihrest*gamma2Ldivalpha(y1/2);
  return cell2 + gamma3Lterm;
}
// wtd combined 2 and 3 cell for simplices greater than sqrt2 in rad:
// assumes that the 2-cell has wt 1 (say, along a supercell)
double gamma23Lwt(double y1,double y2,double y3,double y4,double y5,double y6) {
  double gamma3Lterm =  gamma3Lwt(y1,y2,y6) + gamma3Lwt(y1,y3,y5);
  double dihrest = dih_y(y1,y2,y3,y4,y5,y6) - dih_y(y1,y2,s2,s2,s2,y6) - dih_y(y1,y3,s2,s2,s2,y5);
  double cell2 = dihrest*gamma2Ldivalpha(y1/2);
  return cell2 + gamma3Lterm;
}

double dihcc = dih_y(2*hmid,2,2,2,2,2);
double ggcc = gamma4L(2*hmid,2,2,2,2,2);




//constraint rad < sqrt2:
void smallrad(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = rady(y[0],y[1],y[2],y[3],y[4],y[5]) - (s2);
};
//constraint eta_y < s2:
void smallradf(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = radf(y[0],y[1],y[2]) - (s2);
};
//constraint rady < s2:
void smallrady(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = rady(y[0],y[1],y[2],y[3],y[4],y[5]) - (s2);
};
//constraint rady > s2 
void bigrady(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = -rady(y[0],y[1],y[2],y[3],y[4],y[5]) + (s2);
};
//constraint rady > s2  rad126, rad135 < s2.
void bigradysmallrafy(int numargs,int whichFn,double* y, double* ret,void*) {
  switch(whichFn) {
  case 1: *ret = -rady(y[0],y[1],y[2],y[3],y[4],y[5]) + (s2); break;
  case 2: *ret = radf(y[0],y[1],y[5]) - (s2); break;
  default: *ret = radf(y[0],y[2],y[4]) - (s2); break;
    
  }
};
//constraint gamma4L < 0:
void gamma4L_neg(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = gamma4L(y[0],y[1],y[2],y[3],y[4],y[5]);
};







////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t0(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = vol4(y[0],y[1],y[2],y[3],y[4],y[5]) -vol4M(y[0],y[1],y[2],y[3],y[4],y[5]) + eps;
	}
Minimizer m0() {
  double xmin[6]= {2,2,2,2,2,2};
  double xmax[6]= {sqrt(8.0),sqrt(8.0),sqrt(8.0),sqrt(8.0),sqrt(8.0),sqrt(8.0)};
	Minimizer M(trialcount,6,1,xmin,xmax);
	M.func = t0;
	M.cFunc = smallrad;
	return M;
}
trialdata d0(m0(),"ID[1025009205] d0: Marchal main 4-cell inequality");

////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t1(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = vol3(y[0],y[1],y[2]) -vol3M(y[0],y[1],y[2]) + eps;
	}
Minimizer m1() {
  double xmin[3]= {2,2,2};
  double xmax[3]= {sqrt(8.0),sqrt(8.0),sqrt(8.0)};
	Minimizer M(trialcount,3,1,xmin,xmax);
	M.func = t1;
	M.cFunc = smallradf;
	return M;
}
trialdata d1(m1(),"ID[3564312720] d1: Marchal main 3-cell inequality");

////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t1a(int numargs,int whichFn,double* y, double* ret,void*) {
  double eps = 1.0e-7;
  *ret = gamma3L(y[0],y[1],y[2])+eps;
	}
Minimizer m1a() {
  double xmin[3]= {2,2,2};
  double xmax[3]= {sqrt(8.0),sqrt(8.0),sqrt(8.0)};
	Minimizer M(trialcount,3,1,xmin,xmax);
	M.func = t1a;
	M.cFunc = smallradf;
	return M;
}
trialdata d1a(m1a(),"ID[4869905472] GLFVCVK d1a: Marchal main 3-cell inequality (L version) \n (Exact equality when eta=sqrt2)");


////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t21a(int numargs,int whichFn,double* y, double* ret,void*) {
  // set to zero on quarters //  
  //*ret = (wtcount(y[0],y[1],y[2],y[3],y[4],y[5])==1 ? 0.0 : gamma4L(y[0],y[1],y[2],y[3],y[4],y[5]));
  *ret = gamma4L(y[0],y[1],y[2],y[3],y[4],y[5]);
	}
//constraint outside a ball (which is contained in quarters), rad < sqrt2
void c21a(int numargs,int whichFn,double* y, double* ret,void*) {
  double hh = (hmin + hmax)/2.0;
  double z[6]={2*hh,2,2,2,2,2};
  double r0 = 4.0*(hmax-hh)*(hmax-hh);
  double r = 0.0;
  for (int i=0;i<6;i++) { r += (y[i]-z[i])*(y[i]-z[i]); }
  switch(whichFn) {
  case 1 : *ret =rady(y[0],y[1],y[2],y[3],y[4],y[5]) - (s2); break;
  case 2: *ret  = - r + r0; break;
    // if not a quarter then some |yi-zi|^2 > r0
  }
}
Minimizer m21a() {
  double t = sqrt(8.0);
  double xmin[6]= {2.0*hmin,2,2,2,2,2};
  double xmax[6]= {2.0*hmax,t,t,t,t,t};
	Minimizer M(trialcount,6,2,xmin,xmax);
	M.func = t21a;
	M.cFunc = c21a;
	return M;
}
trialdata d21a(m21a(),"ID[2477216213] GLFVCVK: d21: Marchal, gamma4L(non-quarter) >= 0");


////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t17(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = gamma4L(y[0],y[1],y[2],y[3],y[4],y[5]) + gamma3L(y[0],y[1],y[5]);
	}
Minimizer m17() {
  double t = 2.0*hmin-eps;
  double xmin[6]= {2.0*hmin+eps,2,2,2,2,2};
  double xmax[6]= {2.0*hmax,t,t,t,t,t};
	Minimizer M(trialcount,6,1,xmin,xmax);
	M.func = t17;
	M.cFunc = smallrady;
	return M;
}
trialdata d17(m17(),"ID[1118115412] FHBVYXZ: cc:2bl: d17: Marchal, 2-blade, gamma4L(quarter)+gamma3L>0");

////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t18(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = 1.65 - dih_y(y[0],y[1],y[2],y[3],y[4],y[5]);
	}
Minimizer m18() {
  double t = 2.0*hmin;
  double xmin[6]= {2.0*hmin,2,2,2,2,2};
  double xmax[6]= {2.0*hmax,t,t,t,t,t};
	Minimizer M(trialcount,6,1,xmin,xmax);
	M.func = t18;
	M.cFunc = gamma4L_neg;
	return M;
}
trialdata d18(m18(),"ID BIXPCGW: cc:3bl: d18: Marchal, dih(quarter) < 1.65, if gamma4L is neg");

////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t19(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = 2.8 - dih_y(y[0],y[1],y[2],y[3],y[4],y[5]);
	}
Minimizer m19() {
  double s8 = sqrt(8.0);
  double xmin[6]= {2.0*hmin,2,2,2,2,2};
  double xmax[6]= {2.0*hmax,s8,s8,s8,s8,s8};
	Minimizer M(trialcount,6,0,xmin,xmax);
	M.func = t19;
	return M;
}
trialdata d19(m19(),"ID BIXPCGW: cc:3bl: d19: Marchal, dih(four-cell w. diag) < 2.8");

////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t20a(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = 2.3 - dih_y(y[0],y[1],y[2],y[3],y[4],y[5]);
	}
Minimizer m20a() {
  double s8 = sqrt(8.0);
  double xmin[6]= {2.0*hmin,2.0*hmin,2,2,2,2};
  double xmax[6]= {2.0*hmax,2.0*hmax,s8,s8,s8,s8};
	Minimizer M(trialcount,6,0,xmin,xmax);
	M.func = t20a;
	return M;
}
trialdata d20a(m20a(),"ID BIXPCGW: cc:3bl: d20a: Marchal, if wt<1, then angle < 2.3, adjacent");

////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t20b(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = 2.3 - dih_y(y[0],y[1],y[2],y[3],y[4],y[5]);
	}
Minimizer m20b() {
  double s8 = sqrt(8.0);
  double xmin[6]= {2.0*hmin,2,2,2*hmin,2,2};
  double xmax[6]= {2.0*hmax,s8,s8,2*hmax,s8,s8};
	Minimizer M(trialcount,6,0,xmin,xmax);
	M.func = t20b;
	return M;
}
trialdata d20b(m20b(),"ID BIXPCGW cc:3bl: d20b: Marchal, if wt<1, then angle < 2.3, opposite");

////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t21(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = gamma4L(y[0],y[1],y[2],y[3],y[4],y[5]) +0.0057;//-ggcc ;
	}
Minimizer m21() {
  double t = 2*hmin;
  double xmin[6]= {2.0*hmin,2,2,2,2,2};
  double xmax[6]= {2.0*hmax,t,t,t,t,t};
	Minimizer M(trialcount,6,0,xmin,xmax);
	M.func = t21;
	return M;
}
trialdata d21(m21(),"ID BIXPCGW: cc:3bl: d21: Marchal, gamma4L(quarter) > -0.0057");




////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t22(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = gamma4L(y[0],y[1],y[2],y[3],y[4],y[5]) - 0.0057; //ggcc;
	}
//
void c22(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = 2.3 - dih_y(y[0],y[1],y[2],y[3],y[4],y[5]);
};
Minimizer m22() {
  double t = sqrt(8.0);
  double xmin[6]= {2.0*hmin,2,2,2,2,2};
  double xmax[6]= {2.0*hmax,t,t,t,t,t};
	Minimizer M(trialcount,6,1,xmin,xmax);
	M.func = t22;
	M.cFunc = c22;
	return M;
}
trialdata d22(m22(),"ID BIXPCGW: cc:3bl: d22: Marchal, dih > 2.3 ==> gamma4L() > 0.0057");


double xxmin(int i) {
  if (i==0) { return 2.0; }
  if (i==1) { return 2.0*hmin + eps; }
  return 2*hmax + eps;
}
double xxmax(int i) {
  if (i==0) {return 2*hmin - eps; }
  if (i==1) {return 2.0*hmax - eps; }
  return sqrt(8.0);
}



////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t25(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = gamma4Lwt(y[0],y[1],y[2],y[3],y[4],y[5]) - 0.0560305 + 0.0445813 * dih_y(y[0],y[1],y[2],y[3],y[4],y[5]);
	}
Minimizer m25(int i2,int i3,int i4,int i5,int i6) {
  double xmin[6]= {xxmin(1),xxmin(i2),xxmin(i3),xxmin(i4),xxmin(i5),xxmin(i6)};
  double xmax[6]= {xxmax(1),xxmax(i2),xxmax(i3),xxmax(i4),xxmax(i5),xxmax(i6)}; 
	Minimizer M(40,6,1,xmin,xmax);
	M.func = t25;
	M.cFunc = smallrady;
	return M;
}
// d25 in main().

////////// NEW INEQ
// this is minimized.  failure reported if min is negative.
void t25a(int numargs,int whichFn,double* y, double* ret,void*) {
  *ret = gamma23Lwt(y[0],y[1],y[2],y[3],y[4],y[5]) - 0.0560305 + 0.0445813 * dih_y(y[0],y[1],y[2],y[3],y[4],y[5]);
	}
Minimizer m25a(int i2,int i3,int i4,int i5,int i6) {
  double xmin[6]= {xxmin(1),xxmin(i2),xxmin(i3),xxmin(i4),xxmin(i5),xxmin(i6)};
  double xmax[6]= {xxmax(1),xxmax(i2),xxmax(i3),xxmax(i4),xxmax(i5),xxmax(i6)}; 
	Minimizer M(40,6,3,xmin,xmax);
	M.func = t25a;
	M.cFunc = bigradysmallrafy;
	return M;
}
// d25a in main().


int main()
{
double xmin[6];

  // d25 has many cases:
for (int i2=0;i2<3;i2++)
for (int i3=i2;i3<3;i3++)
for (int i4=0;i4<3;i4++)
for (int i5=0;i5<3;i5++)
for (int i6=0;i6<3;i6++)
  {
xmin[0]=xxmin(1); xmin[1]=xxmin(i2); xmin[2]=xxmin(i3); xmin[3]=xxmin(i4); xmin[4]=xxmin(i5); xmin[5]=xxmin(i6);
if (rady(xmin[0],xmin[1],xmin[2],xmin[3],xmin[4],xmin[5])> s2) continue;
else 
{
trialdata d25(m25(i2,i3,i4,i5,i6),"ID ZTGIJCF: 5:bl: d25: Marchal, gamma4Lwt >=  0.0560305 - 0.0445813 dih, many cases ");
}
  }

  // d25a has many cases:
for (int i2=0;i2<3;i2++)
for (int i3=0;i3<3;i3++)
for (int i4=0;i4<3;i4++)
for (int i5=0;i5<3;i5++)
for (int i6=0;i6<3;i6++)
  {
    xmin[0]=xxmin(1); xmin[1]=xxmin(i2); xmin[2]=xxmin(i3); xmin[3]=xxmin(i4); xmin[4]=xxmin(i5); xmin[5]=xxmin(i6);
    if (radf(xmin[0],xmin[1],xmin[5])> s2) continue;
    else if (radf(xmin[0],xmin[2],xmin[4])> s2) continue;
    else 
{
  //trialdata d25a(m25a(i2,i3,i4,i5,i6),"ID ZTGIJCF: 5:bl: d25a: Marchal, gamma23Lwt >=  0.0560305 - 0.0445813 dih, many cases ");
}
  }

}
