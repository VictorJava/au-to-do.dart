#import('dart:html');
#import('dart:json');
#import('../lawndart/lib/lawndart.dart');

interface ApiService {
  Future<Incident> getIncident(num id);
  Future<List<Incident>> listIncidents([Map<String, String> queryParams]);
  Future<Incident> updateIncident(Incident incident);
}

/**
 * Provides a service class to interact with the Au-to-do API.
 *
 * Example usage:
 *   AjaxService service = new AjaxService(
 *     "http://localhost:9999/resources/v1/");
 *   
 *   // Get an incident
 *   Future<Incident> f = service.getIncident(1);
 *   f.then((Incident value) {
 *     print(value);
 *   });
 *   
 *   // Get all incidents that match params
 *   Map<String, String> params = new Map<String, String>();
 *   params["accepted_tags"] = "API-Test";
 *   Future<List<Incident>> fPrime = service.listIncidents(params);
 *   fPrime.then((List<Incident> incidents) {
 *     incidents.forEach((Incident incident) {
 *       print(incident);
 *     });
 *   });
 *
 *   // Update an incident
 *   Future<Incident> f = service.getIncident(1);
 *   f.then((Incident incident) {
 *     print(incident);
 *     incident.status = "resolved";
 *     Future<Incident> fPrime = service.updateIncident(incident);
 *     fPrime.then((Incident updated) {
 *       print(updated);
 *     });
 *   });
 */
class AjaxService implements ApiService {
  String baseUri;
  
  AjaxService(this.baseUri);
  
  /**
   * Retrieves an incident by ID.
   */
  Future<Incident> getIncident(num id) {
    Completer<Incident> completer = new Completer<Incident>();
    
    Function success = Incident fn(Map<String, Dynamic> data) {
      Incident incident = new Incident.fromMap(data);
      completer.complete(incident);
    };
    
    String uri = baseUri + 'incidents/' + id.toString();
    AjaxClient.doGet(uri, onSuccess:success);
    
    return completer.future;
  }
  
  /**
   * Retrieves a list of incidents.
   */
  Future<List<Incident>> listIncidents([Map<String, String> queryParams]) {
    Completer<List<Incident>> completer = new Completer<List<Incident>>();
    
    Function success = Incident fn(List<Map<String, Dynamic>> data) {
      List<Incident> incidents = new List<Incident>();
      data.forEach((element) {
        incidents.add(new Incident.fromMap(element));
      });
      completer.complete(incidents);
    };
    
    String args = '?';
    if (queryParams != null) {
      queryParams.forEach((key, value) {
        args = args + key + '=' + value;
      });
    }
    String uri = baseUri + 'incidents/' + args;
    AjaxClient.doGet(uri, onSuccess:success);
    
    return completer.future;
  }
  
  /**
   * Updates an incident.
   *
   * Currently returns the same incident that's passed in. This is due to the
   * API implementation (which returns status 204, not a copy of the updated
   * object). This will change in the future, and then this method will be
   * updated to return the object the server returns.
   */
  Future<Incident> updateIncident(Incident incident) {
    Completer<Incident> completer = new Completer<Incident>();
    
    Function success = Incident fn(Map<String, Dynamic> data) {
      // Our API currently returns 204 on PUT, so we'll send back the same
      // incident. In the future, this will change to returning the new copy.
      completer.complete(incident);
    };
    
    String uri = baseUri + 'incidents/' + incident.id.toString();
    String data = JSON.stringify(incident.toMap());
    AjaxClient.doPut(uri, data, onSuccess:success);
    
    return completer.future;
  }
}

class AjaxClient {
  static void doGet(String uri, [Function onSuccess=null,
                                 Function onError=null]) {
    doRequest("GET", uri, onSuccess:onSuccess, onError:onError);
  }
  
  static void doPut(String uri, data, [Function onSuccess=null,
                                       Function onError=null]) {
    doRequest("PUT", uri, data:data, onSuccess:onSuccess, onError:onError);
  }
  
