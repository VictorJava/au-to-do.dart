#library('models');

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