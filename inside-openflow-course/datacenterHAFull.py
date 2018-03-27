"""
  [ s1 ]------[ s2 ]--- ... ---[ s# ]
   |,----------'                |     Each ToR switch connects to corresponding root switch
   ||,--------------------------'     (i.e. s1r1, s2r1 connects to s1)
   |-[ s1r1 ]=.  [ s1r2 ]=.     ...      [ s1r# ]=.
   |-[ s2r1 ]=|  [ s2r2 ]=|     ...      [ s2r# ]=|
   |    ...   |     ...   |     ...         ...   |
   `-[ s#r1 ]=|  [ s#r2 ]=|     ...      [ s#r# ]=|
        |           |                      |
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
            rack = self.buildRack(i, hostsPerRack=hostsPerRack, switchesPerRack=rootSwitches)
            for switch in rack:
                for rootSwitch in HASwitches:
                    self.addLink(rootSwitch, switch)

    def buildRack( self, loc, hostsPerRack, switchesPerRack=2 ):
        "Build a rack of hosts with a given number of TOR switches"

        switches = []
        for i in irange(1, switchesPerRack):
            dpid = ( loc * 16 ) + i
            switches.append(self.addSwitch( 's%sr%s' % (i, loc), dpid='%x' % dpid ))

        for n in irange( 1, hostsPerRack ):
            host = self.addHost('h%sr%s' % (n, loc))
            for tor in switches:
                self.addLink(tor, host)

        return switches

topos = {'dc_ha_full': DatacenterHARootConfigurableTopo}
