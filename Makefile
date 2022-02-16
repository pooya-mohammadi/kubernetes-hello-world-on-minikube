install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

lint:
	sudo docker run --rm -i hadolint/hadolint < Dockerfile
	pylint --disable=R,C,W1203,W0702 app.py

test:
	python -m pytest -vv --cov=app test_app.py

build:
	sudo docker build -t flask-change:latest .

run:
	sudo docker run -p 8080:8080 flask-change

invoke:
	curl http://127.0.0.1:8080/change/1/34

image-export:
	sudo docker save flask-change | bzip2 > flask-change.bz2

copy-image:
	sudo scp -i $(minikube ssh-key) flask-change.bz2 docker@$(minikube ip):/home/docker/flask-change.bz2

run-kube:
	kubectl apply -f kube-hello-change.yaml

create-ip:
	minikube service

minikube-invoke:
	curl http://192.168.59.102:32000//change/1/340

all: install lint test