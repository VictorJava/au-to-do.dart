#import('dart:html');
#import('dart:json');

interface ApiService {
  Future<Incident> getIncident(num id);
  Future<List<Incident>> listIncidents([queryParams]);
  Future<Incident> updateIncident(Incident incident);
}

/**
 * Provides a service class to interact with the Au-to-do API.
 *
 * Example usage:
 *   AjaxService service = new AjaxService(
 *     "http://localhost:9999/resources/v1/");
 *   
 *   Future<Incident> f = service.getIncident(1);
 *   f.then((Incident value) {
 *     print(value);
 *   });
 *   
 *   Future<List<Incident>> fPrime = service.listIncidents();
 *   fPrime.then((List<Incident> incidents) {
 *     incidents.forEach((Incident incident) {
 *       print(incident);
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
   *
   * TODO(danielholevoet): Use queryParams to filter this list.
   */
  Future<List<Incident>> listIncidents([queryParams]) {
    Completer<List<Incident>> completer = new Completer<List<Incident>>();
    
    Function success = Incident fn(List<Map<String, Dynamic>> data) {
      List<Incident> incidents = new List<Incident>();
      data.forEach((element) {
        incidents.add(new Incident.fromMap(element));
      });
      completer.complete(incidents);
    };
    
    String uri = baseUri + 'incidents/';
    AjaxClient.doGet(uri, onSuccess:success);
    
    return completer.future;
  }
  
  /**
   * Updates an incident.
   *
   * NOT YET IMPLEMENTED.
   */
  Future<Incident> updateIncident(Incident incident) {
    return null;
  }
}

class AjaxClient {
  static void doGet(String uri, [Function onSuccess=null,
                                 Function onError=null]) {
    doRequest("GET", uri, onSuccess:onSuccess, onError:onError);
  }
  
  static void doRequest(String method, String uri,
                        [String data=null, Function onSuccess=null,
                         Function onError=null]) {
    XMLHttpRequest req = new XMLHttpRequest();
    req.open(method, uri, true);
    req.on.readyStateChange.add(void _(evt) {
      if (req.readyState == XMLHttpRequest.DONE) {
        if (req.status == 200 || req.status == 204) {
          Object resp;
          if (req.responseText != null) {
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
  
  Incident(this.id, [this.title, this.author, this.created, this.updated,
                     this.owner, this.status]);
  
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
  }
  
  String toString() {
    return "Incident: " + this.id.toString() + ", title: " + title +
           ", owner: " + owner + ", status: " + status + ", created: " +
           created + ", acceptedTags: " + acceptedTags + ", suggestedTags: " +
           suggestedTags;
  }
}

class autodo {

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
