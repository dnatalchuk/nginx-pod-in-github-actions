
## Installation
* Go through the kind installation process from their [documentation](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) 

## Documentation: 

* Project file structure:

```
.
├── CODEOWNERS
├── README.md
├── cluster.yml
├── shell.nix
├── site-deployment.yml
├── site-service.yml
└── src
    ├── Dockerfile
    ├── index.html
    └── nginx.conf
```

* Install required dependencies/packages like `kind`;
* `Hello World` website has been Dockerized under the `src` folder, `nginx.conf` has been created and Docker image build steps are defined in `src/Dockerfile`. `nginx:alpine` source Docker image has been selected because of smaller image size to improve container build/startup times and reduced resource usage; reduced package set minimizes the attack surface, making the container less susceptible to potential security vulnerabilities, etc.;
* Presenting Docker image build logs below:

```
❯ docker build -t nginx_pod_in_github_actions:1.0.0 .
[+] Building 1.3s (9/9) FINISHED                                                                                                           docker:desktop-linux
 => [internal] load .dockerignore                                                                                                                          0.1s
 => => transferring context: 2B                                                                                                                            0.0s
 => [internal] load build definition from Dockerfile                                                                                                       0.2s
 => => transferring dockerfile: 369B                                                                                                                       0.1s
 => [internal] load metadata for docker.io/library/nginx:alpine                                                                                            0.0s
 => [1/4] FROM docker.io/library/nginx:alpine                                                                                                              0.0s
 => [internal] load build context                                                                                                                          0.0s
 => => transferring context: 62B                                                                                                                           0.0s
 => CACHED [2/4] WORKDIR /src                                                                                                                              0.0s
 => CACHED [3/4] COPY ./nginx.conf /etc/nginx/nginx.conf                                                                                                   0.0s
 => CACHED [4/4] COPY ./index.html /hello/                                                                                                           0.0s
 => exporting to image                                                                                                                                     0.0s
 => => exporting layers                                                                                                                                    0.0s
 => => writing image sha256:e2e19e2e171569cd7209f8977e83b2275751b1ce58e30a4483f2340a429d7a86                                                               0.0s
 => => naming to docker.io/library/nginx_pod_in_github_actions:1.0.0
```

* Once the `Hello World` website Docker has been built - the next `site-deployment.yml` manifest has been updated with container spec point to the `nginx_pod_in_github_actions:1.0.0` image;

* Next step was to bootstrap/create a kind cluster running the `kind create cluster` command:

```
kind create cluster
Creating cluster "kind" ...
 • Ensuring node image (kindest/node:v1.27.3) 🖼  ...
 ✓ Ensuring node image (kindest/node:v1.27.3) 🖼
 • Preparing nodes 📦   ...
 ✓ Preparing nodes 📦 
 • Writing configuration 📜  ...
 ✓ Writing configuration 📜
 • Starting control-plane 🕹️  ...
 ✓ Starting control-plane 🕹️
 • Installing CNI 🔌  ...
 ✓ Installing CNI 🔌
 • Installing StorageClass 💾  ...
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind
```

* Once the `kind` cluster was created - the next earlier-built Docker image has been loaded to the kind control plane as below:

```
kind load docker-image nginx_pod_in_github_actions:1.0.0 --name kind

Image: "nginx_pod_in_github_actions:1.0.0" with ID "sha256:891dec4137fa2ca770445b5b48ea30bfb0d25e979d10fb649d0df1164b53beb6" not yet present on node "kind-control-plane", loading...
```

* Next, the `Hello World` deployment and service were created and logs are presented below:

```
kubectl apply -f site-deployment.yml
deployment.apps/hello-world created

kubectl get pods -n default
NAME                           READY   STATUS    RESTARTS   AGE
hello-world-75c64c5ccf-5gbjg   1/1     Running   0          16s

kubectl apply -f site-service.yml
service/hello-world-service created
```

* Since we use the `NodePort` service type - in order to access the app locally, `kubectl port-forward service/hello-world-service 8080:8080` command has been executed:

```
❯ kubectl port-forward service/hello-world-service 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
Handling connection for 8080
```
## GitHub actions implementation details:

* GitHub actions logic is defined as below:

```
name: Hello-World presentation

on:
  push:
    branches: [ "master" ]
  pull_request:
    branches: [ "master" ]

jobs:
  nginx_pod_in_github_actions-test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Building "hello-world" Docker image, creating "kind" cluster and deploying app
      run: ./.github/scripts/deploy.sh
      shell: bash
```
* All Docker image build and deployment logic is defined in `./.github/scripts/deploy.sh` bash script;
