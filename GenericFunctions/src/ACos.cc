// -*- C++ -*-
// $Id: ACos.cc,v 1.3 2003/09/06 14:04:14 boudreau Exp $
#include "CLHEP/GenericFunctions/ACos.hh"
#include "CLHEP/GenericFunctions/Sqrt.hh"
#include "CLHEP/GenericFunctions/Square.hh"
#include <assert.h>

namespace Genfun {
FUNCTION_OBJECT_IMP(ACos)

ACos::ACos()
{}

ACos::~ACos() {
}

ACos::ACos(const ACos & right) 
{  }


double ACos::operator() (double x) const {
  return acos(x);
}


Derivative ACos::partial(unsigned int index) const {
  assert(index==0);

  Square square;
  Sqrt   root;

  const AbsFunction & fPrime = - 1.0/root(1.0-square) ;
  return Derivative(& fPrime);
}

} // end namespace Genfun 


