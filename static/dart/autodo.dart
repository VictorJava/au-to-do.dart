#import('dart:html');
#import('dart:json');
#import('lawndart/lib/lawndart.dart');
#import('views.dart');
#import('models.dart');

#source('value.dart');

interface ApiService default AjaxService {
  ApiService([String baseUri]);
  Future<Incident> getIncident(num id);
  Future<List<Incident>> listIncidents([ListIncidentsFilter filter]);
  Future<Incident> updateIncident(Incident incident);
}

class ListIncidentsFilter {
  var accepted_tags,
      suggested_tags,
      owner,
      status,
      created_before,
      created_after,
      updated_before,
      updated_after,
      resolved_before,
      resolved_after;
  
  ListIncidentsFilter.allForMe([owner = 'me']);

  Map<String, String> toMap() {
    return {
      'accepted_tags' : accepted_tags,
      'suggested_tags' : suggested_tags,
      'owner' : owner,
      'status' : status,
      'created_before' : created_before,
      'created_after' : created_after,
      'updated_before' : updated_before,
      'updated_after' : updated_after,
      'resolved_before' : resolved_before,
      'resolved_after' : resolved_after
    };
  }
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
  
  AjaxService([this.baseUri = '/resources/v1/']);
  
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
  Future<List<Incident>> listIncidents([ListIncidentsFilter filter]) {
    Completer<List<Incident>> completer = new Completer<List<Incident>>();
    
    Function success = Incident fn(List<Map<String, Dynamic>> data) {
      List<Incident> incidents = new List<Incident>();
      data.forEach((element) {
        incidents.add(new Incident.fromMap(element));
      });
      completer.complete(incidents);
    };
    
    List<String> args = [];
    if (filter != null) {
      filter.toMap().forEach((key, value) {
        if (value != null) args.add('${key}=${value}');
      });
    }
    String uri = baseUri + 'incidents/?' + Strings.join(args, '&');
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

class autodo {

  PageView page;
  Adapter database;
  ApiService service;
  ListValue<Incident> visibleIncidents;

  autodo() {
    page = new PageView();
    database = new IndexedDbAdapter({'dbName' : 'autodo'});
    service = new ApiService();
    visibleIncidents = new ListValue<Incident>();
  }

  void run() {
    _loadDatabase();
    page.render();
  }
  
  _loadDatabase() {
    database.open().then((_) => _syncDatabase());
  }
  
  _syncDatabase() {
    service.listIncidents(new ListIncidentsFilter.allForMe()).then((incidents) {
      visibleIncidents.addAll(incidents);
      incidents.forEach((i) => database.save(i, i.id));
    });
  }
}

void main() {
  new autodo().run();
}
