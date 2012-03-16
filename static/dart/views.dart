#library('views');

#import('dart:html');
#import('state.dart');
#import('models.dart');
#import('value.dart');

UIState state;

interface View {
  void render();
  void bind();
}

class DefaultView implements View {
  Element parent;
  Element self;
  String id = "body";
  String html = "<p>Hello World!</p>";
  
  DefaultView() {
    parent = document;
    findSelf();
  }
  
  void render() {
    findSelf();
    self.elements = [new Element.html(html)];
  }
  
  bind() {}
  
  void findSelf() {
    self = parent.query(id);
  }
}

class SidebarView extends DefaultView {
  static final MINE = "sb_mine";
  static final MINE_ALL = "sb_mineall";
  static final NEEDS_ACTION = "sb_needsaction";
  static final RESOLVED = "sb_resolved";
  static final ALL = "sb_all";
  
  static final String ID = "nav";
  static final String HTML = """
<ul>
  <li id="sb_mine" class="mine">Mine (open)</li>
  <li id="sb_mineall" class="mineall">Mine (all)</li>
  <li id="sb_needsaction" class="needsaction">Needs Action</li>
  <li id="sb_resolved" class="resolved">Resolved</li>
  <li id="sb_all" class="all">All</li>
</ul>
    """;
  
  SidebarView(Element parent) {
    this.parent = parent;
    this.id = ID;
    this.html = HTML;
    findSelf();
  }
  
  void bind() {
    self.queryAll('li').forEach(fn(Element e) {
      e.on.click.add(fn(Event event) {
        select(event.target.id);
        state.push(event.target.id);
      });
    });
  }
  
  void select(String element) {
    self.queryAll('li').forEach(fn(Element e) {
      e.classes.remove('selected');
    });
    self.query('#' + element).classes.add('selected');
  }
}

class ListView<T> extends DefaultView {
  List<T> items;
}

class IncidentListView extends ListView<Incident> implements ListChangeListener<Incident> {
  static final String ID = '#main';
  static final String HTML = '<table class="list"></table>';
  
  List<IncidentView> views;
  Element table;
  
  IncidentListView(Element parent) {
    this.parent = parent;
    this.items = items;
    this.id = ID;
    this.html = HTML;
    findSelf();
    
    views = new List<IncidentView>();
  }
  
  void render() {
    super.render();
    table = self.query('table.list');
  }
  
  void bind() {}
  
  void onAddAll(Collection<Incident> incidents) {
    incidents.forEach(fn(Incident incident) {
      IncidentView view = new IncidentView(this.self, incident);
      views.add(view);
      // TODO: move this to IncidentView, yes?
      Element row = new Element.tag('tr');
      row.id = 'incident_' + incident.id;
      table.nodes.add(row);
      view.render();
    });
  }
}

class IncidentView extends DefaultView {
  static final String CHECKBOX_HTML = """
  <td>
    <input type="checkbox" class="content_checkbox" value="id">
  </td>
    """;
  static final String CONTENT_HTML = """
  <td>
    <div class="content-list-div" value="id">
      <strong>title</strong>
      <span>summary</span>
    </div>
  </td>
    """;
  static final String DATE_HTML = '<td>datetime</td>';
  
  Incident incident;
  
  IncidentView(Element parent, Incident incident) {
    this.parent = parent;
    this.incident = incident;
    this.id = '#incident_' + incident.id.toString();
  }
  
  void render() {
    findSelf();
    self.elements = [
        new Element.html(CHECKBOX_HTML),
        new Element.html(CONTENT_HTML),
        new Element.html(DATE_HTML)];
    self.query('td input').value = incident.id.toString();
    self.query('.content-list-div strong').innerHTML = incident.title;
  }
}

class PageView extends DefaultView {
  SidebarView sidebarView;
  IncidentListView incidentListView;
  
  PageView() {
    state = new UIState();
    sidebarView = new SidebarView(this.self);
    incidentListView = new IncidentListView(this.self);
  }
  
  void render() {
    sidebarView.render();
    sidebarView.bind();
    sidebarView.select(SidebarView.MINE);
    incidentListView.render();
  }
}