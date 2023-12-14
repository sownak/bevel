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
    chart: {{ charts_dir }}/bevel-vault-mgmt
    sourceRef:
      kind: GitRepository
      name: flux-{{ network.env.type }}
      namespace: flux-{{ network.env.type }}
  values:
    cluster:
      provider: aws
      cloudNativeServices: false
      kubernetes_url: {{ kubernetes_url }}
    images:
      alpineutils: {{ network.docker.url }}/alpine-utils:1.0
      pullSecret: regcred

    vault:
      serviceAccountName: vault-auth
      role: vault-role
      address: {{ vault.url }}
      authPath: {{ component_auth }}
      policy: vault-crypto-{{ component_ns }}-{{ name }}-ro
      policyData: {{ policydata | to_nice_json }}
      secretPath: {{ vault.secret_path | default(name)}}
