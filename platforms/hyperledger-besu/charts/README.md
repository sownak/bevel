[//]: # (##############################################################################################)
[//]: # (Copyright Accenture. All Rights Reserved.)
[//]: # (SPDX-License-Identifier: Apache-2.0)
[//]: # (##############################################################################################)

# Charts for Hyperledger Besu components

## About
This folder contains the helm charts which are used for the deployment of the Hyperledger Besu components. Each helm that you can use has the following keys and you need to set them. The `global.cluster.provider` is used as a key for the various cloud features enabled. Also you only need to specify one cloud provider, **not** both if deploying to cloud. As of writing this doc, AWS is fully supported.

```yaml
global:
  serviceAccountName: vault-auth
  cluster:
    provider: aws   # choose from: minikube | aws
    cloudNativeServices: false  # future: set to true to use Cloud Native Services 
    kubernetesUrl: "https://yourkubernetes.com" # Provide the k8s URL, ignore if not using Hashicorp Vault
  vault:
    type: hashicorp # choose from hashicorp | kubernetes
    network: besu   # must be besu for these charts
    # Following are necessary only when hashicorp vault is used.
    address: http://vault.url:9001
    authPath: supplychain
    secretEngine: secretsv2
    secretPrefix: "data/supplychain"
    role: vault-role
```

## Usage

### Pre-requisites

- Kubernetes Cluster (either Managed cloud option like EKS or local like minikube)
- Accessible and unsealed Hahsicorp Vault (if using Vault)
- Configured Ambassador AES (if using Ambassador as proxy)
- Update the dependencies
  ```
  helm dependency update besu-genesis
  helm dependency update besu-node
  ```

### _Without Proxy or Vault_

```bash
helm install genesis ./besu-genesis --namespace supplychain-bes --create-namespace --values ./values/noproxy-and-novault/genesis.yaml

# Install the validators
helm install validator-1 ./besu-node --namespace supplychain-bes --values ./values/noproxy-and-novault/validator.yaml
helm install validator-2 ./besu-node --namespace supplychain-bes --values ./values/noproxy-and-novault/validator.yaml
helm install validator-3 ./besu-node --namespace supplychain-bes --values ./values/noproxy-and-novault/validator.yaml
helm install validator-4 ./besu-node --namespace supplychain-bes --values ./values/noproxy-and-novault/validator.yaml

# spin up a besu and tessera node pair
helm install member-1 ./besu-node --namespace supplychain-bes --values ./values/noproxy-and-novault/txnode.yaml
```
### To setup another member in a different namespace

```bash
# Get the genesis and static nodes from existing member and place in besu-genesis/files
cd ./besu-genesis/files/
kubectl --namespace supplychain-bes get configmap besu-peers -o jsonpath='{.data.static-nodes\.json}' > static-nodes.json
kubectl --namespace supplychain-bes get configmap besu-genesis  -o jsonpath='{.data.genesis\.json}' > genesis.json

# Run secondary genesis
cd ../..
helm install genesis ./besu-genesis --namespace carrier-bes --create-namespace --values ./values/noproxy-and-novault/genesis-sec.yaml

helm install member-2 ./besu-node --namespace carrier-bes --values ./values/noproxy-and-novault/txnode-sec.yaml
```

### _With Ambassador proxy and Vault_
Replace the `global.vault.address`, `global.cluster.kubernetesUrl` and `global.proxy.externalUrlSuffix` in all the files in `./values/proxy-and-vault/` folder.

```bash
helm install genesis ./besu-genesis --namespace supplychain-bes --create-namespace --values ./values/proxy-and-vault/genesis.yaml

# !! IMPORTANT !! - If you use bootnodes, please set `quorumFlags.usesBootnodes: true` in the override yaml files
# for validator.yaml, txnode.yaml
helm install validator-1 ./besu-node --namespace supplychain-bes --values ./values/proxy-and-vault/validator.yaml
helm install validator-2 ./besu-node --namespace supplychain-bes --values ./values/proxy-and-vault/validator.yaml
helm install validator-3 ./besu-node --namespace supplychain-bes --values ./values/proxy-and-vault/validator.yaml
helm install validator-4 ./besu-node --namespace supplychain-bes --values ./values/proxy-and-vault/validator.yaml

# spin up a besu and tessera node pair
helm install member-1 ./besu-node --namespace supplychain-bes --values ./values/proxy-and-vault/txnode.yaml

```
### To setup another member in a different namespace

Update the `global.proxy.externalUrlSuffix` and `tessera.tessera.peerNodes` in file `./values/proxy-and-vault/txnode-sec.yaml`
```bash
# Get the genesis and static nodes from existing member and place in besu-genesis/files
cd ./besu-genesis/files/
kubectl --namespace supplychain-bes get configmap besu-peers -o jsonpath='{.data.static-nodes\.json}' > static-nodes.json
kubectl --namespace supplychain-bes get configmap besu-genesis  -o jsonpath='{.data.genesis\.json}' > genesis.json

# Run secondary genesis
cd ../..
helm install genesis ./besu-genesis --namespace carrier-bes --create-namespace --values ./values/proxy-and-vault/genesis-sec.yaml

helm install member-2 ./besu-node --namespace carrier-bes --values ./values/proxy-and-vault/txnode-sec.yaml
```

### API Calls
Once deployed, services are available as follows on the address as provided in your `global.proxy.externalUrlSuffix`.

```bash
# HTTP RPC API
curl -v -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://member-1rpc.test.yourdomain.com

# which should return (confirming that the node running the JSON-RPC service is syncing):
{
  "jsonrpc" : "2.0",
  "id" : 1,
  "result" : "0x4e9"
}
```

### Clean-up

To clean up, just uninstall the helm releases.
```bash
helm uninstall --namespace supplychain-bes validator-1
helm uninstall --namespace supplychain-bes validator-2
helm uninstall --namespace supplychain-bes validator-3
helm uninstall --namespace supplychain-bes validator-4
helm uninstall --namespace supplychain-bes member-1
helm uninstall --namespace supplychain-bes genesis

helm uninstall --namespace carrier-bes member-2
helm uninstall --namespace carrier-bes genesis

```