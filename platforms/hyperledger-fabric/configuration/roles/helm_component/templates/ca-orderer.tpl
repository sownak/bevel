apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: {{ component_name }}-ca
  namespace: {{ component_name }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  interval: 1m
  releaseName: {{ component_name }}-ca
  chart:
    spec:
      interval: 1m
      sourceRef:
        kind: GitRepository
        name: flux-{{ network.env.type }}
        namespace: flux-{{ network.env.type }}
      chart: {{ charts_dir }}/fabric-ca-server   
  values:
{% if network.env.annotations is defined %}
    deployment:
      annotations:
{% for item in network.env.annotations.deployment %}
{% for key, value in item.items() %}
        - {{ key }}: {{ value | quote }}
{% endfor %}
{% endfor %}
    annotations:  
      service:
{% for item in network.env.annotations.service %}
{% for key, value in item.items() %}
        - {{ key }}: {{ value | quote }}
{% endfor %}
{% endfor %}
      pvc:
{% for item in network.env.annotations.pvc %}
{% for key, value in item.items() %}
        - {{ key }}: {{ value | quote }}
{% endfor %}
{% endfor %}
{% endif %}
    metadata:
      namespace: {{ component_name | e }}
      images:
        alpineutils: {{ docker_url }}/{{ alpine_image }}
        ca: {{ docker_url }}/{{ ca_image[network.version] }}
    server:
      name: {{ component_services.ca.name }}
      tlsstatus: true
      admin: {{ component }}-admin
{% if component_services.ca.configpath is defined %}
      configpath: conf/fabric-ca-server-config-{{ component }}.yaml
{% endif %}        
    storage:
      storageclassname: {{ sc_name }}
      storagesize: 512Mi 
    vault:
      role: vault-role
      address: {{ vault.url }}
{% if item.k8s.cluster_id is defined %}
      authpath: {{ item.k8s.cluster_id }}{{ component_name }}-auth
{% else %}
      authpath: {{ network.env.type }}{{ component_name }}-auth
{% endif %}
      secretcert: {{ vault.secret_path | default('secretsv2') }}/data/crypto/ordererOrganizations/{{ component_name | e }}/ca?ca.{{ component_name | e }}-cert.pem
      secretkey: {{ vault.secret_path | default('secretsv2') }}/data/crypto/ordererOrganizations/{{ component_name | e }}/ca?{{ component_name | e }}-CA.key
      secretadminpass: {{ vault.secret_path | default('secretsv2') }}/data/credentials/{{ component_name | e }}/ca/{{ component }}?user
      serviceaccountname: vault-auth
      type: {{ vault.type | default("hashicorp") }}
{% if network.docker.username is defined and network.docker.password is defined  %}
      imagesecretname: regcred
{% else %}
      imagesecretname: ""
{% endif %}
    service:
      servicetype: ClusterIP
      ports:
        tcp:
          clusteripport: {{ component_services.ca.grpc.port }}
{% if component_services.ca.grpc.nodePort is defined %}
          nodeport: {{ component_services.ca.grpc.nodePort }}
{% endif %}
    proxy:
      provider: {{ network.env.proxy }}
      type: orderer
      external_url_suffix: {{ external_url_suffix }}
