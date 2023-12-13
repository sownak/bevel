apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: {{ name }}-operations-console
  namespace: {{ component_ns }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  interval: 1m
  releaseName: {{ name }}-operations-console
  chart:
    spec:
      interval: 1m
      sourceRef:
        kind: GitRepository
        name: flux-{{ network.env.type }}
        namespace: flux-{{ network.env.type }}
      chart: {{ charts_dir }}/fabric-operations-console
  values:
    metadata:
      namespace: {{ component_ns }}
      images:
        couchdb: {{ docker_url }}/{{ couchdb_image[network.version] }}
        console: {{ docker_url }}/{{ fabric_console_image }}
        configtxlator: {{ docker_url }}/{{ fabric_tools_image[network.version] }}
    storage:
      couchdb:
        storageclassname: {{ sc_name }}
        storagesize: 512Mi
    service:
      name: {{ name }}console
      default_consortium: {{ default_consortium }}
      serviceaccountname: default
{% if network.docker.username is defined and network.docker.password is defined %}
      imagesecretname: regcred
{% else %}
      imagesecretname: ""
{% endif %}
      servicetype: ClusterIP
      ports:
        console:
          clusteripport: 3000
        couchdb:
          clusteripport: 5984
    proxy:    
      provider: "{{ network.env.proxy }}"
      external_url_suffix: {{ item.external_url_suffix }}
