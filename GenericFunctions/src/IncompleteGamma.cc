// -*- C++ -*-
// $Id: IncompleteGamma.cc,v 1.3 2003/09/06 14:04:14 boudreau Exp $

#include "CLHEP/GenericFunctions/IncompleteGamma.hh"
#include <assert.h>
#include <math.h>
namespace Genfun {
FUNCTION_OBJECT_IMP(IncompleteGamma)

const int          IncompleteGamma::ITMAX =100;
const double       IncompleteGamma::EPS   =3.0E-7;
const double       IncompleteGamma::FPMIN =1.0e-30;    


IncompleteGamma::IncompleteGamma():
  _a("a", 1.0, 0,10)
{}

IncompleteGamma::IncompleteGamma(const IncompleteGamma & right):
_a(right._a) {
}

IncompleteGamma::~IncompleteGamma() {
}

double IncompleteGamma::operator() (double x) const {

  assert(x>=0.0 && _a.getValue() > 0.0);

  if (x < (_a.getValue()+1.0)) 
    return _gamser(_a.getValue(),x,_logGamma(_a.getValue()));
  else 
    return 1.0-_gammcf(_a.getValue(),x,_logGamma(_a.getValue()));  
}

Parameter & IncompleteGamma::a() {
  return _a;
}

/* ------------------Incomplete gamma function-----------------*/
/* ------------------via its series representation-------------*/
double  IncompleteGamma::_gamser(double a, double x, double logGamma) const {
    double n;
    double ap,del,sum;

    ap=a;
    del=sum=1.0/a;
    for (n=1;n<ITMAX;n++) {
        ++ap;
        del *= x/ap;
        sum += del;
        if (fabs(del) < fabs(sum)*EPS) return sum*exp(-x + a*log(x) - logGamma);
    }
    assert(0);
    return 0;
}        

/* ------------------Incomplete gamma function complement------*/
/* ------------------via its continued fraction representation-*/

double  IncompleteGamma::_gammcf(double a, double x, double logGamma) const {

    double an,b,c,d,del,h;
    int i;

    b = x + 1.0 -a;
    c = 1.0/FPMIN;
    d = 1.0/b;
    h = d;
    for (i=1;i<ITMAX;i++) {
        an = -i*(i-a);
        b+=2.0;
        d=an*d+b;
        if (fabs(d) < FPMIN) d = FPMIN;
        c = b+an/c;
        if (fabs(c) < FPMIN) c = FPMIN;
        d = 1.0/d;
        del=d*c;
        h *= del;
        if (fabs(del-1.0) < EPS) return exp(-x+a*log(x)-logGamma)*h;  
    }
    assert(0);
    return 0;
}




} // namespace Genfun
