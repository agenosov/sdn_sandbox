"""
  [ s1 ]------[ s2 ]--- ... ---[ s# ]
   |,----------'                |     Each ToR switch connects to every
   ||,--------------------------'     root switch.
  [ s1r1 ]=.  [ s1r2 ]=.   ...      [ s1r# ]=.
  [ h1r1 ]-|  [ h1r2 ]-|   ...      [ h1r# ]-|
  [ h2r1 ]-|  [ h2r2 ]-|   ...      [ h2r# ]-|
    ...    |    ...    |   ...        ...    |
  [ h#r1 ]-'  [ h#r2 ]-'   ...      [ h4r# ]-'
  """

from mininet.topo import Topo
from mininet.util import irange

class DatacenterHARootConfigurableTopo( Topo ):

    def build( self, racks=4, hostsPerRack=4, rootSwitches=2 ):
        if rootSwitches >= 16:
            raise Exception("Use less than 16 root switches")

        HASwitches = []
        lastRootSwitch = None
        for i in irange(1, rootSwitches):
            rootSwitch = self.addSwitch( 's%s' % i )
            HASwitches.append(rootSwitch)

            if lastRootSwitch:
                self.addLink(lastRootSwitch, rootSwitch)
            lastRootSwitch = rootSwitch

        # Make the final link from the last switch to the first switch
        if rootSwitches > 1:
            self.addLink(lastRootSwitch, HASwitches[0])

        for i in irange( 1, racks ):
            rack = self.buildRack(i, hostsPerRack=hostsPerRack)
            for switch in rack:
                for rootSwitch in HASwitches:
                    self.addLink(rootSwitch, switch)

    def buildRack( self, loc, hostsPerRack ):
        "Build a rack of hosts with a TOR switch"

        dpid = ( loc * 16 ) + 1
        switch = self.addSwitch( 's1r%s' % loc, dpid='%x' % dpid )

        for n in irange( 1, hostsPerRack ):
            host = self.addHost('h%sr%s' % (n, loc))
            self.addLink(switch, host)

        return [switch]

topos = {'dc_ha_root': DatacenterHARootConfigurableTopo}
