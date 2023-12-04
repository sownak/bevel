[//]: # (##############################################################################################)
[//]: # (Copyright Accenture. All Rights Reserved.)
[//]: # (SPDX-License-Identifier: Apache-2.0)
[//]: # (##############################################################################################)

<a name = "deploy nms-tls"></a>
# Nms Deployment

- [Nms-tls Deployment Helm Chart](#Nms-tls-deployment-helm-chart)
- [Prerequisites](#prerequisites)
- [Chart Structure](#chart-structure)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

<a name = "nms-tls-deployment-helm-chart"></a>
## nms-tls Deployment Helm Chart
---
This [Helm chart](https://github.com/hyperledger/bevel/tree/develop/platforms/r3-corda/charts/corda-networkmap-tls) deploys a networkmap sevice with TLS enabled.

<a name = "prerequisites"></a>
## Prerequisites
---
Before deploying the chart please ensure you have the following prerequisites:

- NetworkMap and Node's database up and running.
- Kubernetes cluster up and running.
- A HashiCorp Vault instance is set up and configured to use Kubernetes service account token-based authentication.
- The Vault is unsealed and initialized.
- Helm is installed.

<a name = "chart-structure"></a>
## Chart Structure
---
This chart has following structue:

```
  
  ├── nms-tls
  │   ├── Chart.yaml
  │   ├── templates
  │   │   ├── deployment.yaml
  │   │   ├── Volume.yaml
  │   │   └── service.yaml
  │   └── values.yaml
```

Type of files used:

- `templates`       : This directory contains the Kubernetes manifest templates that define the resources to be deployed.
- `deployment.yaml` : This file sets up a deployment with multiple containers, mounts volumes, retrieves secrets from Vault, and performs some initialization tasks before starting the main containers.
- `volume.yaml`     : These PVCs can be used to provide persistent storage for the network map service deployment.
- `service.yaml`    : This file defines a Kubernetes Service with multiple ports for protocols and targets, and supports Ambassador proxy annotations for specific configurations when using the "ambassador" proxy provider.
- `chart.yaml`      : Provides metadata about the chart, such as its name, version, and description.
- `values.yaml`     : Contains the default configuration values for the chart. It includes configuration for the image, storage, service, vault and ambassador.

<a name = "configuration"></a>
## Configuration
---
The [values.yaml](https://github.com/hyperledger/bevel/blob/develop/platforms/r3-corda/charts/corda-networkmap-tls/values.yaml) file contains configurable values for the Helm chart. We can modify these values according to the deployment requirements. Here are some important configuration options:

## Parameters
---

### Name

| Name       | Description                                        | Default Value |
| -----------| -------------------------------------------------- | ------------- |
| name       | Provide the name of the node                       | network-map   |

### Metadata

| Name            | Description                                              | Default Value |
| ----------------| -------------------------------------------------------- | ------------- |
| namespace       | Provide the namespace for the nms Generator              | default       |

### Image

| Name                     | Description                                                                                | Default Value   |
| ------------------------ | -------------------------------------------------------                                    | --------------- |
| initContainerName        | Provide the alpine utils image, which is used for all init-containers of deployments/jobs  | ""              |
| containerName            | Provide the containerName of image                                                         | ""              |
| imagePullSecret          | Provide the image pull secret of image                                                     | regcred         |
| env                      | Provide enviroment variable for container image                                            | ""              |

### Service

| Name                  | Description                                                    | Default Value   |
| --------------------- | ------------------------------------------                     | -------------   |
| type                  | Provide the type of service                                    | "NodePort"      |
| port                  | Provide the NMS service port                                   | "30007"         |
| nodePort              | Provide the node port for node service to be accessible outside| "30050"         |


### storage

| Name                  | Description                               | Default Value   |
| --------------------- | ------------------------------------------| -------------   |
| Memory                | Provide the memory for node               | "4Gi"           |


### Vault

| Name                      | Description                                                               | Default Value   |
| ------------------------- | --------------------------------------------------------------------------| -------------   |
| address                   | Address/URL of the Vault server                                           | ""              |
| role                      | Role used for authentication with Vault                                   | vault-role      |
| authpath                  | Authentication path for Vault                                             | cordanms        |
| secretprefix              | Provide the kubernetes auth backed configured in vault                    | ""              |
| imagesecretname           | specify the name of the Kubernetes secret                                 | ""              |
| serviceaccountname        | To authenticate with the Vault server and retrieve the secrets            |vault-auth-issuer|
| ambassador                | Provides the suffix to be used in external URL                            |""               |


<a name = "deployment"></a>
## Deployment
---

To deploy the nms-tls Helm chart, follow these steps:

1. Modify the [values.yaml](https://github.com/hyperledger/bevel/blob/develop/platforms/r3-corda/charts/corda-networkmap-tls/values.yaml) file to set the desired configuration values.
2. Run the following Helm command to install, upgrade, verify, delete the chart:

To install the chart:
```bash
helm repo add bevel https://hyperledger.github.io/bevel/
helm install <release-name> ./corda-networkmap-tls
```

To upgrade the chart:
```bash
helm upgrade <release-name> ./corda-networkmap-tls
```

To verify the deployment:
```bash
kubectl get jobs -n <namespace>
```
Note : Replace `<namespace>` with the actual namespace where the Job was created. This command will display information about the Job, including the number of completions and the current status of the Job's pods.


To delete the chart: 
```bash
helm uninstall <release-name>
```
Note : Replace `<release-name>` with the desired name for the release.


<a name = "contributing"></a>
## Contributing
---
If you encounter any bugs, have suggestions, or would like to contribute to the [Nms-tls Deployment Helm Chart](https://github.com/hyperledger/bevel/tree/develop/platforms/r3-corda/charts/corda-networkmap-tls), please feel free to open an issue or submit a pull request on the [project's GitHub repository](https://github.com/hyperledger/bevel).

<a name = "license"></a>
## License

This chart is licensed under the Apache v2.0 license.

Copyright &copy; 2023 Accenture

### Attribution

This chart is adapted from the [charts](https://hyperledger.github.io/bevel/) which is licensed under the Apache v2.0 License which is reproduced here:

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
