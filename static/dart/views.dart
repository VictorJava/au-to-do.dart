#library('views');

#import('dart:html');

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
  static final MINE = "#sb_mine";
  static final MINE_ALL = "#sb_mineall";
  static final NEEDS_ACTION = "#sb_needsaction";
  static final RESOLVED = "#sb_resolved";
  static final ALL = "#sb_all";
  
  void selected(String element) {
    self.queryAll('li').every(fn(Element e) {
      e.classes.remove('selected');
    });
    self.query(element).classes.add('selected');
  }
}

class PageView extends DefaultView {
  static final String SIDEBAR_ID = "nav";
  static final String SIDEBAR_HTML = """
<ul>
  <li id="sb_mine" class="mine">Mine (open)</li>
  <li id="sb_mineall" class="mineall">Mine (all)</li>
  <li id="sb_needsaction" class="needsaction">Needs Action</li>
  <li id="sb_resolved" class="resolved">Resolved</li>
  <li id="sb_all" class="all">All</li>
</ul>
    """;
  SidebarView sidebar;
  
  PageView() {
    sidebar = new SidebarView();
    sidebar.parent = this.self;
    sidebar.id = SIDEBAR_ID;
    sidebar.html = SIDEBAR_HTML;
  }
  
  void render() {
    sidebar.render();
    sidebar.selected(SidebarView.MINE);
  }
}