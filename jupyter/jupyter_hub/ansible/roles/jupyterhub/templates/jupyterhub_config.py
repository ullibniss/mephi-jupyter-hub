import os
from dockerspawner import SwarmSpawner

c = get_config()
c.JupyterHub.spawner_class = SwarmSpawner
c.JupyterHub.confirm_no_ssl = True
c.JupyterHub.hub_ip = "0.0.0.0"
c.SwarmSpawner.use_internal_ip = True
#c.SwarmSpawner.image = 'zonca/jupyterhub-datascience-systemuser'
c.SwarmSpawner.image = 'quay.io/jupyter/tensorflow-notebook'
c.SwarmSpawner.network_name = "jupyterhub_jupyternet"
c.SwarmSpawner.extra_host_config = {'network_mode': c.SwarmSpawner.network_name}
c.SwarmSpawner.start_timeout = 300
c.SwarmSpawner.hub_ip_connect = "10.0.3.1"