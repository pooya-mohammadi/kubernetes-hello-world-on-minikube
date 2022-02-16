# kubernetes-hello-world-on-minikube

A Kubernetes Hello World Project for Python Flask.  This project uses [a simple Flask app that returns correct change](https://github.com/noahgift/flask-change-microservice) as the base project and converts it to Kubernetes.
![kubernetes-load-balanced-cluster](https://user-images.githubusercontent.com/58792/111511557-3f45a280-8725-11eb-8e4a-5f5ef787796d.png)

This recipe is in the book Practical MLOps.

![9781098103002](https://user-images.githubusercontent.com/58792/111000927-eb1b7680-8350-11eb-8e24-d41064590fc1.jpeg)


## Assets in Repo

* `Makefile`:  [Builds project](https://github.com/noahgift/kubernetes-hello-world-python-flask/blob/main/Makefile)
* `Dockerfile`:  [Container configuration](https://github.com/noahgift/kubernetes-hello-world-python-flask/blob/main/Dockerfile)
* `app.py`:  [Flask app](https://github.com/noahgift/kubernetes-hello-world-python-flask/blob/main/app.py)
* `kube-hello-change.yaml`: [Kubernetes YAML Config](https://github.com/noahgift/kubernetes-hello-world-python-flask/blob/main/kube-hello-change.yaml)

## Get Started

* Create Python virtual environment `python3 -m venv ~/.kube-hello && source ~/.kube-hello/bin/activate`
* Run `make all` to install python libraries, lint project, including `Dockerfile` and run tests

## Build and Run Docker Container

* Install [Docker Desktop](https://www.docker.com/products/docker-desktop)

* To build the image locally do the following.

`docker build -t flask-change:latest .` or run `make build` which has the same command.

* To verify container run `docker image ls`

* To run do the following:  `docker run -p 8080:8080 flask-change` or run `make run` which has the same command

* In a separate terminal invoke the web service via curl, or run `make invoke` which has the same command 

`curl http://127.0.0.1:8080/change/1/34`

```bash
[
  {
    "5": "quarters"
  }, 
  {
    "1": "nickels"
  }, 
  {
    "4": "pennies"
  }
]
```

* Stop the running docker container by using `control-c` command

## Running Kubernetes On MiniKube

* Verify Kubernetes is working via minicube context

```bash
$ kubectl get nodes
NAME       STATUS   ROLES                  AGE     VERSION
minikube   Ready    control-plane,master   7h44m   v1.23.1
```

* First save your docker image and load it on minikube:

```commandline
make image-export # saves the image
make copy-image # copies it to minikube, in case this didn't work run the code on terminal
minikube ssh # ssh to minikube
docker load -i flask-change.bz2 # load the docker image
```

* then apply the deployment on minikube:

`kubectl apply -f kube-hello-change.yaml` or run `make run-kube` which has the same command

You can see from the config file that a load-balancer along with three nodes is the configured application.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-flask-change-service
spec:
  selector:
    app: hello-python
  ports:
  - protocol: "TCP"
    port: 8080
    targetPort: 8080
    nodePort: 32000 # output port
  type: LoadBalancer

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-python
spec:
  selector:
    matchLabels:
      app: hello-python
  replicas: 3
  template:
    metadata:
      labels:
        app: hello-python
    spec:
      containers:
      - name: flask-change
        image: flask-change:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 8080
```

* Verify the container is running

`kubectl get pods`

Here is the output:

```bash
NAME                            READY   STATUS    RESTARTS   AGE
flask-change-7b7d7f467b-26htf   1/1     Running   0          8s
flask-change-7b7d7f467b-fh6df   1/1     Running   0          7s
flask-change-7b7d7f467b-fpsxr   1/1     Running   0          6s
```

* Describe the load balanced service:

`kubectl describe services hello-flask-change-service`

You should see output similar to this:

```bash
Name:                     hello-flask-change-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=hello-python
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.99.135.200
IPs:                      10.99.135.200
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
NodePort:                 <unset>  32000/TCP
Endpoints:                172.17.0.6:8080,172.17.0.7:8080,172.17.0.8:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

To create a visible ip on minikube run the following:
``` 
minikube service hello-flask-change-service
```

Invoke the endpoint to curl it:  

`make minikube-invoke`

```bash
curl http://192.168.59.102:32000//change/1/34
[
  {
    "5": "quarters"
  }, 
  {
    "1": "nickels"
  }, 
  {
    "4": "pennies"
  }
]
```

To cleanup the deployment do the following: 
```
kubectl delete deployment hello-python
minikube stop # to stop the minicube
```

## References

* All credits go to [https://github.com/noahgift/kubernetes-hello-world-python-flask](https://github.com/noahgift/kubernetes-hello-world-python-flask)
* Azure [Kubernetes deployment strategy](https://azure.microsoft.com/en-us/overview/kubernetes-deployment-strategy/)
* Service [Cluster Config](https://kubernetes.io/docs/tasks/access-application-cluster/service-access-application-cluster/) YAML file
* [Kubernetes.io Hello World](https://kubernetes.io/blog/2019/07/23/get-started-with-kubernetes-using-python/)
