#!/usr/bin/python

from mininet.topo import Topo
from mininet.cli import CLI
from mininet.log import setLogLevel
from mininet.net import Mininet
from mininet.node import RemoteController, OVSSwitch

class MinimalTopo(Topo):
    def build(self):
        h1 = self.addHost('h1')
        h2 = self.addHost('h2')

        s1 = self.addSwitch('s1')

        self.addLink(s1, h1)
        self.addLink(s1, h2)

def runCustomMiniTopo():
    topo = MinimalTopo()

    net = Mininet(
        topo=topo,
        controller=lambda name: RemoteController(name, ip='127.0.0.1'),
        switch=OVSSwitch,
        autoSetMacs=True)
    net.start()

    CLI(net)

    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    runCustomMiniTopo()

topos = {'minimal': MinimalTopo}