  static void doRequest(String method, String uri,
                        [String data=null, Function onSuccess=null,
                         Function onError=null]) {
    XMLHttpRequest req = new XMLHttpRequest();
    req.open(method, uri, true);
    req.on.readyStateChange.add((evt) {
      if (req.readyState == XMLHttpRequest.DONE) {
        if (req.status == 200 || req.status == 204) {
          Object resp;
          if (req.responseText != null && req.responseText.length > 0) {
            resp = JSON.parse(req.responseText);
          }
          if (onSuccess != null) {
            onSuccess(resp);
          }
        } else {
          if (onError != null) {
            onError(req.status, req.responseText);
          }
        }
      }
    });
    req.send(data);
  }
}

class Incident {
  static String NEW = "new";
  static String RESOLVED = "resolved";
  
  num id;
  String title;
  String author;
  Date created;
  Date updated;
  String owner;
  String status;
  List<String> acceptedTags;
  List<String> suggestedTags;
  List<String> trainedTags;
  
  Incident(this.id, [this.title, this.author, this.created, this.updated,
                     this.owner, this.status]);
  
  /**
   * Instantiates an incident from a map (usually sourced from JSON).
   */
  Incident.fromMap(Map<String, Dynamic> data) {
    this.id = data["id"];
    this.title = data["title"];
    this.author = data["author"];
    this.created = data["created"];
    this.updated = data["updated"];
    this.owner = data["owner"];
    this.status = data["status"];
    this.acceptedTags = data["accepted_tags"];
    this.suggestedTags = data["suggested_tags"];
    this.trainedTags = data["trained_tags"];
  }
  
  /**
   * Converts an incident to a map (usually intended to become JSON).
   */
  Map<String, Dynamic> toMap() {
    Map<String, Dynamic> data = new Map<String, Dynamic>();
    data["id"] = id;
    data["title"] = title;
    data["author"] = author;
    data["created"] = created;
    data["updated"] = updated;
    data["owner"] = owner;
    data["status"] = status;
    data["accepted_tags"] = acceptedTags;
    data["suggested_tags"] = suggestedTags;
    data["trained_tags"] = trainedTags;
    return data;
  }
  
  String toString() {
    return "Incident: " + this.id.toString() + ", title: " + title +
           ", owner: " + owner + ", status: " + status + ", created: " +
           created + ", acceptedTags: " + acceptedTags + ", suggestedTags: " +
           suggestedTags;
  }
}

interface ObjectCache<T> {
  Future<T> getObject(String key);
  Future<List<T>> listObjects();
  Future<List<T>> queryObjects([Map<String, String> queryParams]);
  Future<T> updateObject(T object);
  Future<bool> deleteObject(T object);
}

// TODO(dan): Patch this up when the underlying implementation works.
//abstract class ObjectCacheImpl implements ObjectCache {
//  static String objectName = "objects"; 
//  
//  String dbName = "objects";
//  int version = 1;
//  
//  IDBObjectStore store;
//  
//  ObjectCacheImpl();
//  
//  void createObjectStore(Function callback) {
//    IDBRequest req = IDBFactory.open(objectName, version);
//    req.addEventListener(IDBSuccess, (IDBDatabase db) {
//      store = db.createObjectStore(objectName);
//    });
//  }
//}

/**
 * Provides cache for incidents, and manages synchronization with the server.
 *
 * While the underlying implementation is incomplete, retrieving from and
 * storing to this object will result in requests over the wire. It will also
 * directly implement ObjectCache in the interim.
 */
class IncidentCache implements ObjectCache {
  String baseUri;
  AjaxService service;
  
  IncidentCache(baseUri) {
    this.baseUri = baseUri;
    service = new AjaxService(baseUri);
  }
  
  Future<Incident> getObject(String key) {
    return service.getIncident(Math.parseInt(key));
  }
  
  Future<List<Incident>> listObjects() {
    return service.listIncidents();
  }
  
  Future<List<Incident>> queryObjects([Map<String, String> queryParams]) {
    return service.listIncidents(queryParams);
  }
  
  Future<Incident> updateObject(Incident incident) {
    return service.updateIncident(incident);
  }
  
  /**
   * Deletes an object from the cache.
   *
   * Returns whether or not the object was deleted.
   */
  Future<bool> deleteObject(Incident incident) {
    Completer<bool> completer = new Completer<bool>();
    completer.complete(false);
    return completer.future;
  }
}

class Application {

  autodo() {
  }

  void run() {
    write("Hello World!");
  }

  void write(String message) {
    // the HTML library defines a global "document" variable
    document.query('#status').innerHTML = message;
  }
}

void main() {
  new autodo().run();
}
