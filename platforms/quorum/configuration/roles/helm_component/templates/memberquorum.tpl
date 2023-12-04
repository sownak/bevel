apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: {{ component_name }}
  namespace: {{ component_ns }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  releaseName: {{ component_name }}
  interval: 1m
  chart:
   spec:
    chart: {{ charts_dir }}/quorum-member-node
    sourceRef:
      kind: GitRepository
      name: flux-{{ network.env.type }}
      namespace: flux-{{ network.env.type }}
  values:
    replicaCount: 1
    metadata:
      namespace: {{ component_ns }}
      labels:
    images:
      node: quorumengineering/quorum:{{ network.version }}
      alpineutils: ghcr.io/hyperledger/bevel-alpine:latest
    node:
      name: {{ peer.name }}
{% if add_new_org %}
{% if network.config.consensus == 'raft' %}
      peer_id: {{ peer_id | int }}
{% endif %}
{% endif %}
      status: {{ node_status }}
      consensus: {{ consensus }}
      subject: {{ peer.subject }}
      mountPath: /etc/quorum/qdata
      imagePullSecret: regcred
      keystore: keystore_1
{% if org.cloud_provider == 'minikube' %}
      servicetype: NodePort
{% else %}
      servicetype: ClusterIP
{% endif %}
      lock: {{ peer.lock | lower }}
      ports:
        rpc: {{ peer.rpc.port }}
{% if network.config.consensus == 'raft' %}
        raft: {{ peer.raft.port }}
{% endif %}
        quorum: {{ peer.p2p.port }}

    tm:
      type: {{ network.config.transaction_manager }}

    vault:
      type: {{ vault.type | default("hashicorp") }}
      address: {{ vault.url }}
      secretprefix: {{ vault.secret_path | default('secretsv2') }}/data/{{ component_ns }}/crypto/{{ peer.name }}
      serviceaccountname: vault-auth
      keyname: quorum
      tm_keyname: tm
      role: vault-role
      authpath: quorum{{ name }}
      
{% if network.config.transaction_manager != "none" %}
    tessera:
{% if network.config.tm_tls == 'strict' %}
      url: "https://{{ peer.name }}.{{ external_url }}:{{ peer.transaction_manager.ambassador }}"
{% else %}
      url: "http://{{ peer.name }}.{{ external_url }}:{{ peer.transaction_manager.ambassador }}"
{% endif %}
      clienturl: "http://{{ peer.name }}-tessera:{{ peer.transaction_manager.clientport }}" #TODO: Enable tls strict for q2t
{% endif %}
    genesis: {{ genesis }}
    staticnodes:
      {{ staticnodes }}
{% if network.env.proxy == 'ambassador' %}
    proxy:
      provider: "ambassador"
      external_url: {{ external_url }}
      quorumport: {{ peer.p2p.ambassador }}
{% if network.config.consensus == 'raft' %}
      portRaft: {{ peer.raft.ambassador }}
{% endif %}
{% else %}
    proxy:
      provider: none
      external_url: {{ name }}.{{ component_ns }}
      quorumport: {{ peer.p2p.port }}
{% if network.config.consensus == 'raft' %}
      portRaft: {{ peer.raft.port }}
{% endif %}
{% endif %}
    storage:
      storageclassname: {{ sc_name }}
      storagesize: 1Gi
      dbstorage: 1Gi
