"""
[ s1 ]================================.
  ,---'       |           |           |
  [ s1r1 ]=.  [ s1r2 ]=.   ...      [ s1r# ]=.
  [ h1r1 ]-|  [ h1r2 ]-|   ...      [ h1r# ]-|
  [ h2r1 ]-|  [ h2r2 ]-|   ...      [ h2r# ]-|
    ...    |    ...    |   ...        ...    |
  [ h#r1 ]-'  [ h#r2 ]-'   ...      [ h4r# ]-'
  """

from mininet.topo import Topo
from mininet.util import irange

class DatacenterConfigurableTopo( Topo ):
    def build( self, racks=4, hostsPerRack=4 ):
        rootSwitch = self.addSwitch( 's1' )
        for i in irange( 1, racks ):
            rack = self.buildRack(i, hostsPerRack=hostsPerRack)
            for switch in rack:
                self.addLink(rootSwitch, switch)

    def buildRack( self, loc, hostsPerRack ):
        "Build a rack of hosts with a TOR switch"

        dpid = ( loc * 16 ) + 1
        switch = self.addSwitch( 's1r%s' % loc, dpid='%x' % dpid )

        for n in irange( 1, hostsPerRack ):
            host = self.addHost('h%sr%s' % (n, loc))
            self.addLink(switch, host)

        return [switch]

topos = {'dcconfigurable': DatacenterConfigurableTopo}
