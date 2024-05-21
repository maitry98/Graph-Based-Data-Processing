# mtrived4-project-2

1. minikube start
2. kubectl apply -f kafka-setup.yaml
3. kubectl apply -f zookeeper-setup.yaml
4. helm install my-neo4j-release neo4j/neo4j -f neo4j-values.yaml
5. kubectl apply -f neo4j-service.yaml
6. kubectl apply -f kafka-neo4j-connector.yaml
7. kubectl port-forward svc/neo4j-service 7474:7474 7687:7687
8. kubectl port-forward svc/kafka-service 9092:9092
9. python3 data_producer.py (The data_producer.py files was edited in order to perfoem the data cleaning and filtering)
10. python3 tester.py (tester.py was edited in order to change the password from "project2phase1" to "project2phase2")
