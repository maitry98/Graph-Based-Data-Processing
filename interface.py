from neo4j import GraphDatabase

class Interface:
    def __init__(self, uri, user, password):
        self._driver = GraphDatabase.driver(uri, auth=(user, password), encrypted=False)
        self._driver.verify_connectivity()

    def close(self):
        self._driver.close()

    def bfs(self, start_node, last_node):

        # TODO: Implement this method
        with self._driver.session() as session:
            #session.run("""CALL gds.graph.drop('myGraph')""")
            result = session.run(("""
                    MATCH (a {name:$c}) , (b {name:$d})
                    WITH id(a) AS source, id(b) AS targetNodes
                    CALL gds.bfs.stream('myGraph', {
                      sourceNode: source,
                      targetNodes: targetNodes
                    })
                    YIELD path
                    RETURN path
            """),c=start_node,d=last_node)
            r=result.data()
            '''
            for record in result:
                #print(record)
                r.append({"path":[{"name":record['path'].start_node['name']},{"name":record['path'].end_node['name']}]})
            #print(r)
            #path = result[0]["path"]
            #print(path)]
            '''
            return r

        #raise NotImplementedError

    def pagerank(self, max_iterations, weight_property):
        # TODO: Implement this method
        
        with self._driver.session() as session:  
            session.run("""CALL gds.graph.project(
                  'myGraph',
                  'Location',
                  'TRIP',
                  {
                    relationshipProperties: 'distance'
                  }
                )""")
            result=session.run(("""CALL gds.pageRank.stream("myGraph", {
              maxIterations: $a,
              dampingFactor: 0.85,
              relationshipWeightProperty: $b
            })
            YIELD nodeId, score
            RETURN gds.util.asNode(nodeId).name AS name, score
            ORDER BY score DESC limit 1
            
            UNION 
            
            CALL gds.pageRank.stream("myGraph", {
              maxIterations: $a,
              dampingFactor: 0.85,
              relationshipWeightProperty: $b
            })
            YIELD nodeId, score
            RETURN gds.util.asNode(nodeId).name AS name, score
            ORDER BY score ASC limit 1
            
            """),a=max_iterations,b=weight_property)
            '''
            r=[]
            for record in result:
                r.append([{'name':record["name"],'score':record["score"]}])
            return [r[0][0],r[-1][0]];
            '''
            r=result.data()
            return r
        
        #raise NotImplementedError
