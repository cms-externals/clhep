//
// Thanks to Bob McElrath for this test
//

#include <fstream>

#include "CLHEP/HepMC/GenEvent.h"
#include "CLHEP/HepPDT/ParticleDataTable.hh"
#include "CLHEP/HepPDT/ParticleData.hh"
#include "CLHEP/HepPDT/DefaultConfig.hh"
#include "CLHEP/HepPDT/TableBuilder.hh"
#include "CLHEP/HepPDT/ParticleDataTableT.hh"
#include "CLHEP/HepPDT/TempParticleData.hh"
#include "CLHEP/Vector/LorentzVector.h"

int main(int argc,char* argv[]) 
{
  HepMC::GenEvent* p_event;
  
  p_event = new HepMC::GenEvent();

  // define an output stream
  std::ofstream os( "testPrintBug.out" );
  
  for(int i=0; i<10; i++) {
    CLHEP::HepLorentzVector vector(1.0,1.0,1.0,1.0);
    HepMC::GenVertex* vertex = new HepMC::GenVertex(vector,i);
    for(int j=0; j<3; j++) {
      HepMC::GenParticle* particle = new HepMC::GenParticle(vector,1,2);
      vertex->add_particle_in(particle);
    }
    for(int j=0; j<3; j++) {
      HepMC::GenParticle* particle = new HepMC::GenParticle(vector,1,2);
      vertex->add_particle_out(particle);
    }
    p_event->add_vertex(vertex);
  }
  p_event->print(os);
}
